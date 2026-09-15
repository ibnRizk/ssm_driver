import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Compact navy store header for the pickup-confirmation screen — the food
/// icon, store name/district, and the order id inline on the far side (no
/// wave motif, unlike `StoreLocationCard`).
class PickupStoreCard extends StatelessWidget {
  final String storeName;
  final String storeDistrict;
  final String orderId;

  const PickupStoreCard({
    super.key,
    required this.storeName,
    required this.storeDistrict,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: c.secondary,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.fastfood_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.r,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  storeName,
                  style: AppTextStyles.title(color: Theme.of(context).colorScheme.onPrimary),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  storeDistrict,
                  style: AppTextStyles.caption(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Text(
            orderId,
            style: AppTextStyles.caption(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
