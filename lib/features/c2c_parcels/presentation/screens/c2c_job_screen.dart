import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/show_dialog.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../core/widgets/vertical_timeline.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../c2c_display.dart';
import '../cubit/c2c_action_cubit.dart';
import '../cubit/c2c_action_state.dart';
import '../cubit/c2c_job_cubit.dart';
import '../cubit/c2c_job_state.dart';
import '../widgets/c2c_otp_sheet.dart';
import '../widgets/c2c_stop_card.dart';

/// One accepted C2C job: the lifecycle (contract §2), both stops with full
/// details, and the one next command the server allows.
class C2cJobScreen extends StatelessWidget {
  /// `null` when the route's id isn't a number.
  final int? parcelId;

  /// The board's copy, shown while the server copy loads.
  final C2cParcel? initial;

  const C2cJobScreen({super.key, required this.parcelId, this.initial});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final int? id = parcelId;

    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<C2cJobCubit>(
          create: (_) {
            final C2cJobCubit cubit = ServiceLocator.instance<C2cJobCubit>();
            if (id != null) cubit.load(id, initial: initial);
            return cubit;
          },
        ),
        BlocProvider<C2cActionCubit>(
          create: (_) => ServiceLocator.instance<C2cActionCubit>(),
        ),
      ],
      child: BlocListener<C2cActionCubit, C2cActionState>(
        listener: (BuildContext context, C2cActionState state) =>
            _onAction(context, state, id),
        child: Scaffold(
          backgroundColor: c.background,
          appBar: SimpleAppBar(
            title: initial?.reference.isNotEmpty == true
                ? initial!.reference
                : Strings.c2cSegment,
            onBack: () => context.pop(),
          ),
          body: SafeArea(
            child: id == null
                ? Center(child: Text(Strings.c2cJobEnded))
                : BlocBuilder<C2cJobCubit, C2cJobState>(
                    builder: (BuildContext context, C2cJobState state) =>
                        switch (state) {
                          C2cJobLoading() => Center(
                            child: CircularProgressIndicator(
                              color: c.secondary,
                            ),
                          ),
                          C2cJobError(:final String message) => ErrorRetryView(
                            message: message,
                            onRetry: () =>
                                context.read<C2cJobCubit>().load(id),
                          ),
                          C2cJobEnded() => const _Ended(),
                          C2cJobLoaded(:final C2cParcel parcel) => _Content(
                            parcel: parcel,
                          ),
                        },
                  ),
          ),
        ),
      ),
    );
  }

  static void _onAction(BuildContext context, C2cActionState state, int? id) {
    final C2cJobCubit job = context.read<C2cJobCubit>();
    switch (state) {
      case C2cActionSuccess(:final C2cAction action, :final C2cParcel? parcel):
        showAppSnackBar(
          context: context,
          message: action == C2cAction.complete
              ? Strings.parcelDeliveryCompleted
              : Strings.c2cStepDone,
          type: ToastType.success,
        );
        if (parcel != null) {
          job.applyParcel(parcel);
        } else if (id != null) {
          job.load(id);
        }
      case C2cActionFailure(:final String message, :final bool shouldRefresh):
        showAppSnackBar(
          context: context,
          message: message,
          type: ToastType.error,
        );
        if (shouldRefresh && id != null) job.load(id);
      default:
        break;
    }
  }
}

class _Ended extends StatelessWidget {
  const _Ended();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            size: 56.r,
            color: context.colors.secondary,
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            Strings.c2cJobEnded,
            textAlign: TextAlign.center,
            style: AppTextStyles.title(color: context.colors.textPrimary),
          ),
          SizedBox(height: AppSpacing.xl.h),
          AppOutlinedButton(text: Strings.ok, onPressed: () => context.pop()),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final C2cParcel parcel;

  const _Content({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String summary = parcel.summary;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.screen.w),
            children: <Widget>[
              VerticalTimeline(steps: _steps(parcel.status)),
              SizedBox(height: AppSpacing.lg.h),
              C2cStopCard(
                title: Strings.c2cPickupTitle,
                stop: parcel.pickup,
                instructions: parcel.pickupInstructions,
                isCurrentLeg: parcel.isHeadingToPickup,
              ),
              SizedBox(height: AppSpacing.md.h),
              C2cStopCard(
                title: Strings.c2cDropoffTitle,
                stop: parcel.dropoff,
                instructions: parcel.deliveryInstructions,
                isCurrentLeg: !parcel.isHeadingToPickup,
              ),
              if (summary.isNotEmpty ||
                  parcel.description.isNotEmpty) ...<Widget>[
                SizedBox(height: AppSpacing.lg.h),
                Text(
                  Strings.c2cParcelInfo,
                  style: AppTextStyles.h2(color: c.primaryDark),
                ),
                SizedBox(height: AppSpacing.xs.h),
                if (summary.isNotEmpty)
                  Text(summary, style: AppTextStyles.body(color: c.textPrimary)),
                if (parcel.description.isNotEmpty)
                  Text(
                    parcel.description,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.screen.w),
          child: _NextStepButton(parcel: parcel),
        ),
      ],
    );
  }

  /// Accepted → delivered, marking where the parcel stands.
  static List<TimelineStep> _steps(C2cStatus? status) {
    final List<C2cStatus> path = C2cStatus.lifecycle.sublist(1);
    final int at = status == null ? -1 : path.indexOf(status);
    return <TimelineStep>[
      for (int i = 0; i < path.length; i++)
        TimelineStep(
          title: path[i].label,
          subtitle: '',
          state: i < at
              ? TimelineStepState.completed
              : i == at
              ? TimelineStepState.active
              : TimelineStepState.pending,
        ),
    ];
  }
}

/// The server's next allowed command; completion asks for the recipient's
/// code when required, or a confirmation otherwise.
class _NextStepButton extends StatelessWidget {
  final C2cParcel parcel;

  const _NextStepButton({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final C2cAction? action = parcel.primaryAction;
    if (action == null) {
      return AppButton(btnText: parcel.status.label, onPressed: null);
    }
    return BlocSelector<C2cActionCubit, C2cActionState, bool>(
      selector: (C2cActionState s) => s is C2cActionInProgress,
      builder: (BuildContext context, bool inProgress) => AppButton(
        btnText: action.label,
        isLoading: inProgress,
        onPressed: () => _run(context, action),
      ),
    );
  }

  Future<void> _run(BuildContext context, C2cAction action) async {
    final C2cActionCubit cubit = context.read<C2cActionCubit>();
    if (action != C2cAction.complete) {
      await cubit.run(parcel, action);
      return;
    }
    if (parcel.requiresOtpToComplete) {
      final String? otp = await showC2cOtpSheet(context);
      if (otp != null && !cubit.isClosed) await cubit.run(parcel, action, otp: otp);
      return;
    }
    final bool? confirmed = await showAppDialog(
      context: context,
      child: const _ConfirmHandover(),
    );
    if (confirmed == true && !cubit.isClosed) await cubit.run(parcel, action);
  }
}

class _ConfirmHandover extends StatelessWidget {
  const _ConfirmHandover();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Strings.c2cCompleteConfirm,
            textAlign: TextAlign.center,
            style: AppTextStyles.title(color: context.colors.primaryDark),
          ),
          SizedBox(height: AppSpacing.xl.h),
          AppButton(
            btnText: Strings.confirm,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          SizedBox(height: AppSpacing.sm.h),
          AppOutlinedButton(
            text: Strings.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
