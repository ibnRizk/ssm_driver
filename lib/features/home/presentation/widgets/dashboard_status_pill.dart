import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Full-width pastel-green pill showing the driver's online/availability
/// status — a solid dot plus a short status line, both centered.
class DashboardStatusPill extends StatelessWidget {
  final String label;

  const DashboardStatusPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
      decoration: BoxDecoration(
        color: c.successLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: c.success,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          Text(
            label,
            style: AppTextStyles.titleSmall(color: c.success),
          ),
        ],
      ),
    );
  }
}
