import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../domain/entities/driver_profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_settings_list.dart';
import '../widgets/vehicle_info_card.dart';

/// Driver profile — the `profile` tab's body. `MainScaffold` already
/// supplies the outer Scaffold and bottom nav; this only builds the
/// scrollable content.
///
/// Owns the [ProfileCubit] (fetches `GET /delivery-man/profile` on open) and
/// hands it to the My Data and Edit Profile screens it pushes.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => ServiceLocator.instance<ProfileCubit>()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screen.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const ProfileHeader(),
              SizedBox(height: AppSpacing.lg.h),
              const _ProfileCardSection(),
              SizedBox(height: AppSpacing.xl.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    Strings.profileVehicleSection,
                    style: AppTextStyles.h2(color: c.textPrimary),
                  ),
                  Text(
                    Strings.profileVehicleSubtitle,
                    style: AppTextStyles.titleSmall(color: c.secondary),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              const _VehicleSection(),
              SizedBox(height: AppSpacing.xl.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    Strings.settings,
                    style: AppTextStyles.h2(color: c.textPrimary),
                  ),
                  Text(
                    Strings.navProfile,
                    style: AppTextStyles.titleSmall(color: c.secondary),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              BlocBuilder<LocaleCubit, Locale>(
                builder: (BuildContext context, Locale locale) {
                  final bool isArabic = locale.languageCode == 'ar';


                  return ProfileSettingsList(
                    items: <ProfileSettingsItem>[
                      ProfileSettingsItem(
                        icon: Icons.badge_outlined,
                        title: Strings.profilePersonalData,
                        subtitle: Strings.profilePersonalDataSubtitle,
                        onTap: () => context.pushNamed(
                          AppRoutes.myDataName,
                          extra: context.read<ProfileCubit>(),
                        ),
                      ),

                      ProfileSettingsItem.toggle(
                        icon: Icons.notifications_outlined,
                        title: Strings.profileNotifications,
                        subtitle: Strings.profileNotificationsSubtitle,
                        value: _notificationsEnabled,
                        onChanged: (bool value) {
                          setState(() => _notificationsEnabled = value);
                        },
                      ),
                      ProfileSettingsItem(
                        icon: Icons.language_outlined,
                        title: Strings.language,
                        subtitle: isArabic ? Strings.arabic : Strings.english,
                        onTap: () => showLanguagePicker(context),
                      ),
                      ProfileSettingsItem.toggle(
                        icon: Icons.dark_mode_outlined,
                        title: Strings.profileThemeMode,
                        subtitle: Strings.profileThemeModeSubtitle,
                        value:
                            context.watch<ThemeCubit>().state == ThemeMode.dark,
                        onChanged: (bool value) {
                          context.read<ThemeCubit>().setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                      ProfileSettingsItem(
                        icon: Icons.support_agent_outlined,
                        title: Strings.profileSupport,
                        subtitle: Strings.profileSupportSubtitle,
                        onTap: () => context.pushNamed(AppRoutes.supportName),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: AppSpacing.xl.h),
              LogoutButton(
                onTap: () async {
                  await context.read<SessionCubit>().logout();
                  if (context.mounted) context.goNamed(AppRoutes.loginName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The identity card bound to [ProfileCubit]: real name, phone, zone and
/// rating once loaded, a shimmer while loading, and a retry on failure.
class _ProfileCardSection extends StatelessWidget {
  const _ProfileCardSection();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (BuildContext context, ProfileState state) => switch (state) {
        ProfileInitial() || ProfileLoading() => AppShimmer(
          child: Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: c.primaryDark,
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
            ),
          ),
        ),
        ProfileError(:final String message) => ErrorRetryView(
          message: message,
          onRetry: context.read<ProfileCubit>().loadProfile,
        ),
        ProfileLoaded(:final DriverProfile profile) => ProfileCard(
          name: profile.fullName,
          phone: profile.phone,
          zone: profile.zoneName,
          ratingText: switch (profile.rating) {
            final DriverRating rating => Strings.profileRatingLabel(
              rating.average.toStringAsFixed(1),
            ),
            null => Strings.profileRatingNew,
          },
          onEditTap: () => context.pushNamed(
            AppRoutes.editProfileName,
            extra: context.read<ProfileCubit>(),
          ),
        ),
      },
    );
  }
}

/// The assigned vehicle from the loaded profile, or an "unassigned" card.
/// Hidden until the profile loads — the identity card above already shows
/// the loading and error states.
class _VehicleSection extends StatelessWidget {
  const _VehicleSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (BuildContext context, ProfileState state) => switch (state) {
        ProfileLoaded(profile: DriverProfile(:final AssignedVehicle vehicle)) =>
          VehicleInfoCard(
            name: vehicle.name,
            subtitle: switch (vehicle.plateNumber) {
              final String plate => Strings.profileVehiclePlate(plate),
              null => Strings.profileVehicleNoPlate,
            },
          ),
        ProfileLoaded() => VehicleInfoCard(
          name: Strings.profileVehicleUnassigned,
          subtitle: Strings.profileVehicleUnassignedHint,
          isVerified: false,
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
