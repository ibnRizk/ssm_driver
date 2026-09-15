import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class ParcelsSummaryCard extends StatelessWidget {
  const ParcelsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: c.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          // Left side organic wave (simulated)
          Positioned(
            left: -40.w,
            bottom: -60.h,
            child: Container(
              width: 180.w,
              height: 160.h,
              decoration: BoxDecoration(
                color: c.secondary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80.r),
                  bottomRight: Radius.circular(80.r),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'جولة مستودع SSM',
                        style: AppTextStyles.h2(color: Colors.white),
                      ),
                      SizedBox(height: AppSpacing.xxs.h),
                      Text(
                        'تربة • جاهز للبدء',
                        style: AppTextStyles.body(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '4',
                      style: AppTextStyles.h1(color: c.accent).copyWith(fontSize: 32.sp),
                    ),
                    Text(
                      'طرود اليوم',
                      style: AppTextStyles.caption(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
