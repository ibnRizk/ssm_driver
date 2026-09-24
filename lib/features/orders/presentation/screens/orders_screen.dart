import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../domain/entities/current_work.dart';
import '../cubit/current_work_cubit.dart';
import '../cubit/current_work_state.dart';
import '../widgets/no_active_work_view.dart';
import '../work_status_label.dart';

/// The `orders` tab: the Driver's current accepted order
/// (`GET /delivery-man/current-work`). Tapping it opens the trip screen.
/// Pull down to refresh.
///
/// Reads the app-wide [CurrentWorkCubit], so an order accepted or completed
/// from the Home tab is reflected here without a manual refresh.
///
/// The API has no order-history endpoint yet, so there is no history list.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // First build of this session's shell: whatever the app-wide cubit
    // holds may belong to a previous session, so don't show it.
    context.read<CurrentWorkCubit>().loadCurrentWork(keepContent: false);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(
          Strings.navOrders,
          style: AppTextStyles.h2(color: c.textPrimary),
        ),
        backgroundColor: c.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: c.secondary,
        onRefresh: context.read<CurrentWorkCubit>().loadCurrentWork,
        // Always scrollable so pull-to-refresh also works on the
        // empty/error states.
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.all(AppSpacing.screen.w),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: BlocBuilder<CurrentWorkCubit, CurrentWorkState>(
                  builder: (BuildContext context, CurrentWorkState state) =>
                      switch (state) {
                        CurrentWorkInitial() || CurrentWorkLoading() => Center(
                          child: CircularProgressIndicator(color: c.secondary),
                        ),
                        CurrentWorkError(:final String message) =>
                          ErrorRetryView(
                            message: message,
                            onRetry: context
                                .read<CurrentWorkCubit>()
                                .loadCurrentWork,
                          ),
                        CurrentWorkEmpty() => const NoActiveWorkView(),
                        CurrentWorkLoaded(:final CurrentWork work) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              Strings.orderCurrentWorkTitle,
                              style: AppTextStyles.h2(color: c.textPrimary),
                            ),
                            SizedBox(height: AppSpacing.sm.h),
                            _CurrentWorkCard(
                              work: work,
                              onTap: () =>
                                  context.pushNamed(AppRoutes.orderTripName),
                            ),
                          ],
                        ),
                      },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentWorkCard extends StatelessWidget {
  final CurrentWork work;
  final VoidCallback onTap;

  const _CurrentWorkCard({required this.work, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final WorkStatus? status = work.status;

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    work.orderLabel,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.title(color: c.textPrimary),
                  ),
                  if (status != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm.w,
                        vertical: AppSpacing.xxs.h,
                      ),
                      decoration: BoxDecoration(
                        color: c.secondaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        status.label,
                        style: AppTextStyles.label(color: c.secondaryDark),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              _InfoLine(icon: Icons.storefront_outlined, text: work.storeName),
              SizedBox(height: AppSpacing.xs.h),
              _InfoLine(
                icon: Icons.location_on_outlined,
                text: work.deliveryAddress,
              ),
              SizedBox(height: AppSpacing.md.h),
              Divider(color: c.border, height: 1),
              SizedBox(height: AppSpacing.md.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    work.isCashOnDelivery
                        ? Strings.orderCodCashLabel
                        : Strings.orderPaymentPrepaid,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
                  if (work.isCashOnDelivery)
                    Text(
                      work.paymentLabel,
                      style: AppTextStyles.title(color: c.primary),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        Icon(icon, size: 16.r, color: c.textHint),
        SizedBox(width: AppSpacing.xs.w),
        Expanded(
          child: Text(
            text.isEmpty ? '-' : text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}
