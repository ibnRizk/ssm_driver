import 'package:equatable/equatable.dart';

/// Lifecycle states in which `GET /delivery-man/current-work` returns work.
enum WorkStatus {
  driverAccepted('driver_accepted'),
  pickedUp('picked_up'),
  outForDelivery('out_for_delivery');

  final String apiValue;
  const WorkStatus(this.apiValue);

  /// `null` for a missing or unrecognised value.
  static WorkStatus? fromApi(String? value) {
    for (final WorkStatus status in values) {
      if (status.apiValue == value) return status;
    }
    return null;
  }
}

/// The Driver's accepted, not-yet-delivered order.
class CurrentWork extends Equatable {
  final int assignmentId;
  final int orderId;
  final WorkStatus? status;
  final int statusVersion;

  final String storeName;
  final String storeAddress;
  final double? storeLatitude;
  final double? storeLongitude;

  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  final String? orderNote;
  final bool isCashOnDelivery;

  /// Server-authoritative; display only, never recompute or send back.
  final num codAmount;

  const CurrentWork({
    required this.assignmentId,
    required this.orderId,
    required this.status,
    required this.statusVersion,
    required this.storeName,
    required this.storeAddress,
    required this.storeLatitude,
    required this.storeLongitude,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.orderNote,
    required this.isCashOnDelivery,
    required this.codAmount,
  });

  /// The store still has to be visited — pickup hasn't been confirmed.
  bool get awaitingPickup => status == WorkStatus.driverAccepted;

  @override
  List<Object?> get props => [
    assignmentId,
    orderId,
    status,
    statusVersion,
    storeName,
    storeAddress,
    storeLatitude,
    storeLongitude,
    customerName,
    customerPhone,
    deliveryAddress,
    deliveryLatitude,
    deliveryLongitude,
    orderNote,
    isCashOnDelivery,
    codAmount,
  ];
}
