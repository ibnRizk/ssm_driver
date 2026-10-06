import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/current_work.dart';
import 'report_problem_sheet.dart';

/// "Report a problem", under the main action of every delivery step: the
/// Driver's way to tell support, or to give the order up, at any point
/// between accepting and completing it.
class ReportProblemButton extends StatelessWidget {
  final CurrentWork work;

  const ReportProblemButton({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xs.h),
      child: TextButton(
        onPressed: () => showReportProblemSheet(context, work: work),
        child: Text(
          Strings.orderReportProblemButton,
          style: AppTextStyles.body(color: context.colors.textHint),
        ),
      ),
    );
  }
}
