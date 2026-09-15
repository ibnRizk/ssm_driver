import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Dark navy COD callout on the trip screen — label + cash note on the
/// right, the large orange amount on the left.
class TripCodSummary extends StatelessWidget {
  final String label;
  final String cashNote;
  final String amount;

  const TripCodSummary({
    super.key,
    required this.label,
    required this.cashNote,
    required this.amount,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: AppTextStyles.titleSmall(color: Colors.white),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  cashNote,
                  style: AppTextStyles.caption(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Text(amount, style: AppTextStyles.h1(color: c.secondary)),
        ],
      ),
    );
  }
}
