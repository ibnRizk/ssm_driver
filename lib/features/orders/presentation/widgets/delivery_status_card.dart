import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_wave.dart';

/// Dark navy hero card for the delivery-to-customer screen's status —
/// three stacked lines (context, headline, sub-status), with the same
/// orange-wave motif as `StoreLocationCard`.
class DeliveryStatusCard extends StatelessWidget {
  final String topLabel;
  final String headline;
  final String subtitle;

  const DeliveryStatusCard({
    super.key,
    required this.topLabel,
    required this.headline,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        color: c.primary,
        child: Stack(
          children: <Widget>[
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 0,
              end: 0,
              bottom: 0,
              height: 64.h,
              child: BrandWave(color: c.secondary.withValues(alpha: 0.9)),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    topLabel,
                    style: AppTextStyles.caption(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    headline,
                    style: AppTextStyles.h1(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(subtitle, style: AppTextStyles.caption(color: c.accent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
