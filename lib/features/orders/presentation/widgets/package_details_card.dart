import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// White card summarizing the physical package(s) being picked up — an
/// outline box icon, a bold title, and an items subtitle.
class PackageDetailsCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const PackageDetailsCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: AppDecorations.card(c),
      child: Row(
        children: <Widget>[
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: c.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.inventory_2_outlined,
              color: c.secondary,
              size: 22.r,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTextStyles.title(color: c.textPrimary)),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
