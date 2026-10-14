import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/work_history.dart';

// `c2c_parcels` items follow the C2C contract §3; `orders` items aren't
// documented, so they're read leniently with the current-work field names.
// Contact fields (phones, e-mails) are deliberately never read.

class HistoryOrderModel extends HistoryOrder {
  const HistoryOrderModel({
    required super.orderId,
    required super.status,
    required super.storeName,
    required super.deliveryAddress,
    required super.isCashOnDelivery,
    required super.amount,
    required super.date,
  });

  factory HistoryOrderModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> pickup = _map(json['pickup'] ?? json['store']);
    final dynamic rawAddress = json['delivery_address'];

    return HistoryOrderModel(
      orderId: readInt(json['order_id'] ?? json['id']),
      status: HistoryStatus.fromApi(
        _string(json['ssm_status']) ?? _string(json['order_status']),
      ),
      storeName: _string(pickup['name']) ?? _string(json['store_name']) ?? '',
      deliveryAddress: rawAddress is String
          ? rawAddress
          : _string(_map(rawAddress)['address']) ?? '',
      isCashOnDelivery: json['payment_method'] == 'cash_on_delivery',
      amount: readDecimal(json['cod_amount'] ?? json['order_amount']),
      date: _dateOf(json),
    );
  }
}

class HistoryParcelModel extends HistoryParcel {
  const HistoryParcelModel({
    required super.id,
    required super.reference,
    required super.status,
    required super.isTerminal,
    required super.title,
    required super.senderName,
    required super.recipientName,
    required super.date,
  });

  /// The C2C item resource (C2C contract §3) — not the warehouse parcel
  /// shape. A `driver_assigned` item is still an offer, so no names.
  factory HistoryParcelModel.fromJson(Map<String, dynamic> json) {
    final HistoryStatus? status = HistoryStatus.fromApi(
      _string(json['status']),
    );
    final bool isOffer = status == HistoryStatus.assigned;
    return HistoryParcelModel(
      id: readInt(json['id'] ?? json['parcel_id']),
      reference: _string(json['reference']) ?? '',
      status: status,
      isTerminal: json['is_terminal'] == true,
      title: _string(_map(json['parcel'])['title']) ?? '',
      senderName: isOffer ? '' : _string(_map(json['pickup'])['name']) ?? '',
      recipientName: isOffer
          ? ''
          : _string(_map(json['dropoff'])['name']) ?? '',
      date: _dateOf(json),
    );
  }
}

/// `{"scope", "orders": [...], "c2c_parcels": [...], "totals": {...}}`.
/// A total the server omits falls back to the items in this page.
WorkHistoryPage workHistoryPageFromJson(Map<String, dynamic> json) {
  final List<HistoryOrder> orders = <HistoryOrder>[
    for (final dynamic item in _list(json['orders']))
      if (item is Map<String, dynamic>) HistoryOrderModel.fromJson(item),
  ];
  final List<HistoryParcel> parcels = <HistoryParcel>[
    for (final dynamic item in _list(json['c2c_parcels']))
      if (item is Map<String, dynamic>) HistoryParcelModel.fromJson(item),
  ];
  final Map<String, dynamic> totals = _map(json['totals']);

  return WorkHistoryPage(
    orders: orders,
    parcels: parcels,
    ordersTotal: readInt(totals['orders'], fallback: orders.length),
    parcelsTotal: readInt(totals['c2c_parcels'], fallback: parcels.length),
  );
}

DateTime? _dateOf(Map<String, dynamic> json) {
  for (final String key in <String>[
    'delivered_at',
    'completed_at',
    'updated_at',
    'created_at',
  ]) {
    final DateTime? date = DateTime.tryParse(_string(json[key]) ?? '');
    if (date != null) return date;
  }
  return null;
}

String? _string(dynamic value) =>
    value is String && value.trim().isNotEmpty ? value : null;

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

List<dynamic> _list(dynamic value) => value is List ? value : const <dynamic>[];
