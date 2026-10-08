import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/general_cubit/driver_stats_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/current_work.dart';
import '../../domain/entities/problem_report.dart';
import '../cubit/current_work_cubit.dart';
import '../cubit/current_work_state.dart';
import '../cubit/report_problem_cubit.dart';
import '../cubit/report_problem_state.dart';

/// The Driver's way out of a stuck order, at every step of the delivery:
/// pick a reason, add an optional note, then either report it to support
/// (the order carries on) or give the order up — released back to dispatch
/// before pickup, a failed delivery after it.
///
/// A given-up order has left `current-work`, so the Driver is taken home.
Future<void> showReportProblemSheet(
  BuildContext context, {
  required CurrentWork work,
}) async {
  final ReportProblemState? outcome =
      await showModalBottomSheet<ReportProblemState>(
        context: context,
        isScrollControlled: true,
        builder: (_) => BlocProvider<ReportProblemCubit>(
          create: (_) =>
              ServiceLocator.instance<ReportProblemCubit>()..loadReasons(),
          child: _ReportProblemSheet(work: work),
        ),
      );
  if (outcome == null || !context.mounted) return;
  switch (outcome) {
    // A report never changes the order (`next_action: continue_order`), so
    // the Driver just stays on this step.
    case ReportProblemSent():
      showAppSnackBar(
        context: context,
        message: Strings.orderReportProblemSent,
        type: ToastType.success,
      );
    case ReportProblemGaveUp(:final bool pickedUp):
      showAppSnackBar(
        context: context,
        message: pickedUp ? Strings.orderDeliveryFailed : Strings.orderReleased,
        type: ToastType.info,
      );
      context.read<CurrentWorkCubit>().loadCurrentWork(keepContent: false);
      // COD liability may have changed.
      context.read<DriverStatsCubit>().refreshStats();
      context.goNamed(AppRoutes.homeName);
    case ReportProblemLoading() ||
        ReportProblemNoReasons() ||
        ReportProblemLoadFailed() ||
        ReportProblemReady():
      break;
  }
}

/// Asks before an order is given up — it can't be taken back, and it
/// counts against the Driver. "Keep the order" is the highlighted default.
Future<bool> _confirmGiveUp(
  BuildContext context, {
  required bool pickedUp,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final AppColors c = context.colors;
      return AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: c.error, size: 48.r),
        title: Text(
          Strings.orderGiveUpConfirmQuestion,
          textAlign: TextAlign.center,
          style: AppTextStyles.h2(color: c.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              pickedUp
                  ? Strings.orderFailDeliveryConfirmTitle
                  : Strings.orderReleaseConfirmTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.title(color: c.textPrimary),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              pickedUp
                  ? Strings.orderFailDeliveryConfirmBody
                  : Strings.orderReleaseConfirmBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: c.textSecondary),
            ),
            SizedBox(height: AppSpacing.md.h),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm.r),
              decoration: BoxDecoration(
                color: c.errorLight,
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                border: Border.all(color: c.error),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.gpp_maybe_rounded, color: c.error, size: 22.r),
                  SizedBox(width: AppSpacing.xs.w),
                  Expanded(
                    child: Text(
                      Strings.orderGiveUpRecordedWarning,
                      style: AppTextStyles.label(color: c.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowDirection: VerticalDirection.down,
        actions: <Widget>[
          AppButton(
            btnText: Strings.orderGiveUpKeepOrder,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              pickedUp
                  ? Strings.orderFailDeliveryButton
                  : Strings.orderReleaseButton,
              style: AppTextStyles.button(color: c.error),
            ),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

class _ReportProblemSheet extends StatefulWidget {
  final CurrentWork work;

  const _ReportProblemSheet({required this.work});

  @override
  State<_ReportProblemSheet> createState() => _ReportProblemSheetState();
}

class _ReportProblemSheetState extends State<_ReportProblemSheet> {
  static const int _maxNoteLength = 500;

  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// The freshest copy of this order: once `current-work` is re-read after
  /// a refused give-up, a retry carries the new `expected_version` — and
  /// release vs fail-delivery follows a pickup made in the meantime.
  static CurrentWork _latest(CurrentWorkState state, CurrentWork opened) =>
      switch (state) {
        CurrentWorkLoaded(:final CurrentWork work)
            when work.orderId == opened.orderId =>
          work,
        _ => opened,
      };

  Future<void> _giveUp(BuildContext context, CurrentWork work) async {
    final ReportProblemCubit cubit = context.read<ReportProblemCubit>();
    // The cubit refuses a short note too; this just skips the dialog.
    if (!isGiveUpNoteLongEnough(_note.text)) {
      return cubit.giveUp(work: work, note: _note.text);
    }
    final bool confirmed = await _confirmGiveUp(
      context,
      pickedUp: !work.awaitingPickup,
    );
    if (!confirmed) return;
    // Exactly what the Driver confirmed; a stale version is refused (409)
    // and the order re-read for the next try.
    await cubit.giveUp(work: work, note: _note.text);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final CurrentWork work = context.select<CurrentWorkCubit, CurrentWork>(
      (CurrentWorkCubit cubit) => _latest(cubit.state, widget.work),
    );

    return BlocConsumer<ReportProblemCubit, ReportProblemState>(
      listener: (BuildContext context, ReportProblemState state) {
        if (state is ReportProblemSent || state is ReportProblemGaveUp) {
          Navigator.of(context).pop(state);
        } else if (state is ReportProblemReady && state.workStale) {
          context.read<CurrentWorkCubit>().loadCurrentWork();
        }
      },
      builder: (BuildContext context, ReportProblemState state) => SafeArea(
        child: Padding(
          // Keeps the note field above the keyboard.
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.screen.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  Strings.orderReportProblemButton,
                  style: AppTextStyles.title(color: c.textPrimary),
                ),
                SizedBox(height: AppSpacing.md.h),
                ...switch (state) {
                  ReportProblemLoading() ||
                  ReportProblemSent() ||
                  ReportProblemGaveUp() => <Widget>[
                    const Center(child: CircularProgressIndicator()),
                  ],
                  ReportProblemNoReasons() => <Widget>[
                    ErrorRetryView(
                      message: Strings.orderReportProblemNoReasons,
                      onRetry: context.read<ReportProblemCubit>().loadReasons,
                    ),
                  ],
                  ReportProblemLoadFailed(:final String message) => <Widget>[
                    ErrorRetryView(
                      message: message,
                      onRetry: context.read<ReportProblemCubit>().loadReasons,
                    ),
                  ],
                  ReportProblemReady() => _form(context, c, state, work),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _form(
    BuildContext context,
    AppColors c,
    ReportProblemReady state,
    CurrentWork work,
  ) {
    final ReportProblemCubit cubit = context.read<ReportProblemCubit>();
    final bool canSend = state.selected != null && !state.isSubmitting;
    final bool pickedUp = !work.awaitingPickup;
    return <Widget>[
      for (final ProblemReason reason in state.reasons)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(reason.label),
          selected: reason == state.selected,
          trailing: reason == state.selected
              ? Icon(Icons.check_circle_rounded, color: c.secondary)
              : null,
          onTap: state.isSubmitting ? null : () => cubit.select(reason),
        ),
      SizedBox(height: AppSpacing.sm.h),
      MyTextFormField(
        controller: _note,
        hintText: Strings.orderReportProblemNoteHint,
        minLines: 2,
        maxLines: 4,
        readOnly: state.isSubmitting,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(_maxNoteLength),
        ],
      ),
      if (state.noteTooShort) ...<Widget>[
        SizedBox(height: AppSpacing.sm.h),
        Text(
          Strings.orderGiveUpNoteTooShort(giveUpNoteMinLength),
          style: AppTextStyles.body(color: c.error),
        ),
      ],
      if (state.submitError case final String error) ...<Widget>[
        SizedBox(height: AppSpacing.sm.h),
        Text(error, style: AppTextStyles.body(color: c.error)),
      ],
      SizedBox(height: AppSpacing.md.h),
      AppButton(
        btnText: Strings.orderReportProblemSubmit,
        isLoading: state.inFlight == ProblemAction.report,
        onPressed: canSend
            ? () => cubit.submit(orderId: work.orderId, note: _note.text)
            : null,
      ),
      SizedBox(height: AppSpacing.md.h),
      // Giving up needs a real explanation: the button stays off until the
      // note is long enough, and the counter says how far off it is.
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: _note,
        builder: (BuildContext context, TextEditingValue value, _) {
          final int length = value.text.trim().length;
          final bool longEnough = isGiveUpNoteLongEnough(value.text);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    longEnough
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    size: 16.r,
                    color: longEnough ? c.success : c.error,
                  ),
                  SizedBox(width: AppSpacing.xxs.w),
                  Expanded(
                    child: Text(
                      Strings.orderGiveUpNoteHint(giveUpNoteMinLength),
                      style: AppTextStyles.caption(
                        color: longEnough ? c.success : c.error,
                      ),
                    ),
                  ),
                  Text(
                    '${length > giveUpNoteMinLength ? giveUpNoteMinLength : length}/$giveUpNoteMinLength',
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.caption(
                      color: longEnough ? c.success : c.error,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs.h),
              AppOutlinedButton(
                text: pickedUp
                    ? Strings.orderFailDeliveryButton
                    : Strings.orderReleaseButton,
                textColor: c.error,
                borderColor: c.error,
                onPressed: canSend && longEnough
                    ? () => _giveUp(context, work)
                    : null,
              ),
            ],
          );
        },
      ),
    ];
  }
}
