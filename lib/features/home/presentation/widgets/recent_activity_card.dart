import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Dark navy card for the "Recent activity" section — an orange icon chip,
/// a title/subtitle pair, and a round chevron button that opens the detail.
class RecentActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const RecentActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Material(
      color: c.primary,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md.r),
          child: Row(
            children: <Widget>[
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: c.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 24.r,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTextStyles.titleSmall(color: Colors.white),
                    ),
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Container(
                width: 32.r,
                height: 32.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: c.primary,
                  size: 20.r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
