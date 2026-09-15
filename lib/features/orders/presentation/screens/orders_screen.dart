import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../config/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(
          Strings.navOrders,
          style: AppTextStyles.h2(color: c.textPrimary),
        ),
        backgroundColor: c.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.screen.w),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            SizedBox(height: AppSpacing.md.h),
        itemBuilder: (BuildContext context, int index) {
          final bool isDelivered = index % 2 == 0;
          return _OrderCard(
            orderId: 'SSM-104${8 + index}#',
            date: '12 أكتوبر 2026',
            status: isDelivered ? 'تم التوصيل' : 'ملغي',
            isDelivered: isDelivered,
            storeName: 'مطاعم مذاق',
            earnings: '15 ر.س',
            onTap: () {
              context.pushNamed(AppRoutes.orderTripName);
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String date;
  final String status;
  final bool isDelivered;
  final String storeName;
  final String earnings;
  final VoidCallback? onTap;

  const _OrderCard({
    required this.orderId,
    required this.date,
    required this.status,
    required this.isDelivered,
    required this.storeName,
    required this.earnings,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

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
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  orderId,
                  style: AppTextStyles.title(
                    color: c.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm.w,
                    vertical: AppSpacing.xxs.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDelivered
                        ? c.secondaryLight
                        : c.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppRadius.pill,
                    ),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.label(
                      color: isDelivered
                          ? c.secondaryDark
                          : c.error,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm.h),
            Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.r,
                  color: c.textHint,
                ),
                SizedBox(width: AppSpacing.xs.w),
                Text(
                  date,
                  style: AppTextStyles.body(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs.h),
            Row(
              children: <Widget>[
                Icon(
                  Icons.storefront_outlined,
                  size: 16.r,
                  color: c.textHint,
                ),
                SizedBox(width: AppSpacing.xs.w),
                Text(
                  storeName,
                  style: AppTextStyles.body(
                    color: c.textSecondary,
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
                  'الأرباح',
                  style: AppTextStyles.body(
                    color: c.textSecondary,
                  ),
                ),
                Text(
                  earnings,
                  style: AppTextStyles.title(
                    color: c.primary,
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
