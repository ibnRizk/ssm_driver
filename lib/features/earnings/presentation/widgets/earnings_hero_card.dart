import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

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
      constraints: BoxConstraints(minHeight: 150.h),
      decoration: BoxDecoration(
        color: c.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
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
                      Strings.earningsCompletedTripsToday,
                      style: AppTextStyles.caption(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    Text(
                      '$deliveriesCount',
                      style: AppTextStyles.display(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ).copyWith(fontSize: 48.sp),
                    ),
                    Text(
                      Strings.earningsTripsLabel,
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
