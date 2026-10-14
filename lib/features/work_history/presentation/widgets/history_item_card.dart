import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One order or parcel in the history list.
class HistoryItemCard extends StatelessWidget {
  final IconData icon;
  final String title;

  /// Where it went; hidden when empty.
  final String route;
  final String status;

  /// Settled jobs get a muted status chip.
  final bool isFinal;

  /// Payment for an order, what is sent for a parcel; may be empty.
  final String detail;
  final String? date;

  /// `null` when the item can't be opened.
  final VoidCallback? onTap;

  const HistoryItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    required this.status,
    required this.isFinal,
    required this.detail,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? when = date;

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(AppRadius.md.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 24.r, color: c.secondary),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.title(color: c.primaryDark),
                          ),
                        ),
                        _StatusChip(label: status, isFinal: isFinal),
                      ],
                    ),
                    if (route.isNotEmpty) ...<Widget>[
                      SizedBox(height: AppSpacing.xxs.h),
                      Text(
                        route,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(color: c.textSecondary),
                      ),
                    ],
                    SizedBox(height: AppSpacing.xs.h),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            detail,
                            style: AppTextStyles.caption(color: c.textPrimary),
                          ),
                        ),
                        if (when != null)
                          Text(
                            when,
                            style: AppTextStyles.caption(color: c.textHint),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isFinal;

  const _StatusChip({required this.label, required this.isFinal});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: isFinal ? c.background : c.secondaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(
          color: isFinal ? c.textSecondary : c.secondaryDark,
        ),
      ),
    );
  }
}
