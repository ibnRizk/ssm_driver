import 'package:equatable/equatable.dart';

import '../../domain/entities/active_offer.dart';

enum OfferAction { accept, reject }

sealed class IncomingOrderState extends Equatable {
  const IncomingOrderState();

  @override
  List<Object?> get props => [];
}

class IncomingOrderLoading extends IncomingOrderState {
  const IncomingOrderLoading();
}

/// The offer is on screen. [inFlight] is the command awaiting the server,
/// if any — both buttons stay disabled until it answers.
class IncomingOrderReady extends IncomingOrderState {
  final ActiveOffer offer;
  final OfferAction? inFlight;

  const IncomingOrderReady(this.offer, {this.inFlight});

  @override
  List<Object?> get props => [offer, inFlight];
}

/// Accept/reject failed; the offer stays on screen so a network failure can
/// be retried.
class IncomingOrderActionFailed extends IncomingOrderState {
  final ActiveOffer offer;
  final String message;

  const IncomingOrderActionFailed(this.offer, this.message);

  @override
  List<Object?> get props => [offer, message];
}

/// Reading the offer failed (not "no offer" — that is [IncomingOrderUnavailable]).
class IncomingOrderLoadError extends IncomingOrderState {
  final String message;

  const IncomingOrderLoadError(this.message);

  @override
  List<Object?> get props => [message];
}

/// No offer waiting: it expired, was handled, or another Driver won it.
class IncomingOrderUnavailable extends IncomingOrderState {
  const IncomingOrderUnavailable();
}

class IncomingOrderAccepted extends IncomingOrderState {
  const IncomingOrderAccepted();
}

class IncomingOrderRejected extends IncomingOrderState {
  const IncomingOrderRejected();
}
