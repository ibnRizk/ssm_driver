import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

/// Earnings screen header — a centered title.
///
/// This is a root tab body (`MainScaffold` owns the bottom nav), so unlike
/// `ParcelDetailsHeader` there is no back button here. No date pill: the
/// API's summaries are running totals, not figures for one day.
class EarningsHeader extends StatelessWidget {
  const EarningsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Center(
      child: Text(
        Strings.navEarnings,
        style: AppTextStyles.h1(color: c.primary),
      ),
    );
  }
}
