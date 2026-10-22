import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/push/push_hint.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/repositories/c2c_parcels_repository.dart';
import 'c2c_board_state.dart';

/// The Parcels tab's house-to-house segment: waiting offers and accepted
/// jobs. A C2C push in [pushHints] re-reads both (contract §6).
class C2cBoardCubit extends Cubit<C2cBoardState> {
  final C2cParcelsRepository _repository;
  StreamSubscription<PushHint>? _pushSubscription;

  /// Bumped by every [load], so a slower older answer is dropped.
  int _generation = 0;

  C2cBoardCubit(this._repository, {Stream<PushHint>? pushHints})
    : super(const C2cBoardLoading()) {
    _pushSubscription = pushHints
        ?.where((PushHint hint) => hint.concerns(PushTarget.c2cParcel))
        .listen((_) {
          if (state is! C2cBoardLoading) load();
        });
  }

  /// A loaded board stays on screen while refreshing.
  Future<void> load() async {
    final int generation = ++_generation;
    if (state is! C2cBoardLoaded) emit(const C2cBoardLoading());

    final List<Either<Failure, List<C2cParcel>>> results = await Future.wait(
      <Future<Either<Failure, List<C2cParcel>>>>[
        _repository.getOffers(),
        _repository.getActiveJobs(),
      ],
    );
    if (isClosed || generation != _generation) return;

    final Failure? failure = results
        .map((r) => r.fold((Failure f) => f, (_) => null))
        .whereType<Failure>()
        .firstOrNull;
    if (failure != null) {
      emit(C2cBoardError(failure.message ?? Strings.somethingWentWrong));
      return;
    }
    List<C2cParcel> listOf(Either<Failure, List<C2cParcel>> r) =>
        r.getOrElse(() => const <C2cParcel>[]);
    final List<C2cParcel> jobs = listOf(results[1]);
    final Set<int> jobIds = <int>{for (final C2cParcel j in jobs) j.id};
    emit(
      C2cBoardLoaded(
        // An offer the Driver just accepted may linger in the offers feed.
        offers: <C2cParcel>[
          for (final C2cParcel o in listOf(results[0]))
            if (!jobIds.contains(o.id)) o,
        ],
        jobs: jobs,
      ),
    );
  }

  /// Removes an offer from the loaded list (e.g. after it is rejected).
  void removeOffer({int? parcelId, int? offerId}) {
    if (state is! C2cBoardLoaded) return;
    final C2cBoardLoaded current = state as C2cBoardLoaded;
    final List<C2cParcel> updatedOffers = current.offers.where((C2cParcel o) {
      if (offerId != null && o.offerId == offerId) return false;
      if (parcelId != null && o.id == parcelId) return false;
      return true;
    }).toList();
    emit(C2cBoardLoaded(offers: updatedOffers, jobs: current.jobs));
  }

  @override
  Future<void> close() {
    _pushSubscription?.cancel();
    return super.close();
  }
}
