import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'app_button.dart';

/// The Google-Maps/Call button pair shared by the order and parcel
/// screens — Maps leads (right, solid orange), Call
/// trails (left, solid navy). Widths are proportional via [mapsFlex]/
/// [callFlex] since the two screens use different ratios.
class MapsCallButtons extends StatelessWidget {
  final String mapsLabel;
  final String callLabel;
  final VoidCallback? onMapsTap;
  final VoidCallback? onCallTap;
  final int mapsFlex;
  final int callFlex;

  const MapsCallButtons({
    super.key,
    required this.mapsLabel,
    required this.callLabel,
    required this.onMapsTap,
    required this.onCallTap,
    this.mapsFlex = 1,
    this.callFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        Expanded(
          flex: mapsFlex,
          child: AppButton(
            btnText: mapsLabel,
            icon: Icons.open_in_new_rounded,
            onPressed: onMapsTap,
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          flex: callFlex,
          child: AppButton(
            btnText: callLabel,
            icon: Icons.call_outlined,
            color: c.primary,
            onPressed: onCallTap,
          ),
        ),
      ],
    );
  }
}
