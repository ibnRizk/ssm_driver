import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_wave.dart';

/// Dark navy hero card for the store's pickup location — the same
/// orange-wave motif used on the splash and parcel-arrival screens, clipped
/// to this card's rounded corners.
class StoreLocationCard extends StatelessWidget {
  final String storeName;
  final String pickupPointLabel;
  final String address;

  const StoreLocationCard({
    super.key,
    required this.storeName,
    required this.pickupPointLabel,
    required this.address,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          color: c.secondary,
                          borderRadius: BorderRadius.circular(
                            AppRadius.md.r,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 22.r,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              storeName,
                              style: AppTextStyles.title(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xxs.h),
                            Text(
                              pickupPointLabel,
                              style: AppTextStyles.caption(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    address,
                    style: AppTextStyles.body(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
