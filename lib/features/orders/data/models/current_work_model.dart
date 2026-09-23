import '../../domain/entities/current_work.dart';

class CurrentWorkModel extends CurrentWork {
  const CurrentWorkModel({
    required super.assignmentId,
    required super.orderId,
    required super.status,
    required super.statusVersion,
    required super.storeName,
    required super.storeAddress,
    required super.storeLatitude,
    required super.storeLongitude,
    required super.customerName,
    required super.customerPhone,
    required super.deliveryAddress,
    required super.deliveryLatitude,
    required super.deliveryLongitude,
    required super.orderNote,
    required super.isCashOnDelivery,
    required super.codAmount,
  });

  /// Parses the work object itself (the caller unwraps any `work` envelope).
  /// Coordinates and `cod_amount` arrive as either numbers or numeric
  /// strings, so both are accepted.
  factory CurrentWorkModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> pickup = _map(json['pickup']);
    final Map<String, dynamic> customer = _map(json['customer']);
    final Map<String, dynamic> coordinates = _map(json['delivery_coordinates']);
    final dynamic rawAddress = json['delivery_address'];
    final Map<String, dynamic> address = _map(rawAddress);

    return CurrentWorkModel(
      assignmentId: _toNum(json['assignment_id'])?.toInt() ?? 0,
      orderId: _toNum(json['order_id'])?.toInt() ?? 0,
      status: WorkStatus.fromApi(json['ssm_status'] as String?),
      statusVersion: _toNum(json['ssm_status_version'])?.toInt() ?? 0,
      storeName: pickup['name'] as String? ?? '',
      storeAddress: pickup['address'] as String? ?? '',
      storeLatitude: _toNum(pickup['latitude'])?.toDouble(),
      storeLongitude: _toNum(pickup['longitude'])?.toDouble(),
      customerName:
          customer['name'] as String? ??
          address['contact_person_name'] as String? ??
          '',
      customerPhone:
          customer['phone'] as String? ??
          address['contact_person_number'] as String? ??
          '',
      deliveryAddress: rawAddress is String
          ? rawAddress
          : address['address'] as String? ?? '',
      deliveryLatitude: _toNum(
        coordinates['latitude'] ?? address['latitude'],
      )?.toDouble(),
      deliveryLongitude: _toNum(
        coordinates['longitude'] ?? address['longitude'],
      )?.toDouble(),
      orderNote: json['order_note'] as String?,
      isCashOnDelivery: json['payment_method'] == 'cash_on_delivery',
      codAmount: _toNum(json['cod_amount']) ?? 0,
    );
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map<String, dynamic> ? value : const <String, dynamic>{};

  static num? _toNum(dynamic value) => switch (value) {
    final num n => n,
    final String s => num.tryParse(s),
    _ => null,
  };
}
