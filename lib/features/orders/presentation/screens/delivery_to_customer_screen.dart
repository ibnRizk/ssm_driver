import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/map_placeholder.dart';
import '../widgets/customer_details_card.dart';
import '../widgets/delivery_status_card.dart';
import '../widgets/maps_call_buttons.dart';

/// Standalone screen: the final delivery leg, from having the order to
/// reaching the customer. No bottom nav — pushed on top of the trip flow.
///
/// TODO: Replace the mock order/customer fields below with the real order
/// payload (route `extra`) once the orders/maps APIs exist.
class DeliveryToCustomerScreen extends StatelessWidget {
  const DeliveryToCustomerScreen({super.key});

  static const String _orderId = 'SSM-1048#';
  static String get _customerInitial => Strings.orderMockCustomerInitial;
  static String get _customerName => Strings.orderMockCustomer;
  static String get _customerAddress => Strings.orderMockFullAddress;
  static String get _codAmount => Strings.orderMockCODAmount;

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
              DeliveryStatusCard(
                topLabel: Strings.orderDeliveryStatusTop,
                headline: Strings.orderDeliveryStatusMain,
                subtitle: Strings.orderDeliveryStatusSubtitle,
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                Strings.orderCustomerDetailsTitle,
                style: AppTextStyles.title(color: c.textPrimary),
              ),
              SizedBox(height: AppSpacing.sm.h),
              CustomerDetailsCard(
                initial: _customerInitial,
                name: _customerName,
                address: _customerAddress,
                onCallTap: () {
                  // TODO: Launch a `tel:` call once a real phone number
                  // exists.
                },
              ),
              SizedBox(height: AppSpacing.lg.h),
              MapPlaceholder(label: Strings.orderRouteToCustomerLabel),
              SizedBox(height: AppSpacing.lg.h),
              MapsCallButtons(
                mapsLabel: Strings.orderOpenGoogleMapsButton,
                callLabel: Strings.orderCallCustomerButton,
                onMapsTap: () {
                  // TODO: Launch Google Maps once real coordinates exist.
                },
                onCallTap: () {
                  // TODO: Launch a `tel:` call once a real phone number
                  // exists.
                },
              ),
              SizedBox(height: AppSpacing.lg.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md.w,
                  vertical: AppSpacing.sm.h,
                ),
                decoration: BoxDecoration(
                  color: c.secondaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        Strings.orderCodCashLabel,
                        style: AppTextStyles.body(color: c.secondaryDark),
                      ),
                    ),
                    Text(_codAmount, style: AppTextStyles.h1(color: c.primary)),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Text(
                Strings.orderDeliveryFooterNote,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(color: c.textHint),
              ),
              SizedBox(height: AppSpacing.xl.h),
              AppButton(
                btnText: Strings.confirm,
                onPressed: () {
                  context.pushReplacementNamed(AppRoutes.proofOfDeliveryName);
                },
              ),
            ],
          ),
        ),
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
                Icons.chevron_right_rounded, color: c.textPrimary,
                size: 24.r,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              Strings.orderDeliveryToCustomerTitle,
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
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: c.border),
          ),
          child: Text(
            orderId,
            style: AppTextStyles.label(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}
