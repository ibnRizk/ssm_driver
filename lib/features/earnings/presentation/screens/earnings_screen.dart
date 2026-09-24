import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/general_cubit/driver_stats_cubit.dart';
import '../../../../core/general_cubit/driver_stats_state.dart';
import '../../../../core/services/driver_stats/cod_summary.dart';
import '../../../../core/services/driver_stats/incentive_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/dashboard_stat_card.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../widgets/earnings_header.dart';
import '../widgets/earnings_hero_card.dart';
import '../widgets/earnings_info_banner.dart';
import '../widgets/earnings_progress_card.dart';

/// Earnings — the `earnings` tab's body: COD liability and incentive
/// progress (`GET /delivery-man/cod-summary`, `/incentive-summary`).
/// `MainScaffold` already supplies the bottom nav. Pull down to refresh.
///
/// Reads the app-wide [DriverStatsCubit] it shares with Home, so a
/// completed delivery (which refreshes it) shows here too.
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    // Home normally loads the stats first; this covers opening Earnings
    // before that (or after a sign-out reset).
    final DriverStatsCubit stats = context.read<DriverStatsCubit>();
    if (stats.state is DriverStatsInitial) stats.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: c.secondary,
          onRefresh: context.read<DriverStatsCubit>().refreshStats,
          // Always scrollable so pull-to-refresh also works on the
          // loading/error states.
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.all(AppSpacing.screen.w),
                sliver: const SliverToBoxAdapter(child: EarningsHeader()),
              ),
              BlocBuilder<DriverStatsCubit, DriverStatsState>(
                builder: (BuildContext context, DriverStatsState state) =>
                    switch (state) {
                      DriverStatsInitial() || DriverStatsLoading() =>
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: c.secondary,
                            ),
                          ),
                        ),
                      DriverStatsError(:final String message) =>
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: ErrorRetryView(
                            message: message,
                            onRetry: context
                                .read<DriverStatsCubit>()
                                .refreshStats,
                          ),
                        ),
                      DriverStatsLoaded(
                        :final CodSummary cod,
                        :final IncentiveSummary incentive,
                      ) =>
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.screen.w,
                            0,
                            AppSpacing.screen.w,
                            AppSpacing.screen.w,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _Content(cod: cod, incentive: incentive),
                          ),
                        ),
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final CodSummary cod;
  final IncentiveSummary incentive;

  const _Content({required this.cod, required this.incentive});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    // Money stays the server's decimal string — formatted, never computed.
    final String liability = Strings.orderAmount(cod.outstandingLiability);
    final String rewardAmount = Strings.orderAmount(IncentiveRule.rewardAmount);
    // "-" when the server sent no progress counts at all.
    final String perReward = incentive.deliveriesPerReward > 0
        ? '${incentive.deliveriesPerReward}'
        : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EarningsHeroCard(
          deliveriesCount: incentive.completedDeliveries,
          progressLabel: Strings.earningsAwardsCount(incentive.awardsCount),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Row(
          children: <Widget>[
            Expanded(
              child: DashboardStatCard(
                label: Strings.earningsCollectedCashLabel,
                value: liability,
                background: c.secondaryLight,
                valueColor: c.secondary,
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: DashboardStatCard(
                label: Strings.earningsEarnedIncentivesLabel,
                value: Strings.orderAmount(incentive.earnedAmount),
                background: c.surface,
                valueColor: c.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm.h),
        Row(
          children: <Widget>[
            Expanded(
              child: DashboardStatCard(
                label: Strings.earningsDueToAdminLabel,
                value: liability,
                background: c.surface,
                valueColor: c.primary,
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: DashboardStatCard(
                label: Strings.earningsIncentiveRateLabel(perReward),
                value: rewardAmount,
                background: c.secondaryLight,
                valueColor: c.secondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              Strings.earningsProgressLabel,
              style: AppTextStyles.h2(color: c.textPrimary),
            ),
            Text(
              '${incentive.completedTowardNextReward} / $perReward',
              // "8 / 10" must read left-to-right in Arabic too.
              textDirection: TextDirection.ltr,
              style: AppTextStyles.titleSmall(color: c.secondary),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm.h),
        EarningsProgressCard(
          remainingLabel: Strings.earningsRemainingDeliveries(
            incentive.deliveriesRequiredForNextReward,
          ),
          progress: incentive.progressToNextReward,
          description: Strings.earningsIncentiveRule(perReward, rewardAmount),
        ),
        SizedBox(height: AppSpacing.lg.h),
        const EarningsInfoBanner(),
        SizedBox(height: AppSpacing.lg.h),
        // The Driver API has no settlement endpoint (API docs §12):
        // handing cash over is recorded by the admin, not from the app.
        AppButton(
          btnText: Strings.earningsActionSubmit,
          onPressed: () => showAppSnackBar(
            context: context,
            message: Strings.earningsSettlementManual,
            type: ToastType.info,
          ),
        ),
      ],
    );
  }
}
