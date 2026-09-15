import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Plain white stat tile for the navigate-to-store screen's distance/time
/// row — a gray label over a bold navy value, no accent colour.
class RouteStatCard extends StatelessWidget {
  final String label;
  final String value;

  const RouteStatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: AppDecorations.card(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.caption(color: c.textSecondary)),
          SizedBox(height: AppSpacing.xxs.h),
          Text(value, style: AppTextStyles.title(color: c.primary)),
        ],
      ),
    );
  }
}
