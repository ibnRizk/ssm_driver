import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/general_cubit/driver_stats_cubit.dart';
import '../../../../core/general_cubit/driver_stats_state.dart';
import '../../../../core/services/location/location_failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/dashboard_stat_card.dart';
import '../../../../injection_container.dart';
import '../../../orders/presentation/cubit/offer_polling_cubit.dart';
import '../../../orders/presentation/cubit/offer_polling_state.dart';
import '../cubit/availability_cubit.dart';
import '../cubit/availability_state.dart';
import '../cubit/location_tracking_cubit.dart';
import '../cubit/location_tracking_state.dart';
import '../widgets/cash_summary_bar.dart';
import '../widgets/dashboard_status_pill.dart';
import '../widgets/recent_activity_card.dart';

/// Driver dashboard — the `home` tab's body. `MainScaffold` already supplies
/// the outer Scaffold and bottom nav; this only builds the scrollable
/// content.
///
/// Stats come from the app-wide [DriverStatsCubit]; the online switch,
/// location + heartbeat reporting and offer polling are scoped to this
/// screen, which
/// lives for the whole signed-in session (the shell keeps its tabs alive).
/// While the Driver is online, a new dispatch offer opens the incoming-order
/// screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<AvailabilityCubit>(
          create: (_) => ServiceLocator.instance<AvailabilityCubit>()..load(),
        ),
        BlocProvider<LocationTrackingCubit>(
          create: (_) => ServiceLocator.instance<LocationTrackingCubit>(),
        ),
        BlocProvider<OfferPollingCubit>(
          create: (_) => ServiceLocator.instance<OfferPollingCubit>(),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  // TODO: Replace with the profile name/location once the dashboard shows
  // them; the parcel activity card waits on the parcels API.
  static String get _driverName => 'محمد';
  static const int _activityParcelCount = 4;
  static const String _activityStore = 'SSM';

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // DriverStatsCubit is app-wide, so the first load happens here, per session.
    context.read<DriverStatsCubit>().loadStats();
    // Back in the foreground (e.g. from the location settings the banner
    // opened): report and look for offers now instead of on the next tick.
    // Both are no-ops while offline.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        context.read<LocationTrackingCubit>().reportNow();
        context.read<OfferPollingCubit>().checkNow();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final AvailabilityCubit availability = context.read<AvailabilityCubit>();
    await Future.wait(<Future<void>>[
      context.read<DriverStatsCubit>().refreshStats(),
      if (availability.state.isOnline == null) availability.load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<AvailabilityCubit, AvailabilityState>(
          listener: (BuildContext context, AvailabilityState state) {
            if (state is AvailabilityError) {
              showAppSnackBar(
                context: context,
                message: state.message,
                type: ToastType.error,
              );
            }
            // Presence reporting and offers only matter for an online Driver
            // (API docs §9, §17); both follow the server-confirmed flag.
            final LocationTrackingCubit tracking = context
                .read<LocationTrackingCubit>();
            final OfferPollingCubit polling = context.read<OfferPollingCubit>();
            switch (state.isOnline) {
              case true:
                tracking.start();
                polling.start();
              case false:
                tracking.stop();
                polling.stop();
              case null:
                break;
            }
          },
        ),
        BlocListener<OfferPollingCubit, OfferPollingState>(
          listener: (BuildContext context, OfferPollingState state) {
            if (state is OfferPollingFound) {
              context.pushNamed(
                AppRoutes.incomingOrderName,
                extra: state.offer,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: RefreshIndicator(
            color: c.secondary,
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.screen.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Header(driverName: _driverName),
                  SizedBox(height: AppSpacing.lg.h),
                  const _AvailabilityStatus(),
                  const _LocationIssueBanner(),
                  SizedBox(height: AppSpacing.lg.h),
                  const _DashboardStats(),
                  SizedBox(height: AppSpacing.lg.h),
                  const _AvailabilityButton(),
                  SizedBox(height: AppSpacing.xl.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        Strings.homeRecentActivityTitle,
                        style: AppTextStyles.h2(color: c.textPrimary),
                      ),
                      TextButton(
                        onPressed: () {
                          context.goNamed(AppRoutes.ordersName);
                        },
                        child: Text(
                          Strings.homeViewAll,
                          style: AppTextStyles.titleSmall(color: c.secondary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  RecentActivityCard(
                    title: Strings.homeActivityTitle,
                    subtitle: Strings.homeActivitySubtitle(
                      _activityParcelCount,
                      _activityStore,
                    ),
                    // A round, not one parcel — open the Parcels tab.
                    onTap: () => context.goNamed(AppRoutes.parcelsName),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  const _CashDueBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailabilityStatus extends StatelessWidget {
  const _AvailabilityStatus();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailabilityCubit, AvailabilityState>(
      builder: (BuildContext context, AvailabilityState state) =>
          DashboardStatusPill(
            isOnline: state.isOnline ?? false,
            label: switch (state) {
              AvailabilityLoading() => Strings.loading,
              _ => switch (state.isOnline) {
                true => Strings.homeStatusOnline,
                false => Strings.homeStatusOffline,
                null => Strings.homeStatusUnavailable,
              },
            },
          ),
    );
  }
}

/// Shown while online but the location can't reach dispatch — without it the
/// Driver gets no offers, so the fix is one tap away.
class _LocationIssueBanner extends StatelessWidget {
  const _LocationIssueBanner();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocBuilder<LocationTrackingCubit, LocationTrackingState>(
      builder: (BuildContext context, LocationTrackingState state) {
        if (state is! TrackingBlocked) return const SizedBox.shrink();
        final LocationIssue issue = state.issue;

        return Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm.h),
          child: Container(
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.md.w,
              end: AppSpacing.xs.w,
              top: AppSpacing.xs.h,
              bottom: AppSpacing.xs.h,
            ),
            decoration: BoxDecoration(
              color: c.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.location_off_rounded,
                  color: c.secondary,
                  size: 20.r,
                ),
                SizedBox(width: AppSpacing.xs.w),
                Expanded(
                  child: Text(
                    LocationFailure(issue).message,
                    style: AppTextStyles.caption(color: c.secondaryDark),
                  ),
                ),
                TextButton(
                  onPressed: context.read<LocationTrackingCubit>().resolveIssue,
                  child: Text(switch (issue) {
                    LocationIssue.permissionDenied =>
                      Strings.locationActionAllow,
                    LocationIssue.permissionDeniedForever =>
                      Strings.locationActionOpenSettings,
                    LocationIssue.serviceDisabled =>
                      Strings.locationActionTurnOn,
                    LocationIssue.unavailable => Strings.retry,
                  }, style: AppTextStyles.titleSmall(color: c.secondary)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Start/stop receiving orders. Local state only flips once the server
/// confirms; a refused "go offline" (active work) keeps the Driver online.
class _AvailabilityButton extends StatelessWidget {
  const _AvailabilityButton();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocBuilder<AvailabilityCubit, AvailabilityState>(
      builder: (BuildContext context, AvailabilityState state) {
        final AvailabilityCubit cubit = context.read<AvailabilityCubit>();
        return switch (state) {
          AvailabilityLoading() => AppButton(
            btnText: Strings.homeStartButton,
            isLoading: true,
            onPressed: null,
          ),
          AvailabilityError(isOnline: null) => AppButton(
            btnText: Strings.retry,
            onPressed: cubit.load,
          ),
          _ => AppButton(
            btnText: state.isOnline == true
                ? Strings.homeStopButton
                : Strings.homeStartButton,
            color: state.isOnline == true ? c.primary : null,
            isLoading: state is AvailabilityLoaded && state.isUpdating,
            onPressed: cubit.toggle,
          ),
        };
      },
    );
  }
}

class _DashboardStats extends StatelessWidget {
  const _DashboardStats();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocBuilder<DriverStatsCubit, DriverStatsState>(
      builder: (BuildContext context, DriverStatsState state) {
        // Placeholders until the numbers arrive (or after a failure).
        final DriverStatsLoaded? data =
            state is DriverStatsLoaded ? state : null;
        const String none = '-';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: DashboardStatCard(
                    label: Strings.homeStatCompletedLabel,
                    value: '${data?.incentive.completedDeliveries ?? none}',
                    background: c.surface,
                    valueColor: c.primary,
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: DashboardStatCard(
                    label: Strings.earningsEarnedIncentivesLabel,
                    value: data == null
                        ? none
                        : Strings.orderAmount(data.incentive.earnedAmount),
                    background: c.secondaryLight,
                    valueColor: c.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: DashboardStatCard(
                    label: Strings.homeStatCodCollectionsLabel,
                    value: '${data?.cod.collectionsCount ?? none}',
                    background: c.surface,
                    valueColor: c.primary,
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: DashboardStatCard(
                    label: Strings.homeStatNextRewardLabel,
                    value:
                        '${data?.incentive.deliveriesRequiredForNextReward ?? none}',
                    background: c.secondaryLight,
                    valueColor: c.secondary,
                    icon: Icons.star_rounded,
                  ),
                ),
              ],
            ),
            if (state is DriverStatsError) ...<Widget>[
              SizedBox(height: AppSpacing.xs.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      state.message,
                      style: AppTextStyles.caption(color: c.error),
                    ),
                  ),
                  TextButton(
                    onPressed: context.read<DriverStatsCubit>().refreshStats,
                    child: Text(
                      Strings.retry,
                      style: AppTextStyles.titleSmall(color: c.secondary),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Outstanding COD liability — cash collected and still owed to the
/// platform.
class _CashDueBar extends StatelessWidget {
  const _CashDueBar();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DriverStatsCubit, DriverStatsState, String?>(
      selector: (DriverStatsState state) =>
          state is DriverStatsLoaded ? state.cod.outstandingLiability : null,
      builder: (BuildContext context, String? liability) => CashSummaryBar(
        label: Strings.earningsDueToAdminLabel,
        amount: liability == null ? '-' : Strings.orderAmount(liability),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String driverName;

  const _Header({required this.driverName});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Strings.homeGreeting(driverName),
                style: AppTextStyles.h1(color: c.primary),
              ),
              SizedBox(height: AppSpacing.xxs.h),
              Text(
                Strings.homeDateLocation,
                style: AppTextStyles.body(color: c.textSecondary),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Container(
          width: 48.r,
          height: 48.r,
          decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            driverName.characters.first,
            style: AppTextStyles.title(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
