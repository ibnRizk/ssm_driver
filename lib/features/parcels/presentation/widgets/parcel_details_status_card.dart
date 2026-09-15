import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_base/core/utils/values/strings.dart';

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
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: -30.w,
            bottom: -50.h,
            child: Container(
              width: 160.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: c.secondary,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(80.r),
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
                  Strings.parcelStatusLabel,
                  style: AppTextStyles.caption(color: Colors.white70),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  Strings.parcelStatusInDelivery,
                  style: AppTextStyles.h1(color: Colors.white).copyWith(fontSize: 28.sp),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  Strings.parcelStatusDescription,
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
