import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart' show ToastType, showAppSnackBar;
import '../../../../injection_container.dart';
import '../cubit/incoming_order_cubit.dart';
import '../cubit/incoming_order_state.dart';
import '../widgets/order_action_buttons.dart';
import '../widgets/order_assignment_banner.dart';
import '../widgets/order_summary_card.dart';

/// Full-screen prompt shown when a new order is dispatched to the driver.
///
/// Pushed outside the bottom-nav shell (see `AppRoutes.incomingOrder`) —
/// it's a one-off decision screen, not a tab.
///
/// TODO: Replace the mock order fields below with the real dispatch payload
/// (e.g. via route `extra`) once the orders API/push channel exists.
class IncomingOrderScreen extends StatelessWidget {
  const IncomingOrderScreen({super.key});

  static const String _orderId = 'SSM-1048#';
  static String get _distance => Strings.orderMockDistance2;
  static const int _etaMinutes = 5;
  static String get _restaurantName => Strings.orderMockStore;
  static String get _restaurantDistrict => Strings.orderMockRestaurantDistrict;
  static String get _destinationValue => Strings.orderMockDestination;
  static const int _contentsCount = 3;
  static String get _codAmount => Strings.orderMockCODAmount;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IncomingOrderCubit>(
      create: (_) => ServiceLocator.instance<IncomingOrderCubit>(),
      child: const _IncomingOrderView(),
    );
  }
}

class _IncomingOrderView extends StatelessWidget {
  const _IncomingOrderView();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocListener<IncomingOrderCubit, IncomingOrderState>(
      listener: (BuildContext context, IncomingOrderState state) {
        if (state is IncomingOrderError) {
          showAppSnackBar(
            context: context,
            message: state.message,
            type: ToastType.error,
          );
        } else if (state is IncomingOrderAccepted) {
          context.pushReplacementNamed(AppRoutes.orderTripName);
        } else if (state is IncomingOrderRejected) {
          // TODO: Dismiss back to the orders list once it exists.
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.screen.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Header(),
                SizedBox(height: AppSpacing.lg.h),
                OrderAssignmentBanner(
                  title: Strings.orderAssignmentTitle,
                  subtitle: Strings.orderAssignmentSubtitle,
                ),
                SizedBox(height: AppSpacing.lg.h),
                OrderSummaryCard(
                  orderId: IncomingOrderScreen._orderId,
                  distance: IncomingOrderScreen._distance,
                  eta: Strings.orderEtaLabel(
                    IncomingOrderScreen._etaMinutes,
                  ),
                  restaurantInitial: IncomingOrderScreen._restaurantName
                      .characters
                      .first,
                  restaurantName: IncomingOrderScreen._restaurantName,
                  restaurantDistrict:
                      IncomingOrderScreen._restaurantDistrict,
                  destinationLabel: Strings.orderDestinationLabel,
                  destinationValue: IncomingOrderScreen._destinationValue,
                  contentsLabel: Strings.orderContentsLabel,
                  contentsValue: Strings.orderContentsValue(
                    IncomingOrderScreen._contentsCount,
                  ),
                  codLabel: Strings.orderCodLabel,
                  codAmount: IncomingOrderScreen._codAmount,
                ),
                SizedBox(height: AppSpacing.lg.h),
                BlocBuilder<IncomingOrderCubit, IncomingOrderState>(
                  builder: (BuildContext context, IncomingOrderState state) {
                    return OrderActionButtons(
                      acceptLabel: Strings.orderAcceptButton,
                      rejectLabel: Strings.orderRejectButton,
                      isAccepting: state is IncomingOrderAccepting,
                      isRejecting: state is IncomingOrderRejecting,
                      onAccept: () => context
                          .read<IncomingOrderCubit>()
                          .accept(IncomingOrderScreen._orderId),
                      onReject: () => context
                          .read<IncomingOrderCubit>()
                          .reject(IncomingOrderScreen._orderId),
                    );
                  },
                ),
                SizedBox(height: AppSpacing.md.h),
                Text(
                  Strings.orderRejectFooterNote,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(color: c.textHint),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
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
