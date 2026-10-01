import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/problem_report.dart';
import '../cubit/report_problem_cubit.dart';
import '../cubit/report_problem_state.dart';

/// PLACEHOLDER until the Figma flow lands: proves the report-a-problem API
/// end to end — loads the reasons, sends the picked one with a fixed test
/// note. Replace this sheet's body; keep [ReportProblemCubit].
Future<void> showReportProblemSheet(
  BuildContext context, {
  required int orderId,
}) async {
  final ProblemReport? report = await showModalBottomSheet<ProblemReport>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider<ReportProblemCubit>(
      create: (_) =>
          ServiceLocator.instance<ReportProblemCubit>()..loadReasons(),
      child: _ReportProblemSheet(orderId: orderId),
    ),
  );
  // A report never changes the order (`next_action: continue_order`), so the
  // Driver just stays on this step.
  if (report != null && context.mounted) {
    showAppSnackBar(
      context: context,
      message: Strings.orderReportProblemSent,
      type: ToastType.success,
    );
  }
}

class _ReportProblemSheet extends StatelessWidget {
  final int orderId;

  /// Fixed until the designed flow adds a note field.
  static const String _placeholderNote =
      'Test report from the driver app (placeholder UI)';

  const _ReportProblemSheet({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocConsumer<ReportProblemCubit, ReportProblemState>(
      listener: (BuildContext context, ReportProblemState state) {
        if (state case ReportProblemSent(:final ProblemReport report)) {
          Navigator.of(context).pop(report);
        }
      },
      builder: (BuildContext context, ReportProblemState state) => SafeArea(
        child: Padding(
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
                ReportProblemLoading() || ReportProblemSent() => <Widget>[
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
    );
  }

  List<Widget> _form(
    BuildContext context,
    AppColors c,
    ReportProblemReady state,
  ) {
    final ReportProblemCubit cubit = context.read<ReportProblemCubit>();
    return <Widget>[
      for (final ProblemReason reason in state.reasons)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(reason.label),
          selected: reason == state.selected,
          trailing: reason == state.selected
              ? Icon(Icons.check_circle_rounded, color: c.secondary)
              : null,
          onTap: () => cubit.select(reason),
        ),
      if (state.submitError case final String error) ...<Widget>[
        SizedBox(height: AppSpacing.sm.h),
        Text(error, style: AppTextStyles.body(color: c.error)),
      ],
      SizedBox(height: AppSpacing.md.h),
      AppButton(
        btnText: Strings.orderReportProblemSubmit,
        isLoading: state.isSubmitting,
        onPressed: state.selected == null
            ? null
            : () => cubit.submit(orderId: orderId, note: _placeholderNote),
      ),
    ];
  }
}
