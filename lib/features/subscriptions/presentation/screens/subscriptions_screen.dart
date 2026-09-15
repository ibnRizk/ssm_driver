import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(Strings.navSubscriptions, style: AppTextStyles.h2(color: c.textPrimary)),
        backgroundColor: c.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.screen.w),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md.h),
        itemBuilder: (BuildContext context, int index) {
          final bool isActive = index == 0;
          return _SubscriptionCard(
            title: 'اشتراك أسبوعي - فرع الملك فهد',
            period: '15 أكتوبر - 21 أكتوبر 2026',
            status: isActive ? 'نشط' : (index == 1 ? 'مجدول' : 'منتهي'),
            guarantee: '1200 ر.س',
            hours: '40 ساعة',
            isActive: isActive,
            isScheduled: index == 1,
          );
        },
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final String title;
  final String period;
  final String status;
  final String guarantee;
  final String hours;
  final bool isActive;
  final bool isScheduled;

  const _SubscriptionCard({
    required this.title,
    required this.period,
    required this.status,
    required this.guarantee,
    required this.hours,
    required this.isActive,
    required this.isScheduled,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(color: isActive ? c.primary : c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.title(color: c.textPrimary),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w,
                  vertical: AppSpacing.xxs.h,
                ),
                decoration: BoxDecoration(
                  color: isActive ? c.secondaryLight : (isScheduled ? c.primary.withOpacity(0.1) : c.surface),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: isScheduled ? c.primary : Colors.transparent),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.label(
                    color: isActive ? c.secondaryDark : (isScheduled ? c.primary : c.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: <Widget>[
              Icon(Icons.date_range_outlined, size: 16.r, color: c.textHint),
              SizedBox(width: AppSpacing.xs.w),
              Text(period, style: AppTextStyles.body(color: c.textSecondary)),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('الحد الأدنى المضمون', style: AppTextStyles.caption(color: c.textHint)),
                    Text(guarantee, style: AppTextStyles.bodyLarge(color: c.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('ساعات العمل', style: AppTextStyles.caption(color: c.textHint)),
                    Text(hours, style: AppTextStyles.bodyLarge(color: c.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          if (isScheduled) ...<Widget>[
            SizedBox(height: AppSpacing.md.h),
            AppButton(
              btnText: 'تأكيد الحضور',
              onPressed: () {},
            ),
          ],
        ],
      ),
    );
  }
}
