import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Pastel-green banner explaining the order was auto-assigned by the
/// system rather than manually picked — sits right under the header.
class OrderAssignmentBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const OrderAssignmentBanner({
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
      decoration: BoxDecoration(
        color: c.successLight,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTextStyles.titleSmall(color: c.success),
          ),
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            subtitle,
            style: AppTextStyles.caption(color: c.success),
          ),
        ],
      ),
    );
  }
}
