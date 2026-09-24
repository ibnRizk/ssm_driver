import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

class ParcelsSummaryCard extends StatelessWidget {
  final int totalCount;

  /// Parcels already out for delivery — the round has started.
  final int inDeliveryCount;

  const ParcelsSummaryCard({
    super.key,
    required this.totalCount,
    required this.inDeliveryCount,
  });

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
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: -40.w,
            bottom: -60.h,
            child: Container(
              width: 180.w,
              height: 160.h,
              decoration: BoxDecoration(
                color: c.secondary,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(80.r),
                  bottomStart: Radius.circular(80.r),
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
                        Strings.parcelTourTitle,
                        style: AppTextStyles.h2(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      SizedBox(height: AppSpacing.xxs.h),
                      Text(
                        inDeliveryCount > 0
                            ? Strings.parcelTourInProgress(inDeliveryCount)
                            : Strings.parcelTourStatus,
                        style: AppTextStyles.body(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$totalCount',
                      style: AppTextStyles.h1(color: c.accent).copyWith(fontSize: 32.sp),
                    ),
                    Text(
                      Strings.parcelsTodayTitle,
                      style: AppTextStyles.caption(color: Theme.of(context).colorScheme.onPrimary),
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
