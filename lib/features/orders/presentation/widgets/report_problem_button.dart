import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/current_work.dart';
import 'report_problem_sheet.dart';

/// "Report a problem", pinned under every delivery step by
/// [CurrentWorkView]: the Driver's way to tell support, or to give the order
/// up, at any point between accepting and completing it.
class ReportProblemButton extends StatelessWidget {
  final CurrentWork work;

  const ReportProblemButton({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return SizedBox(
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: () => showReportProblemSheet(context, work: work),
        icon: Icon(Icons.report_problem_rounded, size: 22.r, color: c.warning),
        label: Text(
          Strings.orderReportProblemButton,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.button(color: c.textPrimary),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          backgroundColor: c.warningLight,
          side: BorderSide(color: c.warning, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
          ),
        ),
      ),
    );
  }
}
