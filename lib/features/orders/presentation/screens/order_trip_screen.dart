import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/order_items_card.dart';
import '../widgets/trip_cod_summary.dart';
import '../widgets/trip_step_card.dart';

/// The accepted-order trip screen: pickup step, delivery step, itemized
/// contents, COD summary, and the CTA to head to the store.
///
/// Pushed outside the bottom-nav shell (see `AppRoutes.orderTrip`) — same
/// reasoning as `IncomingOrderScreen`: a linear flow, not a tab.
///
/// TODO: Replace the mock order fields below with the real order payload
/// (route `extra`) once the orders API exists.
class OrderTripScreen extends StatelessWidget {
  const OrderTripScreen({super.key});

  static const String _orderId = 'SSM-1048#';
  static const String _restaurantName = 'مطاعم مذاق';
  static const String _restaurantAddress =
      'حي الملك فهد، شارع الملك عبدالعزيز، نزلة';
  static const String _customerName = 'عبدالعزيز محمد';
  static const String _customerAddress = 'المنزل — حي الملك فهد، نزلة';
  static const String _customerPhone = '05X XXX XXXX';
  static const String _codAmount = '71 ر.س';
  static const List<OrderLineItem> _items = <OrderLineItem>[
    OrderLineItem(description: 'وجبة برجر × 2 SSM', price: '56 ر.س'),
    OrderLineItem(description: 'بطاطس مقرمشة × 1', price: '8 ر.س'),
    OrderLineItem(description: 'رسوم التوصيل', price: '7 ر.س'),
  ];

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
              const _TripHeader(orderId: _orderId),
              SizedBox(height: AppSpacing.lg.h),
              _SectionHeader(
                title: Strings.orderPickupTitle,
                stepLabel: Strings.orderStepLabel(1),
              ),
              SizedBox(height: AppSpacing.sm.h),
              TripStepCard(
                icon: Icons.storefront_rounded,
                title: _restaurantName,
                subtitleLines: const <String>[_restaurantAddress],
                actionIcon: Icons.map_outlined,
                actionLabel: Strings.orderMapButton,
                onActionTap: () {
                  // TODO: Open the store's location once coordinates exist.
                },
              ),
              SizedBox(height: AppSpacing.lg.h),
              _SectionHeader(
                title: Strings.orderDeliveryTitle,
                stepLabel: Strings.orderStepLabel(2),
              ),
              SizedBox(height: AppSpacing.sm.h),
              TripStepCard(
                icon: Icons.location_on_rounded,
                title: _customerName,
                subtitleLines: const <String>[
                  _customerAddress,
                  _customerPhone,
                ],
                actionIcon: Icons.call_outlined,
                actionLabel: Strings.orderCallButton,
                onActionTap: () {
                  // TODO: Launch a `tel:` call once a real phone number
                  // exists.
                },
              ),
              SizedBox(height: AppSpacing.lg.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    Strings.orderContentsLabel,
                    style: AppTextStyles.h2(color: c.textPrimary),
                  ),
                  Text(
                    Strings.orderContentsValue(_items.length),
                    style: AppTextStyles.caption(color: c.textSecondary),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              const OrderItemsCard(items: _items),
              SizedBox(height: AppSpacing.lg.h),
              TripCodSummary(
                label: Strings.orderCodLabel,
                cashNote: Strings.orderCodCashNote,
                amount: _codAmount,
              ),
              SizedBox(height: AppSpacing.xl.h),
              AppButton(
                btnText: Strings.orderNavigateToStoreButton,
                onPressed: () =>
                    context.pushNamed(AppRoutes.navigateToStoreName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripHeader extends StatelessWidget {
  final String orderId;

  const _TripHeader({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        Material(
          color: c.surface,
          shape: const CircleBorder(),
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
              Strings.orderDetailsTitle,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String stepLabel;

  const _SectionHeader({required this.title, required this.stepLabel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(title, style: AppTextStyles.title(color: c.textPrimary)),
        Text(stepLabel, style: AppTextStyles.caption(color: c.textSecondary)),
      ],
    );
  }
}
