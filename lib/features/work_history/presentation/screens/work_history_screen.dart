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
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/work_history.dart';
import '../cubit/work_history_cubit.dart';
import '../cubit/work_history_state.dart';
import '../history_display.dart';
import '../widgets/history_item_card.dart';

/// The Driver's current and previous store orders and C2C parcels
/// (`GET /delivery-man/work-history`), in two tabs. Pull down to refresh.
class WorkHistoryScreen extends StatelessWidget {
  const WorkHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocProvider<WorkHistoryCubit>(
      create: (_) => ServiceLocator.instance<WorkHistoryCubit>()..load(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: c.background,
          appBar: SimpleAppBar(
            title: Strings.workHistoryTitle,
            onBack: () => context.pop(),
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(AppSpacing.screen.w),
                  child: const _ScopeSwitch(),
                ),
                const Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScopeSwitch extends StatelessWidget {
  const _ScopeSwitch();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WorkHistoryCubit, WorkHistoryState, HistoryScope>(
      selector: (WorkHistoryState s) => s.scope,
      builder: (BuildContext context, HistoryScope scope) =>
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<HistoryScope>(
              showSelectedIcon: false,
              segments: <ButtonSegment<HistoryScope>>[
                ButtonSegment<HistoryScope>(
                  value: HistoryScope.current,
                  label: Text(Strings.workHistoryCurrent),
                ),
                ButtonSegment<HistoryScope>(
                  value: HistoryScope.previous,
                  label: Text(Strings.workHistoryPrevious),
                ),
              ],
              selected: <HistoryScope>{scope},
              onSelectionChanged: (Set<HistoryScope> selected) => context
                  .read<WorkHistoryCubit>()
                  .load(scope: selected.single),
            ),
          ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocBuilder<WorkHistoryCubit, WorkHistoryState>(
      builder: (BuildContext context, WorkHistoryState state) =>
          switch (state) {
            WorkHistoryLoading() => Center(
              child: CircularProgressIndicator(color: c.secondary),
            ),
            WorkHistoryError(:final String message) => ErrorRetryView(
              message: message,
              onRetry: () => context.read<WorkHistoryCubit>().load(),
            ),
            final WorkHistoryLoaded loaded => _Tabs(state: loaded),
          },
    );
  }
}

class _Tabs extends StatelessWidget {
  final WorkHistoryLoaded state;

  const _Tabs({required this.state});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final WorkHistoryPage page = state.page;

    return Column(
      children: <Widget>[
        TabBar(
          labelColor: c.secondary,
          unselectedLabelColor: c.textSecondary,
          indicatorColor: c.secondary,
          labelStyle: AppTextStyles.title(),
          tabs: <Widget>[
            Tab(text: Strings.workHistoryOrdersTab(page.ordersTotal)),
            Tab(text: Strings.workHistoryParcelsTab(page.parcelsTotal)),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: <Widget>[
              _HistoryList(
                state: state,
                count: page.orders.length,
                itemBuilder: (BuildContext context, int i) =>
                    _OrderTile(order: page.orders[i]),
              ),
              _HistoryList(
                state: state,
                count: page.parcels.length,
                itemBuilder: (BuildContext context, int i) =>
                    _ParcelTile(parcel: page.parcels[i]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One tab's list: pull-to-refresh, an empty view, and a load-more tail.
class _HistoryList extends StatelessWidget {
  final WorkHistoryLoaded state;
  final int count;
  final IndexedWidgetBuilder itemBuilder;

  /// Start fetching the next page this close to the end of the list.
  static const double _loadMoreThreshold = 400;

  const _HistoryList({
    required this.state,
    required this.count,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final WorkHistoryCubit cubit = context.read<WorkHistoryCubit>();
    final bool showFooter =
        state.hasMore || state.isLoadingMore || state.loadMoreError != null;

    return RefreshIndicator(
      color: c.secondary,
      onRefresh: cubit.load,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification n) {
          if (n.metrics.axis == Axis.vertical &&
              n.metrics.extentAfter < _loadMoreThreshold) {
            cubit.loadMore();
          }
          return false;
        },
        child: count == 0 && !showFooter
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSpacing.xxl.w),
                children: <Widget>[
                  Text(
                    Strings.workHistoryEmpty,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSpacing.screen.w),
                itemCount: count + (showFooter ? 1 : 0),
                separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm.h),
                itemBuilder: (BuildContext context, int i) => i < count
                    ? itemBuilder(context, i)
                    : _LoadMoreFooter(state: state),
              ),
      ),
    );
  }
}

/// A spinner while the next page loads; the error with a retry after a
/// failure.
class _LoadMoreFooter extends StatelessWidget {
  final WorkHistoryLoaded state;

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
            style: AppTextStyles.body(color: c.textSecondary),
          ),
          TextButton(
            onPressed: context.read<WorkHistoryCubit>().retryLoadMore,
            child: Text(
              Strings.retry,
              style: AppTextStyles.title(color: c.secondary),
            ),
          ),
        ],
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
      child: Center(child: CircularProgressIndicator(color: c.secondary)),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final HistoryOrder order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return HistoryItemCard(
      icon: Icons.receipt_long_outlined,
      title: order.title,
      route: order.route,
      status: order.status.label,
      isFinal: order.status.isFinal,
      detail: order.paymentLabel,
      date: order.dateLabel,
    );
  }
}

/// An active C2C parcel opens its job screen, where the next step can be
/// taken; the history re-reads on return.
class _ParcelTile extends StatelessWidget {
  final HistoryParcel parcel;

  const _ParcelTile({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return HistoryItemCard(
      icon: Icons.home_work_outlined,
      title: parcel.label,
      route: parcel.route,
      status: parcel.status.label,
      isFinal: parcel.status.isFinal,
      detail: parcel.title,
      date: parcel.dateLabel,
      onTap: parcel.isActiveWork ? () => _open(context) : null,
    );
  }

  Future<void> _open(BuildContext context) async {
    final WorkHistoryCubit cubit = context.read<WorkHistoryCubit>();
    await context.pushNamed<void>(
      AppRoutes.c2cJobName,
      pathParameters: <String, String>{'id': '${parcel.id}'},
    );
    if (!cubit.isClosed) await cubit.load();
  }
}
