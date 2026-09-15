import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../home/presentation/widgets/dashboard_stat_card.dart';
import '../widgets/earnings_header.dart';
import '../widgets/earnings_hero_card.dart';
import '../widgets/earnings_info_banner.dart';
import '../widgets/earnings_progress_card.dart';
import 'package:flutter_base/core/utils/values/strings.dart';

/// Earnings — the `earnings` tab's body. `MainScaffold` already supplies the
/// outer Scaffold and bottom nav; this only builds the scrollable content.
///
/// TODO: Replace the mock values below with a real earnings use case once
/// the driver-earnings API exists (same shape as `HomeScreen`'s TODO).
class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  static String get _date => 'Tuesday, Aug 21';
  static const int _deliveriesCompleted = 7;
  static String get _deliveriesProgress => 'أداء جيد اليوم';
  static String get _collectedCash => '640 ر.س';
  static String get _earnedIncentives => '0 ر.س';
  static String get _dueToAdmin => '640 ر.س';
  static String get _incentivePerTenDeliveries => '5 ر.س';
  static const String _incentiveProgressLabel = '10 / 7';
  static String get _remainingDeliveries => '3 توصيلات متبقية';
  static const double _incentiveProgress = 0.7;
  static String get _incentiveDescription => 'عند إكمال 10 توصيلات، تكسب حافز 5 ر.س.';

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
              EarningsHeader(date: _date),
              SizedBox(height: AppSpacing.lg.h),
              EarningsHeroCard(
                deliveriesCount: _deliveriesCompleted,
                progressLabel: _deliveriesProgress,
              ),
              SizedBox(height: AppSpacing.sm.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DashboardStatCard(
                      label: Strings
                          .earningsCollectedCashLabel,
                      value: _collectedCash,
                      background: c.secondaryLight,
                      valueColor: c.secondary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: DashboardStatCard(
                      label: Strings
                          .earningsEarnedIncentivesLabel,
                      value: _earnedIncentives,
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
                      label:
                          Strings.earningsDueToAdminLabel,
                      value: _dueToAdmin,
                      background: c.surface,
                      valueColor: c.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: DashboardStatCard(
                      label: Strings
                          .earningsIncentiveRateLabel,
                      value: _incentivePerTenDeliveries,
                      background: c.secondaryLight,
                      valueColor: c.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl.h),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    Strings.earningsProgressLabel,
                    style: AppTextStyles.h2(
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    _incentiveProgressLabel,
                    style: AppTextStyles.titleSmall(
                      color: c.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              EarningsProgressCard(
                remainingLabel: _remainingDeliveries,
                progress: _incentiveProgress,
                description: _incentiveDescription,
              ),
              SizedBox(height: AppSpacing.lg.h),
              EarningsInfoBanner(),
              SizedBox(height: AppSpacing.lg.h),
              AppButton(
                btnText: Strings.earningsActionSubmit,
                onPressed: () {
                  // TODO: Wire up the cash-settlement flow once it exists.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
