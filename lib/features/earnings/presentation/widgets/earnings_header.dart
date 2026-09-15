import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Earnings screen header — a centered title with a pastel date pill.
///
/// This is a root tab body (`MainScaffold` owns the bottom nav), so unlike
/// `ParcelDetailsHeader` there is no back button here.
class EarningsHeader extends StatelessWidget {
  final String date;

  const EarningsHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Text(
              'الأرباح',
              style: AppTextStyles.h1(color: c.primary),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: c.secondaryLight,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            date,
            style: AppTextStyles.label(color: c.secondary),
          ),
        ),
      ],
    );
  }
}
