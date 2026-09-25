import 'dart:async';
import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/ringtone/ringtone_service.dart';
import '../../../../core/utils/uuid.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/active_offer.dart';
import '../../domain/repositories/orders_repository.dart';
import 'incoming_order_state.dart';

/// Drives one incoming-offer sheet: counts the offer down, rings while it
/// waits for the Driver, and sends the accept/reject.
///
/// The ringtone stops as soon as the Driver taps accept or reject, when the
/// countdown runs out, when the offer turns out to be gone, and when the
/// cubit closes — whichever comes first.
class IncomingOrderCubit extends Cubit<IncomingOrderState> {
  final OrdersRepository _repository;
  final RingtoneService _ringtone;
  final String Function() _newIdempotencyKey;
  final DateTime Function() _now;

  static const Duration _tickInterval = Duration(seconds: 1);

  /// One key per (action, assignment), kept while the outcome is unknown so
  /// a retry after a timeout replays safely instead of acting twice.
  final Map<(OfferAction, int), String> _pendingKeys =
      <(OfferAction, int), String>{};

  Timer? _ticker;
  DateTime _deadline = DateTime.fromMillisecondsSinceEpoch(0);
  int _totalSeconds = 0;
  int? _assignmentId;
  bool _ringing = false;

  IncomingOrderCubit(
    this._repository,
    this._ringtone, {
    String Function() newIdempotencyKey = generateUuidV4,
    DateTime Function() now = DateTime.now,
  }) : _newIdempotencyKey = newIdempotencyKey,
       _now = now,
       super(const IncomingOrderInitial());

  /// Shows [offer], starts its countdown and starts ringing.
  void start(ActiveOffer offer) => _show(offer);

  Future<void> accept() => _respond(OfferAction.accept);

  Future<void> reject() => _respond(OfferAction.reject);

  /// Counted against a fixed deadline taken from the server's
  /// `remaining_seconds` (API docs §10), not by counting ticks, so a late
  /// timer can't make it drift.
  int get _secondsLeft {
    final int ms = _deadline.difference(_now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  void _show(ActiveOffer offer) {
    final bool isNew = offer.assignmentId != _assignmentId;
    _assignmentId = offer.assignmentId;
    _deadline = _now().add(Duration(seconds: offer.remainingSeconds));
    // A re-read of the same offer keeps the progress bar's scale.
    _totalSeconds = isNew
        ? offer.remainingSeconds
        : math.max(_totalSeconds, offer.remainingSeconds);

    if (offer.remainingSeconds <= 0) {
      _end(const IncomingOrderExpired());
      return;
    }
    emit(
      IncomingOrderReady(
        offer,
        secondsLeft: offer.remainingSeconds,
        totalSeconds: _totalSeconds,
      ),
    );
    _ticker?.cancel();
    _ticker = Timer.periodic(_tickInterval, (_) => _onTick());
    // Same offer re-read after a failed answer: the Driver already
    // answered once, so it stays silent.
    if (isNew) _startRinging();
  }

  void _onTick() {
    final IncomingOrderState current = state;
    if (current is! IncomingOrderOffered) return;
    final OfferAction? inFlight = switch (current) {
      IncomingOrderReady(:final OfferAction? inFlight) => inFlight,
      IncomingOrderActionFailed() => null,
    };
    final int left = _secondsLeft;

    if (left == 0 && inFlight == null) {
      _end(const IncomingOrderExpired());
      return;
    }
    if (left == 0) {
      // An answer is already on its way; its result decides the outcome.
      _stopCountdown();
      _stopRinging();
    }
    emit(switch (current) {
      IncomingOrderReady() => IncomingOrderReady(
        current.offer,
        secondsLeft: left,
        totalSeconds: _totalSeconds,
        inFlight: inFlight,
      ),
      IncomingOrderActionFailed(:final String message) =>
        IncomingOrderActionFailed(
          current.offer,
          message,
          secondsLeft: left,
          totalSeconds: _totalSeconds,
        ),
    });
  }

  Future<void> _respond(OfferAction action) async {
    final ActiveOffer? offer = switch (state) {
      IncomingOrderReady(:final ActiveOffer offer, inFlight: null) => offer,
      IncomingOrderActionFailed(:final ActiveOffer offer) => offer,
      // Nothing to answer, or a command is already in flight.
      _ => null,
    };
    if (offer == null) return;

    // The Driver has answered: silence it now, not when the server replies.
    _stopRinging();
    final (OfferAction, int) command = (action, offer.assignmentId);
    final String key = _pendingKeys.putIfAbsent(command, _newIdempotencyKey);
    emit(
      IncomingOrderReady(
        offer,
        secondsLeft: _secondsLeft,
        totalSeconds: _totalSeconds,
        inFlight: action,
      ),
    );

    final Either<Failure, Unit> result = switch (action) {
      OfferAction.accept => await _repository.acceptOffer(
        offer.assignmentId,
        idempotencyKey: key,
      ),
      OfferAction.reject => await _repository.rejectOffer(
        offer.assignmentId,
        idempotencyKey: key,
      ),
    };
    if (isClosed) return;

    final Failure? failure = result.fold((Failure f) => f, (_) => null);
    if (failure == null) {
      _pendingKeys.remove(command);
      _end(
        action == OfferAction.accept
            ? const IncomingOrderAccepted()
            : const IncomingOrderRejected(),
      );
      return;
    }

    // The offer ran out while the answer was on its way: nothing to retry.
    if (_secondsLeft == 0) {
      _pendingKeys.remove(command);
      _end(const IncomingOrderExpired());
      return;
    }

    emit(
      IncomingOrderActionFailed(
        offer,
        failure.message ?? Strings.somethingWentWrong,
        secondsLeft: _secondsLeft,
        totalSeconds: _totalSeconds,
      ),
    );
    // Only a network failure leaves the outcome unknown. Anything else (404
    // gone, 409 expired/handled/another Driver won) is definitive: drop the
    // key and re-read the offer, as the API docs require on 409.
    if (failure is! NetworkFailure) {
      _pendingKeys.remove(command);
      await _reload();
    }
  }

  Future<void> _reload() async {
    final Either<Failure, ActiveOffer?> result = await _repository
        .getActiveOffer();
    // Closed, or the countdown ended it while the request was out.
    if (isClosed || state is! IncomingOrderOffered) return;
    result.fold(
      (Failure f) =>
          _end(IncomingOrderLoadError(f.message ?? Strings.somethingWentWrong)),
      (ActiveOffer? offer) =>
          offer == null ? _end(const IncomingOrderUnavailable()) : _show(offer),
    );
  }

  /// Every way out of the offer goes through here, so none can leave the
  /// ringtone or the countdown running.
  void _end(IncomingOrderState terminal) {
    _stopCountdown();
    _stopRinging();
    emit(terminal);
  }

  void _stopCountdown() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _startRinging() {
    if (_ringing) return;
    _ringing = true;
    unawaited(_ringtone.play());
  }

  void _stopRinging() {
    if (!_ringing) return;
    _ringing = false;
    unawaited(_ringtone.stop());
  }

  @override
  Future<void> close() {
    _stopCountdown();
    _stopRinging();
    return super.close();
  }
}
