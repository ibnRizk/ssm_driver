import 'package:equatable/equatable.dart';

/// Order lifecycle: `current-work` returns work only in the first three;
/// [delivered] is what a successful completion answers with.
enum WorkStatus {
  driverAccepted('driver_accepted'),
  pickedUp('picked_up'),
  outForDelivery('out_for_delivery'),
  delivered('delivered');

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

  /// Decimal string exactly as the API sent it ("125.50") — display only,
  /// never parse to a float, recompute or send back (API docs §12).
  final String codAmount;

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

  /// This order after a confirmed lifecycle transition.
  CurrentWork withStatus(WorkStatus? status, int statusVersion) => CurrentWork(
    assignmentId: assignmentId,
    orderId: orderId,
    status: status,
    statusVersion: statusVersion,
    storeName: storeName,
    storeAddress: storeAddress,
    storeLatitude: storeLatitude,
    storeLongitude: storeLongitude,
    customerName: customerName,
    customerPhone: customerPhone,
    deliveryAddress: deliveryAddress,
    deliveryLatitude: deliveryLatitude,
    deliveryLongitude: deliveryLongitude,
    orderNote: orderNote,
    isCashOnDelivery: isCashOnDelivery,
    codAmount: codAmount,
  );

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
