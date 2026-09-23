import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Empty state for when `current-work` returns no active order.
class NoActiveWorkView extends StatelessWidget {
  const NoActiveWorkView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.receipt_long_outlined, size: 64.r, color: c.textHint),
          SizedBox(height: AppSpacing.md.h),
          Text(
            Strings.orderNoActiveWork,
            textAlign: TextAlign.center,
            style: AppTextStyles.title(color: c.textPrimary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            Strings.orderNoActiveWorkSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
