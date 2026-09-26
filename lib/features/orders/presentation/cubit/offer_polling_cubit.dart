import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/log_utils.dart';
import '../../domain/entities/active_offer.dart';
import '../../domain/repositories/orders_repository.dart';
import 'offer_polling_state.dart';

/// Watches `GET /delivery-man/active-offer` while the Driver is online.
///
/// The app has no push channel yet, so polling is how offers arrive
/// (API docs §17: "ONLINE_IDLE → poll active offer"). Offers last ~30 s,
/// so the default interval leaves most of that window to respond.
class OfferPollingCubit extends Cubit<OfferPollingState> {
  final OrdersRepository _repository;
  final Duration interval;

  Timer? _timer;
  bool _inFlight = false;
  int? _lastAnnouncedAssignmentId;

  OfferPollingCubit(
    this._repository, {
    this.interval = const Duration(seconds: 5),
  }) : super(const OfferPollingIdle());

  bool get isPolling => _timer != null;

  /// Checks right away, then every [interval]. No-op when already polling.
  void start() {
    if (isPolling) return;
    _timer = Timer.periodic(interval, (_) => checkNow());
    checkNow();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _lastAnnouncedAssignmentId = null;
    if (!isClosed) emit(const OfferPollingIdle());
  }

  Future<void> checkNow() async {
    if (!isPolling || _inFlight) return;
    _inFlight = true;
    final Either<Failure, ActiveOffer?> result = await _repository
        .getActiveOffer();
    _inFlight = false;
    // Stopped (went offline) while the request was in flight.
    if (isClosed || !isPolling) return;

    result.fold(
      // Deliberately not surfaced: the next tick retries, and a snackbar
      // every few seconds during a network blip would bury the dashboard.
      // Logged so a persistent failure (e.g. a parsing bug) is not silent.
      (Failure failure) =>
          Log.w('OfferPollingCubit: active-offer poll failed: $failure'),
      (ActiveOffer? offer) {
        if (offer == null) {
          _lastAnnouncedAssignmentId = null;
          emit(const OfferPollingIdle());
        } else if (offer.assignmentId != _lastAnnouncedAssignmentId) {
          _lastAnnouncedAssignmentId = offer.assignmentId;
          emit(OfferPollingFound(offer));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;
    return super.close();
  }
}
