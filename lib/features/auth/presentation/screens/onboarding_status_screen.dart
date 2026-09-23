import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/tinted_note.dart';
import '../../domain/entities/approval_status.dart';
import '../../domain/entities/onboarding_status.dart';
import '../cubit/session_cubit.dart';
import '../cubit/session_state.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/session_error_view.dart';

/// Holding screen for authenticated drivers who can't operate yet (pending
/// admin review, or rejected). Re-reads `onboarding-status` on entry.
class OnboardingStatusScreen extends StatefulWidget {
  const OnboardingStatusScreen({super.key});

  @override
  State<OnboardingStatusScreen> createState() => _OnboardingStatusScreenState();
}

class _OnboardingStatusScreenState extends State<OnboardingStatusScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SessionCubit>().refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      listenWhen: (_, SessionState current) =>
          current is SessionApproved || current is SessionUnauthenticated,
      listener: (BuildContext context, SessionState state) =>
          context.goNamed(
            state is SessionApproved
                ? AppRoutes.homeName
                : AppRoutes.loginName,
          ),
      builder: (BuildContext context, SessionState state) => switch (state) {
        SessionNotApproved(:final status, :final isRefreshing) => _StatusView(
          status: status,
          isRefreshing: isRefreshing,
        ),
        SessionError(:final message) => Scaffold(
          backgroundColor: context.colors.surface,
          body: SafeArea(
            child: SessionErrorView(
              message: message,
              onRetry: context.read<SessionCubit>().refreshStatus,
            ),
          ),
        ),
        _ => Scaffold(
          backgroundColor: context.colors.surface,
          body: Center(
            child: CircularProgressIndicator(color: context.colors.secondary),
          ),
        ),
      },
    );
  }
}

class _StatusView extends StatelessWidget {
  final OnboardingStatus status;
  final bool isRefreshing;

  const _StatusView({required this.status, required this.isRefreshing});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool rejected = status.approvalStatus == ApprovalStatus.rejected;
    final String? reason = status.rejectionReason;

    return AuthScaffold(
      title: rejected
          ? Strings.onboardingRejectedTitle
          : Strings.onboardingPendingTitle,
      subtitle: rejected
          ? Strings.onboardingRejectedSubtitle
          : Strings.onboardingPendingSubtitle,
      footerPrimary: Strings.authFooterSecure,
      footerSecondary: Strings.authFooterTagline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (rejected && reason != null && reason.isNotEmpty) ...<Widget>[
            TintedNote(
              text: Strings.onboardingRejectionReason(reason),
              backgroundColor: c.errorLight,
              textColor: c.error,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl.h),
          ],
          AppButton(
            btnText: Strings.onboardingRefresh,
            isLoading: isRefreshing,
            onPressed: context.read<SessionCubit>().refreshStatus,
          ),
          SizedBox(height: AppSpacing.sm.h),
          AppOutlinedButton(
            text: Strings.profileLogout,
            buttonRadius: AppRadius.lg.r,
            minimumSize: Size.fromHeight(AppSizes.buttonHeight.h),
            onPressed: context.read<SessionCubit>().logout,
          ),
        ],
      ),
    );
  }
}
