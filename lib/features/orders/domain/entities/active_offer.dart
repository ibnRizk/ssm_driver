import 'package:equatable/equatable.dart';

/// The dispatch offer currently shown to this Driver
/// (`GET /delivery-man/active-offer`). Customer contact details are
/// intentionally absent until the offer is accepted.
class ActiveOffer extends Equatable {
  final int assignmentId;
  final int orderId;

  /// Seconds left when the server answered. Count down from this — never
  /// from a blind local 30-second timer (API docs §10).
  final int remainingSeconds;

  /// `null` when the server sent no distance snapshot.
  final int? distanceMeters;

  final String pickupName;
  final String pickupAddress;
  final String deliveryAddress;
  final bool isCashOnDelivery;

  /// Decimal string ("125.00") — display only.
  final String codAmount;

  const ActiveOffer({
    required this.assignmentId,
    required this.orderId,
    required this.remainingSeconds,
    required this.distanceMeters,
    required this.pickupName,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.isCashOnDelivery,
    required this.codAmount,
  });

  @override
  List<Object?> get props => [
    assignmentId,
    orderId,
    remainingSeconds,
    distanceMeters,
    pickupName,
    pickupAddress,
    deliveryAddress,
    isCashOnDelivery,
    codAmount,
  ];
}
