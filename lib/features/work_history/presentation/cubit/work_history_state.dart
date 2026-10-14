import 'package:equatable/equatable.dart';

import '../../domain/entities/work_history.dart';

/// Every state carries the [scope] it is for, so the scope switch always
/// reflects what's on screen.
sealed class WorkHistoryState extends Equatable {
  final HistoryScope scope;

  const WorkHistoryState(this.scope);

  @override
  List<Object?> get props => [scope];
}

class WorkHistoryLoading extends WorkHistoryState {
  const WorkHistoryLoading(super.scope);
}

/// [page] holds everything loaded so far and may be empty.
class WorkHistoryLoaded extends WorkHistoryState {
  final WorkHistoryPage page;

  /// The server has more orders or parcels than [page] holds.
  final bool hasMore;

  final bool isLoadingMore;

  /// Why the last next-page fetch failed; loaded items stay on screen.
  final String? loadMoreError;

  const WorkHistoryLoaded(
    super.scope,
    this.page, {
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  @override
  List<Object?> get props => [
    scope,
    page,
    hasMore,
    isLoadingMore,
    loadMoreError,
  ];
}

class WorkHistoryError extends WorkHistoryState {
  final String message;

  const WorkHistoryError(super.scope, this.message);

  @override
  List<Object?> get props => [scope, message];
}
