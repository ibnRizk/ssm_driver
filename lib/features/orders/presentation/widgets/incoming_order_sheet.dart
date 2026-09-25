import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../domain/entities/active_offer.dart';
import '../cubit/current_work_cubit.dart';
import '../cubit/incoming_order_cubit.dart';
import '../cubit/incoming_order_state.dart';
import '../work_status_label.dart';

/// What the sheet's content depends on — everything but the countdown,
/// which redraws on its own every second.
typedef _OfferView = ({
  ActiveOffer offer,
  OfferAction? inFlight,
  String? error,
});

_OfferView? _viewOf(IncomingOrderState state) => switch (state) {
  IncomingOrderReady(:final ActiveOffer offer, :final OfferAction? inFlight) =>
    (offer: offer, inFlight: inFlight, error: null),
  IncomingOrderActionFailed(:final ActiveOffer offer, :final String message) =>
    (offer: offer, inFlight: null, error: message),
  _ => null,
};

/// The dispatch offer as a bottom sheet over whatever screen the Driver is
/// on. Shown by [IncomingOrderPresenter], which provides the cubit; the sheet
/// closes itself on every way out — answered, expired, or gone.
class IncomingOrderSheet extends StatelessWidget {
  const IncomingOrderSheet({super.key});

  /// Closes exactly this sheet, even if something was pushed above it.
  static void _dismiss(BuildContext context) {
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    final NavigatorState navigator = Navigator.of(context);
    route.isCurrent ? navigator.pop() : navigator.removeRoute(route);
  }

  /// The snackbar lands on the screen under the sheet, so it stays readable
  /// after the sheet is gone.
  static void _dismissWith(
    BuildContext context,
    String message,
    ToastType type,
  ) {
    showAppSnackBar(context: context, message: message, type: type);
    _dismiss(context);
  }

  void _onState(BuildContext context, IncomingOrderState state) {
    switch (state) {
      // Fetch the accepted order into the app-wide cubit, so the trip screen
      // and the Orders tab both show it. Whatever it held before is stale
      // now, hence no keeping content.
      case IncomingOrderAccepted():
        context.read<CurrentWorkCubit>().loadCurrentWork(keepContent: false);
        final GoRouter router = GoRouter.of(context);
        _dismiss(context);
        router.pushNamed(AppRoutes.orderTripName);
      case IncomingOrderRejected():
        _dismiss(context);
      case IncomingOrderExpired():
        _dismissWith(context, Strings.orderOfferExpired, ToastType.info);
      case IncomingOrderUnavailable():
        _dismissWith(context, Strings.orderOfferUnavailable, ToastType.info);
      case IncomingOrderLoadError(:final String message):
        _dismissWith(context, message, ToastType.error);
      case IncomingOrderInitial() || IncomingOrderOffered():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return PopScope(
      // Answered with the buttons only: back must not drop the offer
      // unanswered while it keeps ringing server-side.
      canPop: false,
      child: BlocListener<IncomingOrderCubit, IncomingOrderState>(
        listener: _onState,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl.r),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen.w,
                AppSpacing.xs.h,
                AppSpacing.screen.w,
                AppSpacing.md.h,
              ),
              child: BlocBuilder<IncomingOrderCubit, IncomingOrderState>(
                // Ended states keep the last content while the sheet slides
                // away, instead of collapsing mid-animation.
                buildWhen:
                    (IncomingOrderState previous, IncomingOrderState current) =>
                        current is IncomingOrderOffered &&
                        _viewOf(previous) != _viewOf(current),
                builder: (BuildContext context, IncomingOrderState state) {
                  final _OfferView? view = _viewOf(state);
                  return view == null
                      ? const SizedBox.shrink()
                      : _OfferContent(view: view);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferContent extends StatelessWidget {
  final _OfferView view;

  const _OfferContent({required this.view});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? error = view.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        _Header(orderLabel: view.offer.orderLabel),
        SizedBox(height: AppSpacing.sm.h),
        const _CountdownBar(),
        SizedBox(height: AppSpacing.lg.h),
        _RouteInfo(offer: view.offer),
        SizedBox(height: AppSpacing.sm.h),
        _Metrics(offer: view.offer),
        if (error != null) ...<Widget>[
          SizedBox(height: AppSpacing.sm.h),
          _ErrorNote(message: error),
        ],
        SizedBox(height: AppSpacing.lg.h),
        _Actions(inFlight: view.inFlight),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          Strings.orderRejectFooterNote,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: c.textHint),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String orderLabel;

  const _Header({required this.orderLabel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: c.secondaryLight,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
          child: Icon(
            Icons.notifications_active_rounded,
            color: c.secondary,
            size: AppSizes.icon.r,
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Text(
            Strings.orderOfferTitle,
            style: AppTextStyles.h2(color: c.textPrimary),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xxs.h,
          ),
          decoration: BoxDecoration(
            color: c.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(orderLabel, style: AppTextStyles.label(color: c.primary)),
        ),
      ],
    );
  }
}

/// The only part of the sheet that rebuilds every second.
class _CountdownBar extends StatelessWidget {
  const _CountdownBar();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocBuilder<IncomingOrderCubit, IncomingOrderState>(
      buildWhen: (_, IncomingOrderState current) =>
          current is IncomingOrderOffered,
      builder: (BuildContext context, IncomingOrderState state) {
        if (state is! IncomingOrderOffered) return const SizedBox.shrink();
        final Color color = state.secondsLeft <= 10 ? c.error : c.success;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Glides between the one-second ticks instead of jumping.
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: state.progress),
              duration: const Duration(seconds: 1),
              builder: (_, double value, __) => ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6.h,
                  color: color,
                  backgroundColor: c.border,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xxs.h),
            Text(
              Strings.orderOfferExpiresIn(state.secondsLeft),
              textAlign: TextAlign.end,
              style: AppTextStyles.caption(color: color),
            ),
          ],
        );
      },
    );
  }
}

class _RouteInfo extends StatelessWidget {
  final ActiveOffer offer;

  const _RouteInfo({required this.offer});

  static const double _iconBox = 36;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm.r),
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Column(
        children: <Widget>[
          _RouteStop(
            iconBox: _iconBox,
            icon: Icons.storefront_rounded,
            color: c.secondary,
            background: c.secondaryLight,
            label: Strings.orderPickupTitle,
            title: offer.pickupName.isEmpty ? '-' : offer.pickupName,
            subtitle: offer.pickupAddress,
          ),
          // The line joining the two stops, centred under their icons.
          Padding(
            padding: EdgeInsetsDirectional.only(start: (_iconBox / 2 - 1).r),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                width: 2,
                height: AppSpacing.md.h,
                color: c.border,
              ),
            ),
          ),
          _RouteStop(
            iconBox: _iconBox,
            icon: Icons.location_on_rounded,
            color: c.primary,
            background: c.primaryLight,
            label: Strings.orderDeliveryTitle,
            title: offer.deliveryAddress.isEmpty ? '-' : offer.deliveryAddress,
          ),
        ],
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  final double iconBox;
  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final String title;
  final String subtitle;

  const _RouteStop({
    required this.iconBox,
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.title,
    this.subtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: iconBox.r,
          height: iconBox.r,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20.r),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: AppTextStyles.caption(color: c.textSecondary)),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleSmall(color: c.textPrimary),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(color: c.textHint),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Distance, payment method and cash to collect. The offer API carries no
/// Driver earnings or ETA yet, so neither is shown.
class _Metrics extends StatelessWidget {
  final ActiveOffer offer;

  const _Metrics({required this.offer});

  @override
  Widget build(BuildContext context) {
    final String distance = offer.distanceLabel;

    return Row(
      children: <Widget>[
        Expanded(
          child: _MetricTile(
            icon: Icons.route_rounded,
            label: Strings.orderDistanceLabel,
            value: distance.isEmpty ? '-' : distance,
          ),
        ),
        SizedBox(width: AppSpacing.xs.w),
        Expanded(
          child: _MetricTile(
            icon: Icons.payments_outlined,
            label: Strings.orderPaymentLabel,
            value: offer.paymentMethodLabel,
          ),
        ),
        SizedBox(width: AppSpacing.xs.w),
        Expanded(
          child: _MetricTile(
            icon: Icons.account_balance_wallet_outlined,
            label: Strings.orderToCollectLabel,
            value: offer.isCashOnDelivery
                ? Strings.orderAmount(offer.codAmount)
                : '-',
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: c.secondary, size: 20.r),
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(color: c.textSecondary),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleSmall(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _ErrorNote extends StatelessWidget {
  final String message;

  const _ErrorNote({required this.message});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm.r),
      decoration: BoxDecoration(
        color: c.errorLight,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline_rounded, color: c.error, size: 20.r),
          SizedBox(width: AppSpacing.xs.w),
          Expanded(
            child: Text(message, style: AppTextStyles.body(color: c.error)),
          ),
        ],
      ),
    );
  }
}

/// Reject (outlined) trails, accept (solid green) leads and is wider.
class _Actions extends StatelessWidget {
  final OfferAction? inFlight;

  const _Actions({required this.inFlight});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final IncomingOrderCubit cubit = context.read<IncomingOrderCubit>();
    final bool busy = inFlight != null;
    final Color rejectColor = busy ? c.textHint : c.error;

    return Row(
      children: <Widget>[
        Expanded(
          child: AppOutlinedButton(
            text: Strings.orderRejectButton,
            onPressed: busy ? null : cubit.reject,
            textColor: rejectColor,
            borderColor: rejectColor,
            buttonRadius: AppRadius.lg.r,
            minimumSize: Size.fromHeight(AppSizes.buttonHeight.h),
            icon: inFlight == OfferAction.reject
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: rejectColor,
                    ),
                  )
                : null,
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          flex: 2,
          child: AppButton(
            btnText: Strings.orderAcceptButton,
            icon: Icons.check_rounded,
            color: c.success,
            isLoading: inFlight == OfferAction.accept,
            onPressed: busy ? null : cubit.accept,
          ),
        ),
      ],
    );
  }
}
