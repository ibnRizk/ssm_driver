import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Navy hero card showing today's completed-deliveries count, with the
/// brand-orange organic wave bleeding off the bottom-left corner (same
/// pattern as `ParcelsSummaryCard` / `ParcelDetailsStatusCard`).
class EarningsHeroCard extends StatelessWidget {
  final int deliveriesCount;
  final String progressLabel;

  const EarningsHeroCard({
    super.key,
    required this.deliveriesCount,
    required this.progressLabel,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        color: c.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
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
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'عدد التوصيلات المكتملة اليوم',
                      style: AppTextStyles.caption(color: Colors.white),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    Text(
                      '$deliveriesCount',
                      style: AppTextStyles.display(
                        color: Colors.white,
                      ).copyWith(fontSize: 48.sp),
                    ),
                    Text(
                      'توصيلات',
                      style: AppTextStyles.title(color: c.secondary),
                    ),
                  ],
                ),
                Text(
                  progressLabel,
                  style: AppTextStyles.titleSmall(color: c.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
