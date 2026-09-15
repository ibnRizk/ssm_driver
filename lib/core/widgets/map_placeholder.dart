import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Visual stand-in for a map — no real map integration yet. Used on every
/// route/navigation screen (navigate-to-store, delivery-to-customer); pulled
/// into `core/` once the second screen needed the exact same shape, per the
/// project's "2+ places" rule for shared widgets (see `TintedNote`).
class MapPlaceholder extends StatelessWidget {
  final String? label;
  final double height;

  const MapPlaceholder({super.key, this.label, this.height = 220});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      height: height.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EDE9),
        borderRadius: BorderRadius.circular(AppRadius.xl.r),
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: Icon(
              Icons.map_outlined,
              size: 40.r,
              color: c.textHint,
            ),
          ),
          if (label != null)
            Positioned.directional(
              textDirection: Directionality.of(context),
              top: AppSpacing.sm.h,
              start: AppSpacing.sm.w,
              child: Text(
                label!,
                style: AppTextStyles.caption(color: c.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
