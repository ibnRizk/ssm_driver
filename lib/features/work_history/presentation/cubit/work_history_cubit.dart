import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/work_history.dart';
import '../../domain/repositories/work_history_repository.dart';
import 'work_history_state.dart';

/// The Driver's unified work history (`GET /delivery-man/work-history`):
/// store orders and C2C parcels for one [HistoryScope], [pageSize] of each
/// per request.
class WorkHistoryCubit extends Cubit<WorkHistoryState> {
  final WorkHistoryRepository _repository;

  static const int pageSize = 20;

  /// The 1-based page [loadMore] fetches next.
  int _nextPage = 1;

  /// Bumped by every [load], so a late answer for an older scope or refresh
  /// is dropped instead of shown.
  int _generation = 0;

  WorkHistoryCubit(this._repository)
    : super(const WorkHistoryLoading(HistoryScope.current));

  /// (Re)loads the first page of [scope] — the current one when omitted.
  /// A refresh of the same scope keeps the loaded list on screen.
  Future<void> load({HistoryScope? scope}) async {
    final HistoryScope target = scope ?? state.scope;
    final int generation = ++_generation;
    if (target != state.scope || state is! WorkHistoryLoaded) {
      emit(WorkHistoryLoading(target));
    }

    final result = await _repository.getWorkHistory(
      scope: target,
      page: 1,
      limit: pageSize,
    );
    if (isClosed || generation != _generation) return;
    result.fold(
      (Failure f) =>
          emit(WorkHistoryError(target, f.message ?? Strings.somethingWentWrong)),
      (WorkHistoryPage page) {
        _nextPage = 2;
        emit(WorkHistoryLoaded(target, page, hasMore: _hasMore(page, page)));
      },
    );
  }

  /// Appends the next page. A no-op while one is in flight, when everything
  /// is loaded, or after a failure — [retryLoadMore] is the way back.
  Future<void> loadMore() async {
    final WorkHistoryState current = state;
    if (current is! WorkHistoryLoaded ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.loadMoreError != null) {
      return;
    }
    await _fetchNextPage(current);
  }

  Future<void> retryLoadMore() async {
    final WorkHistoryState current = state;
    if (current is! WorkHistoryLoaded || current.isLoadingMore) return;
    await _fetchNextPage(current);
  }

  Future<void> _fetchNextPage(WorkHistoryLoaded from) async {
    final int generation = _generation;
    emit(
      WorkHistoryLoaded(
        from.scope,
        from.page,
        hasMore: from.hasMore,
        isLoadingMore: true,
      ),
    );

    final result = await _repository.getWorkHistory(
      scope: from.scope,
      page: _nextPage,
      limit: pageSize,
    );
    if (isClosed || generation != _generation) return;
    result.fold(
      (Failure f) => emit(
        WorkHistoryLoaded(
          from.scope,
          from.page,
          hasMore: from.hasMore,
          loadMoreError: f.message ?? Strings.somethingWentWrong,
        ),
      ),
      (WorkHistoryPage next) {
        _nextPage++;
        final WorkHistoryPage merged = from.page.appending(next);
        emit(
          WorkHistoryLoaded(
            from.scope,
            merged,
            hasMore: _hasMore(merged, next),
          ),
        );
      },
    );
  }

  /// An empty page ends the list even if the totals say otherwise, so stale
  /// totals can't cause endless requests.
  bool _hasMore(WorkHistoryPage loaded, WorkHistoryPage lastFetched) =>
      !lastFetched.isEmpty && loaded.hasMore;
}
