import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/uuid.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/active_offer.dart';
import '../../domain/repositories/orders_repository.dart';
import 'incoming_order_state.dart';

/// Screen-scoped cubit for [IncomingOrderScreen]: shows the active offer and
/// sends the Driver's accept/reject.
class IncomingOrderCubit extends Cubit<IncomingOrderState> {
  final OrdersRepository _repository;
  final String Function() _newIdempotencyKey;

  /// One key per (action, assignment), kept while the outcome is unknown so
  /// a retry after a timeout replays safely instead of acting twice.
  final Map<(OfferAction, int), String> _pendingKeys =
      <(OfferAction, int), String>{};

  IncomingOrderCubit(
    this._repository, {
    String Function() newIdempotencyKey = generateUuidV4,
  }) : _newIdempotencyKey = newIdempotencyKey,
       super(const IncomingOrderLoading());

  /// Shows [offer] immediately when the caller already has it (home
  /// polling); otherwise reads it from the server.
  Future<void> start([ActiveOffer? offer]) async {
    if (offer != null) {
      emit(IncomingOrderReady(offer));
      return;
    }
    await loadOffer();
  }

  /// Re-reads the offer — on open, when the countdown runs out, and after a
  /// conflict. The current offer stays on screen while it loads.
  Future<void> loadOffer() async {
    if (state is! IncomingOrderReady && state is! IncomingOrderActionFailed) {
      emit(const IncomingOrderLoading());
    }
    final Either<Failure, ActiveOffer?> result = await _repository
        .getActiveOffer();
    if (isClosed) return;
    result.fold(
      (Failure f) =>
          emit(IncomingOrderLoadError(f.message ?? Strings.somethingWentWrong)),
      (ActiveOffer? offer) => emit(
        offer == null
            ? const IncomingOrderUnavailable()
            : IncomingOrderReady(offer),
      ),
    );
  }

  Future<void> accept() => _respond(OfferAction.accept);

  Future<void> reject() => _respond(OfferAction.reject);

  Future<void> _respond(OfferAction action) async {
    final ActiveOffer? offer = switch (state) {
      IncomingOrderReady(:final ActiveOffer offer, inFlight: null) => offer,
      IncomingOrderActionFailed(:final ActiveOffer offer) => offer,
      // Nothing to answer, or a command is already in flight.
      _ => null,
    };
    if (offer == null) return;

    final (OfferAction, int) command = (action, offer.assignmentId);
    final String key = _pendingKeys.putIfAbsent(command, _newIdempotencyKey);
    emit(IncomingOrderReady(offer, inFlight: action));

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
      emit(
        action == OfferAction.accept
            ? const IncomingOrderAccepted()
            : const IncomingOrderRejected(),
      );
      return;
    }

    emit(
      IncomingOrderActionFailed(
        offer,
        failure.message ?? Strings.somethingWentWrong,
      ),
    );
    // Only a network failure leaves the outcome unknown. Anything else (404
    // gone, 409 expired/handled/another Driver won) is definitive: drop the
    // key and re-read the offer, as the API docs require on 409.
    if (failure is! NetworkFailure) {
      _pendingKeys.remove(command);
      await loadOffer();
    }
  }
}
