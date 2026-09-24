import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/launch_url_method.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/destination_map.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/current_work.dart';
import '../cubit/current_work_cubit.dart';
import '../cubit/order_lifecycle_cubit.dart';
import '../cubit/order_lifecycle_state.dart';
import '../lifecycle_feedback.dart';
import '../widgets/current_work_view.dart';
import '../widgets/customer_details_card.dart';
import '../widgets/delivery_status_card.dart';
import '../widgets/flow_back_button.dart';
import '../widgets/maps_call_buttons.dart';
import '../work_status_label.dart';

/// Step 3 of the delivery flow: the final leg to the customer. Starts the
/// delivery (`POST /delivery-man/orders/{id}/out-for-delivery`), then hands
/// over to proof of delivery. No bottom nav; reads the app-wide
/// [CurrentWorkCubit].
class DeliveryToCustomerScreen extends StatelessWidget {
  const DeliveryToCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocProvider<OrderLifecycleCubit>(
      create: (_) => ServiceLocator.instance<OrderLifecycleCubit>(),
      child: BlocListener<OrderLifecycleCubit, OrderLifecycleState>(
        listener: (BuildContext context, OrderLifecycleState state) {
          switch (state) {
            // Stays here: the CTA switches to "Enter delivery code".
            case LifecycleSuccess(:final transition):
              context.read<CurrentWorkCubit>().applyTransition(transition);
            case final LifecycleFailure failure:
              showLifecycleFailure(context, failure);
            default:
              break;
          }
        },
        child: Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            child: CurrentWorkView(
              header: const _Header(orderId: null),
              builder: (_, CurrentWork work) => _Content(work: work),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final CurrentWork work;

  const _Content({required this.work});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double? lat = work.deliveryLatitude;
    final double? lng = work.deliveryLongitude;
    final String name = work.customerName.isEmpty ? '-' : work.customerName;
    final VoidCallback? call = work.customerPhone.isEmpty
        ? null
        : () =>
              makePhoneCall(phoneNumber: work.customerPhone, context: context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Header(orderId: work.orderLabel),
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
            initial: name.characters.first,
            name: name,
            address: work.deliveryAddress,
            onCallTap: call,
          ),
          SizedBox(height: AppSpacing.lg.h),
          DestinationMap(
            latitude: lat,
            longitude: lng,
            markerTitle: name,
            label: Strings.orderRouteToCustomerLabel,
          ),
          SizedBox(height: AppSpacing.lg.h),
          MapsCallButtons(
            mapsLabel: Strings.orderOpenGoogleMapsButton,
            callLabel: Strings.orderCallCustomerButton,
            onMapsTap: lat == null || lng == null
                ? null
                : () => openMapsDirections(
                    latitude: lat,
                    longitude: lng,
                    context: context,
                  ),
            onCallTap: call,
          ),
          if (work.isCashOnDelivery) ...<Widget>[
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
                  Text(
                    work.paymentLabel,
                    style: AppTextStyles.h1(color: c.primary),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSpacing.md.h),
          Text(
            Strings.orderDeliveryFooterNote,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: c.textHint),
          ),
          SizedBox(height: AppSpacing.xl.h),
          _NextStepButton(work: work),
        ],
      ),
    );
  }
}

/// The CTA follows the server status, so the lifecycle can only advance in
/// order: picked up → start delivery → enter the customer's code.
class _NextStepButton extends StatelessWidget {
  final CurrentWork work;

  const _NextStepButton({required this.work});

  @override
  Widget build(BuildContext context) {
    return switch (work.status) {
      WorkStatus.pickedUp =>
        BlocSelector<OrderLifecycleCubit, OrderLifecycleState, bool>(
          selector: (OrderLifecycleState s) => s is LifecycleInProgress,
          builder: (BuildContext context, bool inProgress) => AppButton(
            btnText: Strings.orderStartDeliveryButton,
            isLoading: inProgress,
            onPressed: () =>
                context.read<OrderLifecycleCubit>().startDelivery(work),
          ),
        ),
      WorkStatus.outForDelivery => AppButton(
        btnText: Strings.orderEnterDeliveryCodeButton,
        onPressed: () =>
            context.pushReplacementNamed(AppRoutes.proofOfDeliveryName),
      ),
      // Not picked up yet (or unknown): pickup has to be confirmed first.
      _ => AppButton(
        btnText: Strings.orderNavigateToStoreButton,
        onPressed: () =>
            context.pushReplacementNamed(AppRoutes.navigateToStoreName),
      ),
    };
  }
}

class _Header extends StatelessWidget {
  /// `null` while the order is still loading (no id pill yet).
  final String? orderId;

  const _Header({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? id = orderId;

    return Row(
      children: <Widget>[
        const FlowBackButton(),
        Expanded(
          child: Center(
            child: Text(
              Strings.orderDeliveryToCustomerTitle,
              style: AppTextStyles.h1(color: c.textPrimary),
            ),
          ),
        ),
        if (id != null)
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
              id,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.label(color: c.textSecondary),
            ),
          ),
      ],
    );
  }
}
