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
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/smart_empty_state_widget.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/parcel.dart';
import '../cubit/parcel_action_cubit.dart';
import '../cubit/parcel_action_state.dart';
import '../cubit/parcels_cubit.dart';
import '../cubit/parcels_state.dart';
import '../parcel_display.dart';
import '../widgets/parcel_route_card.dart';
import '../widgets/parcels_header.dart';
import '../widgets/parcels_list_header.dart';
import '../widgets/parcels_summary_card.dart';

/// The `parcels` tab: the Driver's active parcel round
/// (`GET /delivery-man/parcels?status=active`). Pull down to refresh.
///
/// "Start parcel tour" starts the first parcel still at the warehouse — the
/// API starts parcels one at a time — then opens it.
class ParcelsScreen extends StatelessWidget {
  const ParcelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers:
          <BlocProvider<StateStreamableSource<Object?>>>[
            BlocProvider<ParcelsCubit>(
              create: (_) =>
                  ServiceLocator.instance<ParcelsCubit>()
                    ..loadParcels(),
            ),
            BlocProvider<ParcelActionCubit>(
              create: (_) =>
                  ServiceLocator.instance<
                    ParcelActionCubit
                  >(),
            ),
          ],
      child: const _ParcelsView(),
    );
  }
}

/// Opens [parcel]'s details and re-reads the round on return, since it may
/// have been started or delivered there.
Future<void> _openParcel(
  BuildContext context,
  Parcel parcel,
) async {
  final ParcelsCubit cubit = context.read<ParcelsCubit>();
  await context.pushNamed<void>(
    AppRoutes.parcelDetailsName,
    pathParameters: <String, String>{'id': '${parcel.id}'},
    extra: parcel,
  );
  if (!cubit.isClosed) await cubit.loadParcels();
}

class _ParcelsView extends StatelessWidget {
  const _ParcelsView();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocListener<
      ParcelActionCubit,
      ParcelActionState
    >(
      listener:
          (BuildContext context, ParcelActionState state) {
            switch (state) {
              case ParcelActionSuccess(
                :final Parcel parcel,
              ):
                showAppSnackBar(
                  context: context,
                  message: Strings.parcelDeliveryStarted,
                  type: ToastType.success,
                );
                context.read<ParcelsCubit>().applyParcel(
                  parcel,
                );
                _openParcel(context, parcel);
              case ParcelActionFailure(
                :final String message,
                :final bool shouldRefresh,
              ):
                showAppSnackBar(
                  context: context,
                  message: message,
                  type: ToastType.error,
                );
                if (shouldRefresh)
                  context
                      .read<ParcelsCubit>()
                      .loadParcels();
              default:
                break;
            }
          },
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: BlocBuilder<ParcelsCubit, ParcelsState>(
            builder:
                (
                  BuildContext context,
                  ParcelsState state,
                ) => switch (state) {
                  ParcelsInitial() ||
                  ParcelsLoading() => _Scrollable(
                    header: const ParcelsHeader(),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: c.secondary,
                      ),
                    ),
                  ),
                  ParcelsError(:final String message) =>
                    _Scrollable(
                      header: const ParcelsHeader(),
                      child: ErrorRetryView(
                        message: message,
                        onRetry: () => context
                            .read<ParcelsCubit>()
                            .loadParcels(
                              keepContent: false,
                            ),
                      ),
                    ),
                  ParcelsLoaded(:final ParcelsPage page)
                      when page.parcels.isEmpty =>
                    _Scrollable(
                      header: const ParcelsHeader(count: 0),
                      child: const SmartEmptyStateWidget(),
                    ),
                  final ParcelsLoaded loaded => _Content(
                    state: loaded,
                  ),
                },
          ),
        ),
      ),
    );
  }
}

/// Header plus a centered state view, still pull-to-refreshable.
class _Scrollable extends StatelessWidget {
  final Widget header;
  final Widget child;

  const _Scrollable({
    required this.header,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: context.colors.secondary,
      onRefresh: context.read<ParcelsCubit>().loadParcels,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.screen.w),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: <Widget>[
                  header,
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ParcelsLoaded state;

  /// Start fetching the next page this close to the end of the list.
  static const double _loadMoreThreshold = 400;

  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final ParcelsPage page = state.page;
    final List<Parcel> parcels = page.parcels;
    final int inDelivery = parcels
        .where((Parcel p) => p.isOutForDelivery)
        .length;
    final bool showFooter =
        state.hasMore ||
        state.isLoadingMore ||
        state.loadMoreError != null;

    return Column(
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            color: context.colors.secondary,
            onRefresh: context
                .read<ParcelsCubit>()
                .loadParcels,
            // Metrics notifications cover a first page too short to scroll.
            child: NotificationListener<Notification>(
              onNotification: (Notification n) {
                final ScrollMetrics? metrics = switch (n) {
                  ScrollNotification(
                    :final ScrollMetrics metrics,
                  ) =>
                    metrics,
                  ScrollMetricsNotification(
                    :final ScrollMetrics metrics,
                  ) =>
                    metrics,
                  _ => null,
                };
                if (metrics != null &&
                    metrics.axis == Axis.vertical &&
                    metrics.extentAfter <
                        _loadMoreThreshold) {
                  context.read<ParcelsCubit>().loadMore();
                }
                return false;
              },
              child: ListView.separated(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(
                  AppSpacing.screen.w,
                ),
                // Header, summary and list title come first.
                itemCount:
                    parcels.length +
                    3 +
                    (showFooter ? 1 : 0),
                separatorBuilder: (_, int index) =>
                    SizedBox(
                      height: index < 2
                          ? AppSpacing.xl.h
                          : AppSpacing.md.h,
                    ),
                itemBuilder:
                    (
                      BuildContext context,
                      int index,
                    ) => switch (index) {
                      0 => ParcelsHeader(
                        count: page.totalSize,
                      ),
                      1 => ParcelsSummaryCard(
                        totalCount: page.totalSize,
                        inDeliveryCount: inDelivery,
                      ),
                      2 => const ParcelsListHeader(),
                      _ when index - 3 < parcels.length =>
                        _ParcelTile(
                          parcel: parcels[index - 3],
                          station: index - 2,
                        ),
                      _ => _LoadMoreFooter(state: state),
                    },
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.screen.w),
          child: _TourButton(parcels: parcels),
        ),
      ],
    );
  }
}

/// The list's tail while more pages exist: a spinner while fetching, the
/// error with a retry after a failure.
class _LoadMoreFooter extends StatelessWidget {
  final ParcelsLoaded state;

  const _LoadMoreFooter({required this.state});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? error = state.loadMoreError;

    if (error != null) {
      return Column(
        children: <Widget>[
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(
              color: c.textSecondary,
            ),
          ),
          TextButton(
            onPressed: context
                .read<ParcelsCubit>()
                .retryLoadMore,
            child: Text(
              Strings.retry,
              style: AppTextStyles.title(
                color: c.secondary,
              ),
            ),
          ),
        ],
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.sm.h,
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: c.secondary,
        ),
      ),
    );
  }
}

class _ParcelTile extends StatelessWidget {
  final Parcel parcel;

  /// 1-based stop number in the round.
  final int station;

  const _ParcelTile({
    required this.parcel,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    return ParcelRouteCard(
      orderId: parcel.label,
      customerDetails: parcel.deliveryAddress.isEmpty
          ? parcel.recipientLabel
          : '${parcel.recipientLabel} • ${parcel.deliveryAddress}',
      phone: parcel.recipientPhone,
      station: Strings.parcelStation(station),
      status: parcel.statusLabel,
      isInDelivery: parcel.isOutForDelivery,
      onTap: () => _openParcel(context, parcel),
    );
  }
}

/// Starts the first parcel still at the warehouse. Once none are left
/// waiting it continues with the first one already out for delivery.
class _TourButton extends StatelessWidget {
  final List<Parcel> parcels;

  const _TourButton({required this.parcels});

  @override
  Widget build(BuildContext context) {
    final Parcel? waiting = _firstWhere(
      (Parcel p) => p.awaitingStart,
    );
    final Parcel? started = _firstWhere(
      (Parcel p) => p.isOutForDelivery,
    );

    if (waiting == null) {
      return AppButton(
        btnText: Strings.parcelActionContinueTour,
        onPressed: started == null
            ? null
            : () => _openParcel(context, started),
      );
    }
    return BlocSelector<
      ParcelActionCubit,
      ParcelActionState,
      bool
    >(
      selector: (ParcelActionState s) =>
          s is ParcelActionInProgress,
      builder: (BuildContext context, bool inProgress) =>
          AppButton(
            btnText: Strings.parcelActionStartTour,
            isLoading: inProgress,
            onPressed: () => context
                .read<ParcelActionCubit>()
                .startDelivery(waiting),
          ),
    );
  }

  Parcel? _firstWhere(bool Function(Parcel) test) {
    for (final Parcel p in parcels) {
      if (test(p)) return p;
    }
    return null;
  }
}
