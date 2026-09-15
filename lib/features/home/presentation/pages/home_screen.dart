import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/cash_summary_bar.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/dashboard_status_pill.dart';
import '../widgets/recent_activity_card.dart';

/// Driver dashboard — the `home` tab's body. `MainScaffold` already supplies
/// the outer Scaffold and bottom nav; this only builds the scrollable
/// content.
///
/// TODO: Replace the mock values below with `HomeCubit`/a real dashboard
/// use case once the driver-stats API exists — same shape `HomeCubit`'s doc
/// comment shows (see `home_cubit.dart`).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String get _driverName => 'محمد';
  static const int _ordersToday = 8;
  static String get _incentivesToday => '0 ر.س';
  static const int _parcelsToday = 4;
  static const String _rating = '4.9';
  static const int _activityParcelCount = 4;
  static const String _activityStore = 'SSM';
  static String get _cashTotal => '640 ر.س';

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
              _Header(driverName: _driverName),
              SizedBox(height: AppSpacing.lg.h),
              DashboardStatusPill(label: Strings.homeStatusOnline),
              SizedBox(height: AppSpacing.lg.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DashboardStatCard(
                      label: Strings.homeStatOrdersLabel,
                      value: '$_ordersToday',
                      background: c.surface,
                      valueColor: c.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: DashboardStatCard(
                      label: Strings.homeStatIncentivesLabel,
                      value: _incentivesToday,
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
                      label: Strings.homeStatParcelsLabel,
                      value: '$_parcelsToday',
                      background: c.surface,
                      valueColor: c.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: DashboardStatCard(
                      label: Strings.homeStatRatingLabel,
                      value: _rating,
                      background: c.secondaryLight,
                      valueColor: c.secondary,
                      icon: Icons.star_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppButton(
                btnText: Strings.homeStartButton,
                onPressed: () {
                  context.pushNamed(AppRoutes.incomingOrderName);
                },
              ),
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
                onTap: () {
                  context.pushNamed(AppRoutes.parcelDetailsName);
                },
              ),
              SizedBox(height: AppSpacing.lg.h),
              CashSummaryBar(
                label: Strings.homeCashTotalLabel,
                amount: _cashTotal,
              ),
            ],
          ),
        ),
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
            style: AppTextStyles.title(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}
