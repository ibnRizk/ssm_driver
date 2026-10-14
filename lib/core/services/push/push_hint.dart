import 'package:equatable/equatable.dart';

/// What a push is about — decides what to refetch and where a tap lands.
/// [parcel] is a warehouse parcel; [c2cParcel] a customer-to-customer one,
/// which has its own API (C2C contract §6).
enum PushTarget { offer, order, parcel, c2cParcel, unknown }

/// A push reduced to a hint (API docs §8, §14): the payload is never trusted
/// as state, it only says which REST resource to re-read.
///
/// The backend doesn't document its FCM data keys, so [PushHint.fromData]
/// reads the usual type keys loosely and falls back to whichever id the
/// payload carries. Anything unrecognised becomes [PushTarget.unknown],
/// which refreshes everything rather than nothing.
class PushHint extends Equatable {
  final PushTarget target;

  /// The parcel, order or assignment id, when the payload names one.
  final int? id;

  const PushHint(this.target, {this.id});

  static const List<String> _typeKeys = <String>[
    'type',
    'event',
    'notification_type',
    'action',
    'category',
  ];

  factory PushHint.fromData(Map<String, dynamic> data) {
    final String type = _typeKeys
        .map((String key) => data[key])
        .whereType<Object>()
        .map((Object value) => '$value'.toLowerCase())
        .join(' ');
    final PushTarget target = _targetOf(type, data);
    return PushHint(target, id: _idOf(target, data));
  }

  /// Whether a [resource] should be refetched for this push.
  bool concerns(PushTarget resource) =>
      target == resource || target == PushTarget.unknown;

  /// Checked most specific first: "ssm.c2c_parcel.offer_created" is a C2C
  /// push, "parcel_order_updated" a parcel push, "offer_assigned" an offer.
  static PushTarget _targetOf(String type, Map<String, dynamic> data) {
    if (type.contains('c2c')) return PushTarget.c2cParcel;
    if (type.contains('parcel')) return PushTarget.parcel;
    if (type.contains('offer')) return PushTarget.offer;
    if (type.contains('order') ||
        type.contains('assign') ||
        type.contains('work')) {
      return PushTarget.order;
    }
    if (data.containsKey('c2c_parcel_id')) return PushTarget.c2cParcel;
    if (data.containsKey('parcel_id')) return PushTarget.parcel;
    if (data.containsKey('assignment_id')) return PushTarget.offer;
    if (data.containsKey('order_id')) return PushTarget.order;
    return PushTarget.unknown;
  }

  static int? _idOf(PushTarget target, Map<String, dynamic> data) {
    final Object? raw = switch (target) {
      PushTarget.parcel => data['parcel_id'] ?? data['id'],
      PushTarget.c2cParcel =>
        data['c2c_parcel_id'] ?? data['parcel_id'] ?? data['id'],
      PushTarget.order => data['order_id'] ?? data['id'],
      PushTarget.offer => data['assignment_id'] ?? data['id'],
      PushTarget.unknown => null,
    };
    // FCM delivers every data value as a string.
    return switch (raw) {
      int value => value,
      String value => int.tryParse(value),
      _ => null,
    };
  }

  @override
  List<Object?> get props => <Object?>[target, id];
}
