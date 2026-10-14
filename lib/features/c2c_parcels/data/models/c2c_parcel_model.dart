import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/c2c_parcel.dart';

/// The C2C item resource (C2C contract §3). Read leniently: the contract
/// shows one sample, and offers/mutation answers aren't specified.
class C2cParcelModel extends C2cParcel {
  const C2cParcelModel({
    required super.id,
    required super.reference,
    required super.status,
    required super.statusVersion,
    required super.isTerminal,
    required super.title,
    required super.description,
    required super.category,
    required super.weightKg,
    required super.isFragile,
    required super.pickupInstructions,
    required super.deliveryInstructions,
    required super.pickup,
    required super.dropoff,
    required super.nextActions,
    required super.requiresOtpToComplete,
    required super.expiresAt,
  });

  /// With [coarse] — every offer, and anything still `driver_assigned` —
  /// only the stops' areas are read; names, phones, addresses and exact
  /// coordinates are dropped even if sent (contract §7).
  factory C2cParcelModel.fromJson(
    Map<String, dynamic> json, {
    bool coarse = false,
  }) {
    final C2cStatus? status = C2cStatus.fromApi(_string(json['status']));
    final bool hideDetails = coarse || status == C2cStatus.driverAssigned;
    final Map<String, dynamic> parcel = _map(json['parcel']);
    final dynamic requiresOtp = json['requires_otp_to_complete'];

    return C2cParcelModel(
      id: readInt(json['parcel_id'] ?? json['id']),
      reference: _string(json['reference']) ?? '',
      status: status,
      statusVersion: readInt(json['status_version']),
      isTerminal: json['is_terminal'] == true,
      title: _string(parcel['title']) ?? '',
      description: _string(parcel['description']) ?? '',
      category: _string(parcel['category']) ?? '',
      weightKg: parcel['weight_kg'] == null
          ? ''
          : readDecimal(parcel['weight_kg'], fallback: ''),
      isFragile: parcel['is_fragile'] == true,
      pickupInstructions: hideDetails
          ? ''
          : _string(parcel['pickup_instructions']) ?? '',
      deliveryInstructions: hideDetails
          ? ''
          : _string(parcel['delivery_instructions']) ?? '',
      pickup: _stop(json['pickup'], coarse: hideDetails),
      dropoff: _stop(json['dropoff'], coarse: hideDetails),
      nextActions: <C2cAction>[
        for (final dynamic a in _list(json['next_actions']))
          if (C2cAction.fromApi(_string(a)) case final C2cAction action)
            action,
      ],
      // The contract's completion carries the recipient's code (§5), so
      // only an explicit `false` skips it.
      requiresOtpToComplete: requiresOtp is! bool || requiresOtp,
      expiresAt: DateTime.tryParse(_string(json['expires_at']) ?? ''),
    );
  }

  static C2cStop _stop(dynamic raw, {required bool coarse}) {
    final Map<String, dynamic> json = _map(raw);
    final String area =
        _string(json['area']) ??
        _string(json['approximate_area']) ??
        _string(json['district']) ??
        _string(json['zone_name']) ??
        _string(json['city']) ??
        '';
    if (coarse) {
      return C2cStop(
        name: '',
        phone: '',
        address: '',
        area: area,
        latitude: null,
        longitude: null,
      );
    }
    return C2cStop(
      name: _string(json['name']) ?? '',
      phone: _string(json['phone']) ?? '',
      address: _string(json['address']) ?? '',
      area: area,
      latitude: readDouble(json['latitude']),
      longitude: readDouble(json['longitude']),
    );
  }
}

String? _string(dynamic value) =>
    value is String && value.trim().isNotEmpty ? value : null;

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

List<dynamic> _list(dynamic value) => value is List ? value : const <dynamic>[];
