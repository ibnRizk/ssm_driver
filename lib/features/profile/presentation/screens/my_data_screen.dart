import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/identity_type_label.dart';
import '../../domain/entities/driver_profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

/// "My Data" (بياناتي) — read-only view of the Driver's personal details.
///
/// Reuses the Profile tab's [ProfileCubit] when one is passed in, so no second
/// request is made; opened any other way (e.g. a deep link) it loads its own.
class MyDataScreen extends StatelessWidget {
  final ProfileCubit? cubit;

  const MyDataScreen({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    final ProfileCubit? shared = cubit;
    return shared != null
        ? BlocProvider<ProfileCubit>.value(
            value: shared,
            child: const _MyDataView(),
          )
        : BlocProvider<ProfileCubit>(
            create: (_) =>
                ServiceLocator.instance<ProfileCubit>()..loadProfile(),
            child: const _MyDataView(),
          );
  }
}

class _MyDataView extends StatelessWidget {
  const _MyDataView();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.profilePersonalData,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (BuildContext context, ProfileState state) =>
              switch (state) {
                ProfileInitial() || ProfileLoading() => Center(
                  child: CircularProgressIndicator(color: c.secondary),
                ),
                ProfileError(:final String message) => ErrorRetryView(
                  message: message,
                  onRetry: context.read<ProfileCubit>().loadProfile,
                ),
                ProfileLoaded(:final DriverProfile profile) => _ProfileDetails(
                  profile: profile,
                ),
              },
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  final DriverProfile profile;

  const _ProfileDetails({required this.profile});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final List<({IconData icon, String label, String value})> fields =
        <({IconData icon, String label, String value})>[
          (
            icon: Icons.person_outline,
            label: Strings.authFirstNameLabel,
            value: profile.firstName,
          ),
          (
            icon: Icons.person_outline,
            label: Strings.authLastNameLabel,
            value: profile.lastName,
          ),
          (
            icon: Icons.phone_outlined,
            label: Strings.authPhoneLabel,
            value: profile.phone,
          ),
          (
            icon: Icons.email_outlined,
            label: Strings.authEmailLabel,
            value: profile.email,
          ),
          (
            icon: Icons.badge_outlined,
            label: Strings.authIdentityTypeLabel,
            value: profile.identityType?.label ?? '',
          ),
          (
            icon: Icons.numbers_outlined,
            label: Strings.authIdentityNumberLabel,
            value: profile.identityNumber,
          ),
        ];

    return ListView(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      children: <Widget>[
        Container(
          decoration: AppDecorations.card(c),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < fields.length; i++) ...<Widget>[
                if (i > 0)
                  Divider(
                    color: c.border,
                    height: 1,
                    indent: AppSpacing.md.w,
                    endIndent: AppSpacing.md.w,
                  ),
                _DataRow(
                  icon: fields[i].icon,
                  label: fields[i].label,
                  value: fields[i].value,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: c.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: c.secondary, size: 20.r),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  value.isEmpty ? '-' : value,
                  style: AppTextStyles.title(color: c.primaryDark),
                  // Phone, email and ID number are LTR even in an RTL layout.
                  textDirection: value.isNotEmpty && !_arabic.hasMatch(value)
                      ? TextDirection.ltr
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Any Arabic-script character (all blocks, incl. presentation forms).
  /// Compiled once rather than per build.
  static final RegExp _arabic = RegExp(r'\p{Script=Arabic}', unicode: true);
}
