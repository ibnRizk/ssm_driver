import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/push/push_hint.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/repositories/parcels_repository.dart';
import 'parcel_assignment_state.dart';

/// Spots parcels newly assigned to the Driver while the app is open.
///
/// A foreground parcel push is only a hint — the backend doesn't say which
/// push types mean "assigned" — so it re-reads the active list and reports
/// the parcels whose ids this session hadn't seen. A status-change push for
/// a known parcel therefore announces nothing.
class ParcelAssignmentCubit extends Cubit<ParcelAssignmentState> {
  final ParcelsRepository _repository;
  StreamSubscription<PushHint>? _pushSubscription;

  /// How many active parcels one check reads. Wide enough that a new parcel
  /// isn't paged out of view on a normal round.
  static const int watchLimit = 50;

  /// Every active parcel id seen this session; `null` until the first read
  /// succeeds. Only grows, so a parcel paged out and back isn't "new".
  Set<int>? _known;

  ParcelAssignmentCubit(this._repository, {Stream<PushHint>? arrivals})
    : super(const ParcelAssignmentIdle()) {
    _pushSubscription = arrivals
        ?.where((PushHint hint) => hint.concerns(PushTarget.parcel))
        .listen((_) => _check(announce: true));
  }

  /// Records the parcels already assigned, so they're never announced.
  Future<void> start() => _check(announce: false);

  Future<void> _check({required bool announce}) async {
    final Either<Failure, ParcelsPage> result = await _repository.getParcels(
      page: 1,
      limit: watchLimit,
    );
    if (isClosed) return;
    // A failed read keeps what's known; the next push tries again.
    final ParcelsPage? page = result.fold((_) => null, (ParcelsPage p) => p);
    if (page == null) return;

    // Read after the await, so overlapping checks never announce twice.
    final Set<int>? known = _known;
    _known = <int>{...?known, for (final Parcel p in page.parcels) p.id};
    // Without a baseline, everything would look new: this read becomes it.
    if (!announce || known == null) return;

    final List<Parcel> fresh = <Parcel>[
      for (final Parcel p in page.parcels)
        if (!known.contains(p.id) && !p.isDelivered) p,
    ];
    if (fresh.isNotEmpty) emit(ParcelAssignmentFound(fresh));
  }

  @override
  Future<void> close() {
    _pushSubscription?.cancel();
    return super.close();
  }
}
