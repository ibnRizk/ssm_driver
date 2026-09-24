import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/values/strings.dart';

/// "Cash to collect" strip for cash-on-delivery orders and parcels.
class CodCashBanner extends StatelessWidget {
  /// Display text as the server sent it, e.g. "31.00 SAR".
  final String amount;

  const CodCashBanner({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
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
              Strings.orderCodCashLabel,
              style: AppTextStyles.body(color: c.secondaryDark),
            ),
          ),
          Text(amount, style: AppTextStyles.h1(color: c.primary)),
        ],
      ),
    );
  }
}
