import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// White card showing progress toward the next delivery incentive: a
/// remaining-count / percentage row, a linear progress bar, then a short
/// explanatory caption.
class EarningsProgressCard extends StatelessWidget {
  final String remainingLabel;
  final double progress;
  final String description;

  const EarningsProgressCard({
    super.key,
    required this.remainingLabel,
    required this.progress,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: AppDecorations.card(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                remainingLabel,
                style: AppTextStyles.title(color: c.primaryDark),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.title(color: c.secondary),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              color: c.secondary,
              backgroundColor: c.border,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            description,
            style: AppTextStyles.caption(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
