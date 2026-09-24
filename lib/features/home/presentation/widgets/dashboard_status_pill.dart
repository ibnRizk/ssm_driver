import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Full-width pill showing the driver's online/availability status — a
/// solid dot plus a short status line, both centered. Pastel green while
/// [isOnline], neutral gray otherwise.
class DashboardStatusPill extends StatelessWidget {
  final String label;
  final bool isOnline;

  const DashboardStatusPill({
    super.key,
    required this.label,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color foreground = isOnline ? c.success : c.textSecondary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
      decoration: BoxDecoration(
        color: isOnline ? c.successLight : c.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: isOnline ? null : Border.all(color: c.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          Text(label, style: AppTextStyles.titleSmall(color: foreground)),
        ],
      ),
    );
  }
}
