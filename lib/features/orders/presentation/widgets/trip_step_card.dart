import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One step of the trip (pickup or delivery): an icon, a name, one or two
/// lines of detail, and a small action pill (map / call) on the far side.
class TripStepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> subtitleLines;
  final IconData actionIcon;
  final String actionLabel;
  final VoidCallback? onActionTap;

  const TripStepCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitleLines,
    required this.actionIcon,
    required this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: AppDecorations.card(c),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: c.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: c.secondary, size: 22.r),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTextStyles.title(color: c.textPrimary)),
                for (final String line in subtitleLines) ...<Widget>[
                  SizedBox(height: AppSpacing.xxs.h),
                  Text(
                    line,
                    style: AppTextStyles.caption(color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          _ActionPill(icon: actionIcon, label: actionLabel, onTap: onActionTap),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionPill({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Material(
      color: c.secondaryLight,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xs.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: c.secondary, size: 18.r),
              SizedBox(height: AppSpacing.xxs.h),
              Text(label, style: AppTextStyles.label(color: c.secondary)),
            ],
          ),
        ),
      ),
    );
  }
}
