import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/active_offer.dart';

class ActiveOfferModel extends ActiveOffer {
  const ActiveOfferModel({
    required super.assignmentId,
    required super.orderId,
    required super.remainingSeconds,
    required super.distanceMeters,
    required super.pickupName,
    required super.pickupAddress,
    required super.deliveryAddress,
    required super.isCashOnDelivery,
    required super.codAmount,
  });

  /// Parses the offer object itself (the caller unwraps any `offer`
  /// envelope). `delivery_address` arrives as an address object (with
  /// string coordinates) but is accepted as a plain string too.
  factory ActiveOfferModel.fromJson(Map<String, dynamic> json) {
    final dynamic pickup = json['pickup'];
    final Map<String, dynamic> pickupMap = pickup is Map<String, dynamic>
        ? pickup
        : const <String, dynamic>{};
    final dynamic address = json['delivery_address'];
    final dynamic distance = json['distance_meters_snapshot'];
    final int remaining = readInt(json['remaining_seconds']);

    return ActiveOfferModel(
      assignmentId: readInt(json['assignment_id']),
      orderId: readInt(json['order_id']),
      remainingSeconds: remaining < 0 ? 0 : remaining,
      distanceMeters: distance == null ? null : readDouble(distance)?.round(),
      pickupName: pickupMap['name'] as String? ?? '',
      pickupAddress: pickupMap['address'] as String? ?? '',
      deliveryAddress: switch (address) {
        final String s => s,
        final Map<String, dynamic> m => m['address'] as String? ?? '',
        _ => '',
      },
      isCashOnDelivery: json['payment_method'] == 'cash_on_delivery',
      codAmount: readDecimal(json['cod_amount']),
    );
  }
}
