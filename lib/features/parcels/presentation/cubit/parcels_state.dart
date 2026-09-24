import 'package:equatable/equatable.dart';

import '../../domain/entities/parcel.dart';

sealed class ParcelsState extends Equatable {
  const ParcelsState();

  @override
  List<Object?> get props => [];
}

class ParcelsInitial extends ParcelsState {
  const ParcelsInitial();
}

class ParcelsLoading extends ParcelsState {
  const ParcelsLoading();
}

/// [page] holds every parcel loaded so far and may be empty — the Driver
/// has no active parcels.
class ParcelsLoaded extends ParcelsState {
  final ParcelsPage page;

  /// The server has more parcels than [page] holds.
  final bool hasMore;

  /// The next page is being fetched.
  final bool isLoadingMore;

  /// Why the last next-page fetch failed; the loaded parcels stay on screen.
  final String? loadMoreError;

  const ParcelsLoaded(
    this.page, {
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  @override
  List<Object?> get props => [page, hasMore, isLoadingMore, loadMoreError];
}

class ParcelsError extends ParcelsState {
  final String message;

  const ParcelsError(this.message);

  @override
  List<Object?> get props => [message];
}
