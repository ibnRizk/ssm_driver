import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';

class ParcelsScreen extends StatelessWidget {
  const ParcelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(Strings.navParcels, style: AppTextStyles.h2(color: c.textPrimary)),
        backgroundColor: c.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.screen.w),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md.h),
        itemBuilder: (BuildContext context, int index) {
          final bool isActive = index == 0;
          return _ParcelBatchCard(
            batchId: 'BATCH-${1000 + index}',
            storeName: 'مستودع الأزياء الحديثة',
            totalStops: 4 + index,
            completedStops: isActive ? 1 : (index > 0 ? 4 + index : 0),
            earnings: '${35 + (index * 5)} ر.س',
            isActive: isActive,
          );
        },
      ),
    );
  }
}

class _ParcelBatchCard extends StatelessWidget {
  final String batchId;
  final String storeName;
  final int totalStops;
  final int completedStops;
  final String earnings;
  final bool isActive;

  const _ParcelBatchCard({
    required this.batchId,
    required this.storeName,
    required this.totalStops,
    required this.completedStops,
    required this.earnings,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double progress = totalStops > 0 ? completedStops / totalStops : 0;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: isActive ? c.primary.withOpacity(0.05) : c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(color: isActive ? c.primary : c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'شحنات متعددة',
                style: AppTextStyles.title(color: c.textPrimary),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w,
                  vertical: AppSpacing.xxs.h,
                ),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: c.border),
                ),
                child: Text(
                  batchId,
                  style: AppTextStyles.label(color: c.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: <Widget>[
              Icon(Icons.inventory_2_outlined, size: 16.r, color: c.textHint),
              SizedBox(width: AppSpacing.xs.w),
              Text(storeName, style: AppTextStyles.body(color: c.textSecondary)),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'النقاط المكتملة',
                style: AppTextStyles.caption(color: c.textHint),
              ),
              Text(
                '$completedStops / $totalStops',
                style: AppTextStyles.label(color: c.textPrimary),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: c.border,
            color: c.primary,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            minHeight: 6.h,
          ),
          SizedBox(height: AppSpacing.md.h),
          Divider(color: c.border, height: 1),
          SizedBox(height: AppSpacing.md.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'إجمالي العائد المتوقع',
                style: AppTextStyles.body(color: c.textSecondary),
              ),
              Text(
                earnings,
                style: AppTextStyles.title(color: c.primary),
              ),
            ],
          ),
          if (isActive) ...<Widget>[
            SizedBox(height: AppSpacing.md.h),
            AppButton(
              btnText: 'متابعة التوصيل',
              onPressed: () {
                // Navigate to active parcel batch
              },
            ),
          ],
        ],
      ),
    );
  }
}
