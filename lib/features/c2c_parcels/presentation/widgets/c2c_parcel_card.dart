import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../c2c_display.dart';

/// An offer or an accepted job on the house-to-house board.
///
/// An offer shows coarse areas only (contract §7) and an accept button; a
/// job shows its status and opens on tap.
class C2cParcelCard extends StatelessWidget {
  final C2cParcel parcel;

  /// Offers only.
  final VoidCallback? onAccept;
  final bool isAccepting;

  /// Jobs only.
  final VoidCallback? onTap;

  const C2cParcelCard.offer({
    super.key,
    required this.parcel,
    required this.onAccept,
    required this.isAccepting,
  }) : onTap = null;

  const C2cParcelCard.job({super.key, required this.parcel, required this.onTap})
    : onAccept = null,
      isAccepting = false;

  bool get _isOffer => onTap == null;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String summary = parcel.summary;
    final String? expiry = parcel.expiryLabel;
    // A job names where the Driver is heading next; an offer only areas.
    final String route = _isOffer
        ? parcel.areaRoute
        : parcel.isHeadingToPickup
        ? '${Strings.c2cPickupTitle}: ${parcel.pickup.placeLabel}'
        : '${Strings.c2cDropoffTitle}: ${parcel.dropoff.placeLabel}';

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            border: Border.all(color: _isOffer ? c.secondary : c.border),
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.home_work_outlined, size: 22.r, color: c.secondary),
                  SizedBox(width: AppSpacing.xs.w),
                  Expanded(
                    child: Text(
                      parcel.label,
                      style: AppTextStyles.title(color: c.primaryDark),
                    ),
                  ),
                  Text(
                    parcel.status.label,
                    style: AppTextStyles.caption(color: c.secondaryDark),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(route, style: AppTextStyles.body(color: c.textPrimary)),
              if (summary.isNotEmpty) ...<Widget>[
                SizedBox(height: AppSpacing.xxs.h),
                Text(summary, style: AppTextStyles.caption(color: c.textSecondary)),
              ],
              if (_isOffer) ...<Widget>[
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  expiry == null
                      ? Strings.c2cOfferCoarseNote
                      : '${Strings.c2cOfferCoarseNote}\n$expiry',
                  style: AppTextStyles.caption(color: c.textHint),
                ),
                SizedBox(height: AppSpacing.sm.h),
                AppButton(
                  btnText: Strings.c2cActionAccept,
                  isLoading: isAccepting,
                  onPressed: onAccept,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
