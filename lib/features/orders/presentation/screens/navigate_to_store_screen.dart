import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/tinted_note.dart';
import '../widgets/route_stat_card.dart';
import '../widgets/store_location_card.dart';

/// Standalone screen: guides the driver from accepting an order to the
/// store's pickup point. No bottom nav — pushed on top of the trip flow.
///
/// TODO: Replace the mock order/route fields below with the real order +
/// routing payload (route `extra`) once the orders/maps APIs exist.
class NavigateToStoreScreen extends StatelessWidget {
  const NavigateToStoreScreen({super.key});

  static const String _orderId = 'SSM-1048#';
  static const String _storeName = 'مطاعم مذاق';
  static const String _storeAddress =
      'حي الملك فهد، شارع الملك عبدالعزيز، نزلة';
  static const String _distance = '3.2 كم';
  static const String _etaMinutes = '8 د';

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screen.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _Header(orderId: _orderId),
              SizedBox(height: AppSpacing.lg.h),
              StoreLocationCard(
                storeName: _storeName,
                pickupPointLabel: Strings.orderPickupPointLabel,
                address: _storeAddress,
              ),
              SizedBox(height: AppSpacing.lg.h),
              _MapPlaceholder(),
              SizedBox(height: AppSpacing.lg.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RouteStatCard(
                      label: Strings.orderDistanceLabel,
                      value: _distance,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: RouteStatCard(
                      label: Strings.orderEtaTimeLabel,
                      value: _etaMinutes,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: AppButton(
                      btnText: Strings.orderOpenGoogleMapsButton,
                      icon: Icons.open_in_new_rounded,
                      onPressed: () {
                        // TODO: Launch Google Maps once real coordinates
                        // exist.
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    flex: 3,
                    child: AppButton(
                      btnText: Strings.orderCallButton,
                      icon: Icons.call_outlined,
                      color: c.primary,
                      onPressed: () {
                        // TODO: Launch a `tel:` call once a real phone
                        // number exists.
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              TintedNote(
                text: Strings.orderNavigateWarningNote,
                backgroundColor: c.secondaryLight,
                textColor: c.secondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      height: 220.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EDE9),
        borderRadius: BorderRadius.circular(AppRadius.xl.r),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.map_outlined,
        size: 40.r,
        color: c.textHint,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String orderId;

  const _Header({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          shape: CircleBorder(side: BorderSide(color: c.border)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xs.r),
              child: Icon(
                Icons.chevron_right_rounded,
                color: c.textPrimary,
                size: 24.r,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              Strings.orderNavigateTitle,
              style: AppTextStyles.h1(color: c.textPrimary),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xxs.h,
          ),
          decoration: BoxDecoration(
            color: c.secondaryLight,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            orderId,
            style: AppTextStyles.label(color: c.secondary),
          ),
        ),
      ],
    );
  }
}
