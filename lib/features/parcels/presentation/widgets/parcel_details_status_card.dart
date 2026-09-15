import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class ParcelDetailsStatusCard extends StatelessWidget {
  const ParcelDetailsStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        color: c.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          // Left side organic wave
          Positioned(
            left: -30.w,
            bottom: -50.h,
            child: Container(
              width: 160.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: c.secondary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80.r),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // RTL -> Right aligned
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'حالة الشحنة',
                  style: AppTextStyles.caption(color: Colors.white70),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  'قيد التوصيل',
                  style: AppTextStyles.h1(color: Colors.white).copyWith(fontSize: 28.sp),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  'من مستودع SSM إلى العميل',
                  style: AppTextStyles.title(color: c.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
