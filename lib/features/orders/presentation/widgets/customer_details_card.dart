import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// White card introducing the delivery recipient — initial-letter avatar,
/// name/address, and a call icon button on the far side.
class CustomerDetailsCard extends StatelessWidget {
  final String initial;
  final String name;
  final String address;
  final VoidCallback? onCallTap;

  const CustomerDetailsCard({
    super.key,
    required this.initial,
    required this.name,
    required this.address,
    this.onCallTap,
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
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: c.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
            ),
            alignment: Alignment.center,
            child: Text(initial, style: AppTextStyles.h1(color: c.primary)),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: AppTextStyles.title(color: c.textPrimary)),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  address,
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Material(
            color: c.successLight,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md.r),
              onTap: onCallTap,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm.r),
                child: Icon(Icons.call_outlined, color: c.success, size: 20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
