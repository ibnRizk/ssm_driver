import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// One end of a [RouteStopsCard].
class RouteStopData {
  final IconData icon;
  final String label;
  final String title;

  /// Shown under [title] when not empty.
  final String subtitle;

  const RouteStopData({
    required this.icon,
    required this.label,
    required this.title,
    this.subtitle = '',
  });
}

/// Pickup and drop-off as two stops joined by a line — the route summary
/// on the offer sheets.
class RouteStopsCard extends StatelessWidget {
  final RouteStopData pickup;
  final RouteStopData dropoff;

  const RouteStopsCard({
    super.key,
    required this.pickup,
    required this.dropoff,
  });

  static const double _iconBox = 36;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm.r),
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Column(
        children: <Widget>[
          _RouteStop(
            stop: pickup,
            color: c.secondary,
            background: c.secondaryLight,
          ),
          // The line joining the two stops, centred under their icons.
          Padding(
            padding: EdgeInsetsDirectional.only(start: (_iconBox / 2 - 1).r),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                width: 2,
                height: AppSpacing.md.h,
                color: c.border,
              ),
            ),
          ),
          _RouteStop(
            stop: dropoff,
            color: c.primary,
            background: c.primaryLight,
          ),
        ],
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  final RouteStopData stop;
  final Color color;
  final Color background;

  const _RouteStop({
    required this.stop,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: RouteStopsCard._iconBox.r,
          height: RouteStopsCard._iconBox.r,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(stop.icon, color: color, size: 20.r),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                stop.label,
                style: AppTextStyles.caption(color: c.textSecondary),
              ),
              Text(
                stop.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleSmall(color: c.textPrimary),
              ),
              if (stop.subtitle.isNotEmpty)
                Text(
                  stop.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(color: c.textHint),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
