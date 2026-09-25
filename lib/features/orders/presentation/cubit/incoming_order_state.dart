import 'package:equatable/equatable.dart';

import '../../domain/entities/active_offer.dart';

enum OfferAction { accept, reject }

sealed class IncomingOrderState extends Equatable {
  const IncomingOrderState();

  @override
  List<Object?> get props => [];
}

/// Before [IncomingOrderCubit.start].
class IncomingOrderInitial extends IncomingOrderState {
  const IncomingOrderInitial();
}

/// An offer on screen, counting down: [secondsLeft] of the [totalSeconds]
/// it had when it arrived.
sealed class IncomingOrderOffered extends IncomingOrderState {
  final ActiveOffer offer;
  final int secondsLeft;
  final int totalSeconds;

  const IncomingOrderOffered(
    this.offer, {
    required this.secondsLeft,
    required this.totalSeconds,
  });

  /// 1 when the offer arrived, 0 when it runs out.
  double get progress => totalSeconds <= 0 ? 0 : secondsLeft / totalSeconds;
}

/// [inFlight] is the command awaiting the server, if any — both buttons
/// stay disabled until it answers.
class IncomingOrderReady extends IncomingOrderOffered {
  final OfferAction? inFlight;

  const IncomingOrderReady(
    super.offer, {
    required super.secondsLeft,
    required super.totalSeconds,
    this.inFlight,
  });

  @override
  List<Object?> get props => [offer, secondsLeft, totalSeconds, inFlight];
}

/// Accept/reject failed; the offer stays on screen, still counting down, with
/// [message] shown until the Driver answers again.
class IncomingOrderActionFailed extends IncomingOrderOffered {
  final String message;

  const IncomingOrderActionFailed(
    super.offer,
    this.message, {
    required super.secondsLeft,
    required super.totalSeconds,
  });

  @override
  List<Object?> get props => [offer, message, secondsLeft, totalSeconds];
}

/// Re-reading the offer failed (not "no offer" — that is [IncomingOrderUnavailable]).
class IncomingOrderLoadError extends IncomingOrderState {
  final String message;

  const IncomingOrderLoadError(this.message);

  @override
  List<Object?> get props => [message];
}

/// No offer waiting: it was handled or another Driver won it.
class IncomingOrderUnavailable extends IncomingOrderState {
  const IncomingOrderUnavailable();
}

/// The countdown ran out before the Driver answered.
class IncomingOrderExpired extends IncomingOrderState {
  const IncomingOrderExpired();
}

class IncomingOrderAccepted extends IncomingOrderState {
  const IncomingOrderAccepted();
}

class IncomingOrderRejected extends IncomingOrderState {
  const IncomingOrderRejected();
}
