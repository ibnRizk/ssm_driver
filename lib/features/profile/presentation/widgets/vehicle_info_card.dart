import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_base/core/utils/values/strings.dart';

/// White card summarizing the driver's assigned vehicle, with a verified
/// pill on the trailing edge.
class VehicleInfoCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool isVerified;

  const VehicleInfoCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.isVerified = true,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: AppDecorations.card(c),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: c.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
            ),
            child: Icon(Icons.bolt_rounded, color: c.secondary, size: 24.r),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: AppTextStyles.title(color: c.primaryDark)),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
              ],
            ),
          ),
          if (isVerified)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm.w,
                vertical: AppSpacing.xxs.h,
              ),
              decoration: BoxDecoration(
                color: c.successLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                Strings.profileVerified,
                style: AppTextStyles.label(color: c.success),
              ),
            ),
        ],
      ),
    );
  }
}
