import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One tile of the 2x2 dashboard grid — a gray label over a large bold
/// value, optionally led by an icon (the rating star).
class DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color background;
  final Color valueColor;
  final IconData? icon;

  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.background,
    required this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: AppDecorations.card(c, color: background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.caption(color: c.textSecondary),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, color: valueColor, size: 20.r),
                SizedBox(width: AppSpacing.xxs.w),
              ],
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.h1(color: valueColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
