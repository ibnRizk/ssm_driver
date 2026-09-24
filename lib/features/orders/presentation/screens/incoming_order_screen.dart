import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/active_offer.dart';
import '../cubit/current_work_cubit.dart';
import '../cubit/incoming_order_cubit.dart';
import '../cubit/incoming_order_state.dart';
import '../widgets/offer_countdown.dart';
import '../widgets/order_action_buttons.dart';
import '../widgets/order_assignment_banner.dart';
import '../widgets/order_summary_card.dart';
import '../work_status_label.dart';

/// Full-screen prompt for the dispatch offer (`GET /delivery-man/active-offer`)
/// with accept/reject.
///
/// Pushed outside the bottom-nav shell (see `AppRoutes.incomingOrder`) —
/// it's a one-off decision screen, not a tab. [offer] is the one home
/// polling already fetched; opened without it, the screen reads it itself.
class IncomingOrderScreen extends StatelessWidget {
  final ActiveOffer? offer;

  const IncomingOrderScreen({super.key, this.offer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IncomingOrderCubit>(
      create: (_) =>
          ServiceLocator.instance<IncomingOrderCubit>()..start(offer),
      child: const _IncomingOrderView(),
    );
  }
}

class _IncomingOrderView extends StatelessWidget {
  const _IncomingOrderView();

  void _close(BuildContext context) =>
      context.canPop() ? context.pop() : context.goNamed(AppRoutes.homeName);

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocListener<IncomingOrderCubit, IncomingOrderState>(
      listener: (BuildContext context, IncomingOrderState state) {
        switch (state) {
          case IncomingOrderActionFailed(:final String message):
            showAppSnackBar(
              context: context,
              message: message,
              type: ToastType.error,
            );
          case IncomingOrderUnavailable():
            showAppSnackBar(
              context: context,
              message: Strings.orderOfferUnavailable,
              type: ToastType.info,
            );
            _close(context);
          // Fetch the accepted order into the app-wide cubit, so the trip
          // screen and the Orders tab both show it. Whatever it held before
          // is stale now, hence no keeping content.
          case IncomingOrderAccepted():
            context.read<CurrentWorkCubit>().loadCurrentWork(
              keepContent: false,
            );
            context.pushReplacementNamed(AppRoutes.orderTripName);
          case IncomingOrderRejected():
            _close(context);
          default:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: BlocBuilder<IncomingOrderCubit, IncomingOrderState>(
            builder: (BuildContext context, IncomingOrderState state) =>
                switch (state) {
                  IncomingOrderReady(
                    :final ActiveOffer offer,
                    :final OfferAction? inFlight,
                  ) =>
                    _OfferContent(offer: offer, inFlight: inFlight),
                  IncomingOrderActionFailed(:final ActiveOffer offer) =>
                    _OfferContent(offer: offer, inFlight: null),
                  IncomingOrderLoadError(:final String message) => Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.screen.w),
                        child: const _Header(),
                      ),
                      Expanded(
                        child: ErrorRetryView(
                          message: message,
                          onRetry: context.read<IncomingOrderCubit>().loadOffer,
                        ),
                      ),
                    ],
                  ),
                  // Loading, or about to leave the screen.
                  _ => Center(
                    child: CircularProgressIndicator(color: c.secondary),
                  ),
                },
          ),
        ),
      ),
    );
  }
}

class _OfferContent extends StatelessWidget {
  final ActiveOffer offer;
  final OfferAction? inFlight;

  const _OfferContent({required this.offer, required this.inFlight});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final IncomingOrderCubit cubit = context.read<IncomingOrderCubit>();
    final String storeName = offer.pickupName.isEmpty ? '-' : offer.pickupName;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _Header(),
          SizedBox(height: AppSpacing.lg.h),
          OrderAssignmentBanner(
            title: Strings.orderAssignmentTitle,
            subtitle: Strings.orderAssignmentSubtitle,
          ),
          SizedBox(height: AppSpacing.lg.h),
          OrderSummaryCard(
            orderId: offer.orderLabel,
            distance: offer.distanceLabel,
            // Re-read the offer at zero: the server decides whether it's gone.
            eta: OfferCountdown(
              remainingSeconds: offer.remainingSeconds,
              onExpired: cubit.loadOffer,
            ),
            restaurantInitial: storeName.characters.first,
            restaurantName: storeName,
            restaurantDistrict: offer.pickupAddress,
            destinationLabel: Strings.orderDestinationLabel,
            destinationValue: offer.deliveryAddress.isEmpty
                ? '-'
                : offer.deliveryAddress,
            contentsLabel: Strings.orderPaymentLabel,
            contentsValue: offer.paymentMethodLabel,
            codLabel: offer.isCashOnDelivery
                ? Strings.orderCodLabel
                : Strings.orderPaymentLabel,
            codAmount: offer.paymentLabel,
          ),
          SizedBox(height: AppSpacing.lg.h),
          OrderActionButtons(
            acceptLabel: Strings.orderAcceptButton,
            rejectLabel: Strings.orderRejectButton,
            isAccepting: inFlight == OfferAction.accept,
            isRejecting: inFlight == OfferAction.reject,
            onAccept: cubit.accept,
            onReject: cubit.reject,
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            Strings.orderRejectFooterNote,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: c.textHint),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            Strings.orderNewTitle,
            style: AppTextStyles.h1(color: c.primary),
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: c.secondaryLight,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: c.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
