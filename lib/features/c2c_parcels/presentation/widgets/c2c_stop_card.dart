import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/launch_url_method.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/maps_call_buttons.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../c2c_display.dart';

/// The sender's pickup point or the recipient's drop-off, with directions
/// and a call button. [isCurrentLeg] highlights where the Driver heads now.
class C2cStopCard extends StatelessWidget {
  final String title;
  final C2cStop stop;
  final String instructions;
  final bool isCurrentLeg;

  const C2cStopCard({
    super.key,
    required this.title,
    required this.stop,
    required this.instructions,
    required this.isCurrentLeg,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double? lat = stop.latitude;
    final double? lng = stop.longitude;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(
          color: isCurrentLeg ? c.secondary : c.border,
          width: isCurrentLeg ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: AppTextStyles.titleSmall(color: c.secondaryDark)),
          SizedBox(height: AppSpacing.xs.h),
          if (stop.name.isNotEmpty)
            Text(stop.name, style: AppTextStyles.title(color: c.primaryDark)),
          Text(
            stop.placeLabel,
            style: AppTextStyles.body(color: c.textSecondary),
          ),
          if (instructions.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSpacing.xs.h),
            Text(
              Strings.c2cInstructions(instructions),
              style: AppTextStyles.caption(color: c.textPrimary),
            ),
          ],
          SizedBox(height: AppSpacing.sm.h),
          MapsCallButtons(
            mapsLabel: Strings.parcelActionMaps,
            callLabel: Strings.parcelActionCall,
            onMapsTap: lat == null || lng == null
                ? null
                : () => openMapsDirections(
                    latitude: lat,
                    longitude: lng,
                    context: context,
                  ),
            onCallTap: stop.phone.isEmpty
                ? null
                : () => makePhoneCall(phoneNumber: stop.phone, context: context),
          ),
        ],
      ),
    );
  }
}
