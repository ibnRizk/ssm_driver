import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/values/strings.dart';

class ProofOfDeliveryStatusCard extends StatelessWidget {
  /// What to collect — "Cash to collect: 31 SAR", or "Prepaid".
  final String subtitle;

  /// Defaults to "Order Ready for Delivery"; parcels pass their own.
  final String? title;

  const ProofOfDeliveryStatusCard({
    super.key,
    required this.subtitle,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: c.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title ?? Strings.orderReadyForDelivery,
                  style: AppTextStyles.h2(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  subtitle,
                  style: AppTextStyles.body(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: c.secondary,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
            child: Icon(
              Icons.check_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28.r,
            ),
          ),
        ],
      ),
    );
  }
}
