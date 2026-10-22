import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/route_stops_card.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../c2c_display.dart';
import '../cubit/c2c_action_cubit.dart';
import '../cubit/c2c_action_state.dart';
import '../cubit/c2c_offer_alert_cubit.dart';

/// How a [C2cOfferSheet] was left. `null` means "Later" — the offer stays
/// on the board.
sealed class C2cOfferSheetResult {
  const C2cOfferSheetResult();
}

/// The server took the accept; open the job straight away. [parcel] is its
/// answer, or `null` when it sent none (the job screen reads it then).
final class C2cOfferAccepted extends C2cOfferSheetResult {
  final int parcelId;
  final C2cParcel? parcel;

  const C2cOfferAccepted(this.parcelId, this.parcel);
}

/// The Driver rejected the offer.
final class C2cOfferRejected extends C2cOfferSheetResult {
  final int parcelId;
  final int offerId;

  const C2cOfferRejected(this.parcelId, this.offerId);
}

/// The Driver wants every waiting offer, on the board.
final class C2cOfferViewAll extends C2cOfferSheetResult {
  const C2cOfferViewAll();
}

/// Shows [offer] as a bottom sheet over the current screen. [moreCount] is
/// how many other new offers arrived with it; they stay on the board.
Future<C2cOfferSheetResult?> showC2cOfferSheet({
  required BuildContext context,
  required C2cParcel offer,
  int moreCount = 0,
}) {
  return showModalBottomSheet<C2cOfferSheetResult>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    // Drag-to-close skips PopScope, so it would let the Driver drop the sheet
    // mid-accept and miss the job. Tapping outside goes through PopScope.
    enableDrag: false,
    backgroundColor: Colors.transparent,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 420),
      reverseDuration: Duration(milliseconds: 260),
    ),
    builder: (_) => MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<C2cActionCubit>(
          create: (_) => ServiceLocator.instance<C2cActionCubit>(),
        ),
        // Closed with the sheet, however it goes away — which silences it.
        BlocProvider<C2cOfferAlertCubit>(
          lazy: false,
          create: (_) =>
              ServiceLocator.instance<C2cOfferAlertCubit>()..start(offer),
        ),
      ],
      child: C2cOfferSheet(offer: offer, moreCount: moreCount),
    ),
  );
}

/// A new house-to-house offer: route, parcel and accept. Before acceptance
/// only coarse areas are known (contract §7); the job screen it opens on
/// accept shows the exact addresses and contacts.
class C2cOfferSheet extends StatelessWidget {
  final C2cParcel offer;
  final int moreCount;

  const C2cOfferSheet({super.key, required this.offer, this.moreCount = 0});

  void _onState(BuildContext context, C2cActionState state) {
    switch (state) {
      case C2cActionSuccess(:final int parcelId, :final C2cParcel? parcel):
        Navigator.of(context).pop(C2cOfferAccepted(parcelId, parcel));
      case C2cRejectSuccess(:final int parcelId, :final int offerId):
        Navigator.of(context).pop(C2cOfferRejected(parcelId, offerId));
      case C2cRejectFailure(:final String message):
        showAppSnackBar(
          context: context,
          message: message,
          type: ToastType.error,
        );
      // The server answered no: expired, or another Driver took it. A
      // network failure stays on the sheet to retry instead.
      case C2cActionFailure(:final String message, shouldRefresh: true):
        showAppSnackBar(
          context: context,
          message: message,
          type: ToastType.error,
        );
        Navigator.of(context).pop();
      default:
        break;
    }
  }

  /// Ran out before the Driver answered; it stays off the board too.
  void _onExpired(BuildContext context, C2cOfferAlertState _) {
    showAppSnackBar(
      context: context,
      message: Strings.orderOfferExpired,
      type: ToastType.info,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    // Built once: toggling `busy` below only rebuilds the PopScope.
    final Widget content = _FadeSlideIn(
      child: _OfferContent(offer: offer, moreCount: moreCount),
    );

    return MultiBlocListener(
      listeners: <BlocListener<StateStreamableSource<Object?>, Object?>>[
        BlocListener<C2cActionCubit, C2cActionState>(listener: _onState),
        BlocListener<C2cOfferAlertCubit, C2cOfferAlertState>(
          listenWhen: (_, C2cOfferAlertState s) =>
              s == C2cOfferAlertState.expired,
          listener: _onExpired,
        ),
      ],
      child: BlocSelector<C2cActionCubit, C2cActionState, bool>(
        selector: (C2cActionState s) =>
            s is C2cActionInProgress || s is C2cRejectInProgress,
        // No closing while the accept or reject is out: its answer decides.
        builder: (_, bool busy) => PopScope(
          canPop: !busy,
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
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lifts the content in just behind the sheet's own slide.
class _FadeSlideIn extends StatelessWidget {
  final Widget child;

  const _FadeSlideIn({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (_, double t, Widget? child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 16.h),
          child: child,
        ),
      ),
    );
  }
}

class _OfferContent extends StatelessWidget {
  final C2cParcel offer;
  final int moreCount;

  const _OfferContent({required this.offer, required this.moreCount});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? expiry = offer.expiryLabel;

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
        _Header(reference: offer.label),
        if (expiry != null) ...<Widget>[
          SizedBox(height: AppSpacing.xs.h),
          _IconNote(
            icon: Icons.schedule_rounded,
            text: expiry,
            color: c.warning,
          ),
        ],
        SizedBox(height: AppSpacing.lg.h),
        RouteStopsCard(
          pickup: RouteStopData(
            icon: Icons.home_rounded,
            label: Strings.c2cPickupTitle,
            title: offer.pickup.areaLabel,
            subtitle: '',
          ),
          dropoff: RouteStopData(
            icon: Icons.location_on_rounded,
            label: Strings.c2cDropoffTitle,
            title: offer.destinationAreaLabel,
            subtitle: '',
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        _Metrics(offer: offer),
        if (offer.title.isNotEmpty ||
            offer.category.isNotEmpty ||
            offer.description.isNotEmpty ||
            offer.weightKg.isNotEmpty ||
            offer.isFragile) ...<Widget>[
          SizedBox(height: AppSpacing.sm.h),
          _ParcelCard(offer: offer),
        ],
        SizedBox(height: AppSpacing.sm.h),
        _IconNote(
          icon: Icons.lock_outline_rounded,
          text: Strings.c2cOfferCoarseNote,
          color: c.textHint,
        ),
        const _ErrorNote(),
        SizedBox(height: AppSpacing.lg.h),
        _Actions(offer: offer),
        if (moreCount > 0) ...<Widget>[
          SizedBox(height: AppSpacing.xs.h),
          TextButton(
            onPressed: () =>
                Navigator.of(context).maybePop(const C2cOfferViewAll()),
            child: Text(
              Strings.c2cOfferMore(moreCount),
              style: AppTextStyles.label(color: c.primary),
            ),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String reference;

  const _Header({required this.reference});

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
            Icons.home_work_rounded,
            color: c.secondary,
            size: AppSizes.icon.r,
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Text(
            Strings.c2cNewOfferTitle,
            style: AppTextStyles.h2(color: c.textPrimary),
          ),
        ),
        SizedBox(width: AppSpacing.xs.w),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xxs.h,
          ),
          decoration: BoxDecoration(
            color: c.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(reference, style: AppTextStyles.label(color: c.primary)),
        ),
      ],
    );
  }
}

/// What is being sent: title or category, weight, fragility, description.
class _ParcelCard extends StatelessWidget {
  final C2cParcel offer;

  const _ParcelCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String name = offer.title.isNotEmpty ? offer.title : offer.category;
    final String description = offer.description;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm.r),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.inventory_2_outlined, color: c.secondary, size: 20.r),
              SizedBox(width: AppSpacing.xs.w),
              Expanded(
                child: Text(
                  name.isEmpty ? Strings.c2cParcelInfo : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                ),
              ),
            ],
          ),
          if (offer.weightKg.isNotEmpty || offer.isFragile) ...<Widget>[
            SizedBox(height: AppSpacing.xs.h),
            Wrap(
              spacing: AppSpacing.xs.w,
              runSpacing: AppSpacing.xxs.h,
              children: <Widget>[
                if (offer.weightKg.isNotEmpty)
                  _Chip(
                    icon: Icons.scale_outlined,
                    text: Strings.c2cWeight(offer.weightKg),
                    color: c.primary,
                    background: c.primaryLight,
                  ),
                if (offer.isFragile)
                  _Chip(
                    icon: Icons.wine_bar_outlined,
                    text: Strings.c2cFragile,
                    color: c.warning,
                    background: c.warningLight,
                  ),
              ],
            ),
          ],
          if (description.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSpacing.xs.h),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  const _Chip({
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs.w,
        vertical: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 14.r),
          SizedBox(width: AppSpacing.xxs.w),
          Text(text, style: AppTextStyles.caption(color: color)),
        ],
      ),
    );
  }
}

class _IconNote extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _IconNote({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: color, size: 16.r),
        SizedBox(width: AppSpacing.xxs.w),
        Expanded(
          child: Text(text, style: AppTextStyles.caption(color: color)),
        ),
      ],
    );
  }
}

/// A network failure left the accept's outcome unknown; tapping accept again
/// retries it with the same idempotency key.
class _ErrorNote extends StatelessWidget {
  const _ErrorNote();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocSelector<C2cActionCubit, C2cActionState, String?>(
      selector: (C2cActionState s) =>
          s is C2cActionFailure && !s.shouldRefresh ? s.message : null,
      builder: (_, String? message) {
        if (message == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm.h),
          child: Container(
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
                  child: Text(
                    message,
                    style: AppTextStyles.body(color: c.error),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Distance and delivery fee metrics.
class _Metrics extends StatelessWidget {
  final C2cParcel offer;

  const _Metrics({required this.offer});

  @override
  Widget build(BuildContext context) {
    final String distance = offer.estimatedDistanceLabel;
    final String fee = offer.feeLabel;
    if (distance.isEmpty && fee.isEmpty) return const SizedBox.shrink();

    return Row(
      children: <Widget>[
        if (distance.isNotEmpty)
          Expanded(
            child: _MetricTile(
              icon: Icons.route_rounded,
              label: Strings.orderDistanceLabel,
              value: distance,
            ),
          ),
        if (distance.isNotEmpty && fee.isNotEmpty)
          SizedBox(width: AppSpacing.xs.w),
        if (fee.isNotEmpty)
          Expanded(
            child: _MetricTile(
              icon: Icons.payments_outlined,
              label: Strings.c2cTotalFee,
              value: fee,
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

/// Reject (outlined red) and Accept (solid green) lead; "Later" trails.
class _Actions extends StatelessWidget {
  final C2cParcel offer;

  const _Actions({required this.offer});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocBuilder<C2cActionCubit, C2cActionState>(
      builder: (BuildContext context, C2cActionState actionState) {
        final bool isAccepting = actionState is C2cActionInProgress;
        final bool isRejecting = actionState is C2cRejectInProgress;
        final bool busy = isAccepting || isRejecting;
        final Color rejectColor = busy ? c.textHint : c.error;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: AppOutlinedButton(
                    text: Strings.orderRejectButton,
                    onPressed: busy
                        ? null
                        : () {
                            context.read<C2cOfferAlertCubit>().silence();
                            context.read<C2cActionCubit>().reject(offer);
                          },
                    textColor: rejectColor,
                    borderColor: rejectColor,
                    buttonRadius: AppRadius.lg.r,
                    minimumSize: Size.fromHeight(AppSizes.buttonHeight.h),
                    icon: isRejecting
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
                    btnText: Strings.c2cActionAccept,
                    icon: Icons.check_rounded,
                    color: c.success,
                    isLoading: isAccepting,
                    onPressed: busy
                        ? null
                        : () {
                            context.read<C2cOfferAlertCubit>().silence();
                            context.read<C2cActionCubit>().run(
                              offer,
                              C2cAction.accept,
                            );
                          },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs.h),
            Center(
              child: TextButton(
                onPressed: busy ? null : () => Navigator.of(context).maybePop(),
                child: Text(
                  Strings.parcelNewAssignedLater,
                  style: AppTextStyles.label(color: c.textSecondary),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

