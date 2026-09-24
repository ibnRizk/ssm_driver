import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/repositories/parcels_repository.dart';
import 'parcels_state.dart';

/// The Driver's active parcel round (`GET /delivery-man/parcels`), loaded
/// [pageSize] parcels at a time.
class ParcelsCubit extends Cubit<ParcelsState> {
  final ParcelsRepository _repository;

  static const int pageSize = 20;

  /// The 1-based page [loadMore] fetches next.
  int _nextPage = 1;

  /// Bumped by every [loadParcels], so a next-page answer that arrives
  /// after a refresh is dropped instead of appended to the new list.
  int _generation = 0;

  ParcelsCubit(this._repository) : super(const ParcelsInitial());

  /// (Re)loads the first page. With [keepContent] a loaded list stays on
  /// screen while refreshing (pull-to-refresh, returning from details)
  /// instead of flashing a spinner.
  Future<void> loadParcels({bool keepContent = true}) async {
    final int generation = ++_generation;
    if (!keepContent || state is! ParcelsLoaded) emit(const ParcelsLoading());

    final result = await _repository.getParcels(page: 1, limit: pageSize);
    if (isClosed || generation != _generation) return;
    result.fold(
      (Failure f) => emit(ParcelsError(f.message ?? Strings.somethingWentWrong)),
      (ParcelsPage page) {
        _nextPage = 2;
        emit(ParcelsLoaded(page, hasMore: _hasMore(page, page)));
      },
    );
  }

  /// Appends the next page. A no-op while one is in flight, when everything
  /// is loaded, or after a failure — scrolling must not hammer a failing
  /// server; [retryLoadMore] is the explicit way back.
  Future<void> loadMore() async {
    final ParcelsState current = state;
    if (current is! ParcelsLoaded ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.loadMoreError != null) {
      return;
    }
    await _fetchNextPage(current);
  }

  Future<void> retryLoadMore() async {
    final ParcelsState current = state;
    if (current is! ParcelsLoaded || current.isLoadingMore) return;
    await _fetchNextPage(current);
  }

  Future<void> _fetchNextPage(ParcelsLoaded from) async {
    final int generation = _generation;
    emit(ParcelsLoaded(from.page, hasMore: from.hasMore, isLoadingMore: true));

    final result = await _repository.getParcels(
      page: _nextPage,
      limit: pageSize,
    );
    // Re-read: applyParcel may have changed the list meanwhile.
    final ParcelsState latest = state;
    if (isClosed || generation != _generation || latest is! ParcelsLoaded) {
      return;
    }
    result.fold(
      (Failure f) => emit(
        ParcelsLoaded(
          latest.page,
          hasMore: latest.hasMore,
          loadMoreError: f.message ?? Strings.somethingWentWrong,
        ),
      ),
      (ParcelsPage next) {
        _nextPage++;
        final ParcelsPage merged = latest.page.appending(next);
        emit(ParcelsLoaded(merged, hasMore: _hasMore(merged, next)));
      },
    );
  }

  /// Reflects a server-confirmed change (e.g. a started delivery) without
  /// another round trip.
  void applyParcel(Parcel parcel) {
    final ParcelsState current = state;
    if (current is ParcelsLoaded) {
      emit(
        ParcelsLoaded(
          current.page.replacing(parcel),
          hasMore: current.hasMore,
          isLoadingMore: current.isLoadingMore,
          loadMoreError: current.loadMoreError,
        ),
      );
    }
  }

  /// An empty page ends the list even if the total says otherwise, so a
  /// stale `total_size` can't cause endless requests.
  bool _hasMore(ParcelsPage loaded, ParcelsPage lastFetched) =>
      lastFetched.parcels.isNotEmpty &&
      loaded.parcels.length < loaded.totalSize;
}
