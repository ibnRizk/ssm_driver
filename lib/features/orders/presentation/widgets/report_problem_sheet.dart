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

/// Asks before an order is given up — it can't be taken back.
Future<bool> _confirmGiveUp(
  BuildContext context, {
  required bool pickedUp,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
        pickedUp
            ? Strings.orderFailDeliveryConfirmTitle
            : Strings.orderReleaseConfirmTitle,
      ),
      content: Text(
        pickedUp
            ? Strings.orderFailDeliveryConfirmBody
            : Strings.orderReleaseConfirmBody,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(Strings.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            pickedUp
                ? Strings.orderFailDeliveryButton
                : Strings.orderReleaseButton,
            style: TextStyle(color: context.colors.error),
          ),
        ),
      ],
    ),
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

  Future<void> _giveUp(BuildContext context) async {
    final ReportProblemCubit cubit = context.read<ReportProblemCubit>();
    final bool confirmed = await _confirmGiveUp(
      context,
      pickedUp: !widget.work.awaitingPickup,
    );
    if (!confirmed) return;
    await cubit.giveUp(work: widget.work, note: _note.text);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocConsumer<ReportProblemCubit, ReportProblemState>(
      listener: (BuildContext context, ReportProblemState state) {
        if (state is ReportProblemSent || state is ReportProblemGaveUp) {
          Navigator.of(context).pop(state);
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
                  ReportProblemReady() => _form(context, c, state),
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
  ) {
    final ReportProblemCubit cubit = context.read<ReportProblemCubit>();
    final bool canSend = state.selected != null && !state.isSubmitting;
    final bool pickedUp = !widget.work.awaitingPickup;
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
      if (state.submitError case final String error) ...<Widget>[
        SizedBox(height: AppSpacing.sm.h),
        Text(error, style: AppTextStyles.body(color: c.error)),
      ],
      SizedBox(height: AppSpacing.md.h),
      AppButton(
        btnText: Strings.orderReportProblemSubmit,
        isLoading: state.inFlight == ProblemAction.report,
        onPressed: canSend
            ? () => cubit.submit(orderId: widget.work.orderId, note: _note.text)
            : null,
      ),
      SizedBox(height: AppSpacing.sm.h),
      AppOutlinedButton(
        text: pickedUp
            ? Strings.orderFailDeliveryButton
            : Strings.orderReleaseButton,
        textColor: c.error,
        borderColor: c.error,
        onPressed: canSend ? () => _giveUp(context) : null,
      ),
    ];
  }
}
