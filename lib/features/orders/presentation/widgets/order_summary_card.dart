import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The white detail card: order id/distance/eta, the restaurant, the
/// destination and contents rows, and the COD highlight — everything
/// between the assignment banner and the accept/reject buttons.
class OrderSummaryCard extends StatelessWidget {
  final String orderId;
  final String distance;
  final String eta;
  final String restaurantInitial;
  final String restaurantName;
  final String restaurantDistrict;
  final String destinationLabel;
  final String destinationValue;
  final String contentsLabel;
  final String contentsValue;
  final String codLabel;
  final String codAmount;

  const OrderSummaryCard({
    super.key,
    required this.orderId,
    required this.distance,
    required this.eta,
    required this.restaurantInitial,
    required this.restaurantName,
    required this.restaurantDistrict,
    required this.destinationLabel,
    required this.destinationValue,
    required this.contentsLabel,
    required this.contentsValue,
    required this.codLabel,
    required this.codAmount,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: AppDecorations.card(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(orderId, style: AppTextStyles.title(color: c.primary)),
              Text(
                distance,
                style: AppTextStyles.title(color: c.secondary),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxs.h),
          Text(eta, style: AppTextStyles.caption(color: c.textSecondary)),
          SizedBox(height: AppSpacing.md.h),
          const Divider(),
          SizedBox(height: AppSpacing.md.h),
          Row(
            children: <Widget>[
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  restaurantInitial,
                  style: AppTextStyles.title(color: Colors.white),
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      restaurantName,
                      style: AppTextStyles.title(color: c.textPrimary),
                    ),
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      restaurantDistrict,
                      style: AppTextStyles.caption(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          const Divider(),
          SizedBox(height: AppSpacing.md.h),
          _DetailRow(label: destinationLabel, value: destinationValue),
          SizedBox(height: AppSpacing.md.h),
          const Divider(),
          SizedBox(height: AppSpacing.md.h),
          _DetailRow(label: contentsLabel, value: contentsValue),
          SizedBox(height: AppSpacing.md.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md.w,
              vertical: AppSpacing.sm.h,
            ),
            decoration: BoxDecoration(
              color: c.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    codLabel,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
                ),
                Text(
                  codAmount,
                  style: AppTextStyles.h1(color: c.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: AppTextStyles.body(color: c.textSecondary)),
        Text(value, style: AppTextStyles.titleSmall(color: c.textPrimary)),
      ],
    );
  }
}
