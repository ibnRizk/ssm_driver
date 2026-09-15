import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class ParcelRouteCard extends StatelessWidget {
  final String orderId;
  final String customerDetails;
  final String phone;
  final String station;
  final String status;
  final VoidCallback? onTap;

  const ParcelRouteCard({
    super.key,
    required this.orderId,
    required this.customerDetails,
    required this.phone,
    required this.station,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool isInDelivery = status == 'قيد التوصيل';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(
            AppRadius.lg.r,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Palette.shadowHairline,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: c.secondaryLight,
                    borderRadius: BorderRadius.circular(
                      AppRadius.sm.r,
                    ),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: c.secondary,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        orderId,
                        style: AppTextStyles.title(
                          color: c.primaryDark,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs.h),
                      Text(
                        customerDetails,
                        style: AppTextStyles.caption(
                          color: c.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm.w,
                    vertical: AppSpacing.xxs.h,
                  ),
                  decoration: BoxDecoration(
                    color: isInDelivery
                        ? c.successLight
                        : c.secondaryLight,
                    borderRadius: BorderRadius.circular(
                      AppRadius.pill,
                    ),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.label(
                      color: isInDelivery
                          ? c.success
                          : c.secondaryDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            Divider(color: c.border, height: 1),
            SizedBox(height: AppSpacing.md.h),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  station,
                  style: AppTextStyles.title(
                    color: c.primaryDark,
                  ),
                ),
                Text(
                  phone,
                  style: AppTextStyles.body(
                    color: c.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
