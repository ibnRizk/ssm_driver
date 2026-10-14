import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/push/push_hint.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/repositories/c2c_parcels_repository.dart';

sealed class C2cOfferWatchState extends Equatable {
  const C2cOfferWatchState();

  @override
  List<Object?> get props => [];
}

class C2cOfferWatchIdle extends C2cOfferWatchState {
  const C2cOfferWatchIdle();
}

/// Offers this session hadn't seen before. Never empty.
class C2cOfferWatchFound extends C2cOfferWatchState {
  final List<C2cParcel> offers;

  const C2cOfferWatchFound(this.offers);

  @override
  List<Object?> get props => [offers];
}

/// Spots new C2C offers on any tab: on a foreground C2C push, and every
/// [pollInterval] as the fallback FCM can't guarantee (contract §6).
/// Offers already waiting when it starts are not announced.
class C2cOfferWatchCubit extends Cubit<C2cOfferWatchState> {
  final C2cParcelsRepository _repository;
  final Duration pollInterval;
  StreamSubscription<PushHint>? _pushSubscription;
  Timer? _timer;

  /// Every offer id seen this session; `null` until the first read.
  Set<int>? _known;

  C2cOfferWatchCubit(
    this._repository, {
    Stream<PushHint>? arrivals,
    this.pollInterval = const Duration(seconds: 30),
  }) : super(const C2cOfferWatchIdle()) {
    _pushSubscription = arrivals
        ?.where((PushHint hint) => hint.concerns(PushTarget.c2cParcel))
        .listen((_) => check());
  }

  /// Records the offers already waiting, then starts polling.
  Future<void> start() async {
    if (_timer != null) return;
    _timer = Timer.periodic(pollInterval, (_) => check());
    await check(announce: false);
  }

  Future<void> check({bool announce = true}) async {
    final Either<Failure, List<C2cParcel>> result = await _repository
        .getOffers();
    if (isClosed) return;
    final List<C2cParcel>? offers = result.fold((_) => null, (o) => o);
    if (offers == null) return;

    // Read after the await, so overlapping checks never announce twice.
    final Set<int>? known = _known;
    _known = <int>{...?known, for (final C2cParcel o in offers) o.id};
    if (!announce || known == null) return;

    final List<C2cParcel> fresh = <C2cParcel>[
      for (final C2cParcel o in offers)
        if (!known.contains(o.id)) o,
    ];
    if (fresh.isNotEmpty) emit(C2cOfferWatchFound(fresh));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;
    _pushSubscription?.cancel();
    return super.close();
  }
}
