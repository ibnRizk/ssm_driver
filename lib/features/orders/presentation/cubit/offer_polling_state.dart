import 'package:equatable/equatable.dart';

import '../../domain/entities/active_offer.dart';

sealed class OfferPollingState extends Equatable {
  const OfferPollingState();

  @override
  List<Object?> get props => [];
}

/// No offer waiting (or not polling).
class OfferPollingIdle extends OfferPollingState {
  const OfferPollingIdle();
}

/// A new offer arrived. Emitted once per assignment, so a still-open offer
/// isn't pushed on screen again on every poll.
class OfferPollingFound extends OfferPollingState {
  final ActiveOffer offer;

  const OfferPollingFound(this.offer);

  @override
  List<Object?> get props => [offer];
}
