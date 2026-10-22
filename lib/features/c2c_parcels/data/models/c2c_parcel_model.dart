import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/c2c_parcel.dart';

/// The C2C item resource (C2C contract §3). Read leniently: the contract
/// shows one sample, and offers/mutation answers aren't specified.
class C2cParcelModel extends C2cParcel {
  const C2cParcelModel({
    required super.id,
    super.offerId,
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
    super.destinationArea,
    super.totalFee = '',
    super.currency = '',
    required super.nextActions,
    required super.requiresOtpToComplete,
    required super.expiresAt,
  });

  /// With [coarse] — every offer, and anything still `driver_assigned` —
  /// only the stops' areas are read; names, phones, addresses and exact
  /// coordinates are dropped even if sent (contract §7).
  ///
  /// The offer endpoint (API update 2026-10-20) returns a *flat* payload that
  /// carries `offer_id`, coarse coordinate objects (`pickup_area`,
  /// `dropoff_area`), and `destination_area`. That shape is detected here and
  /// routed to [_fromOfferJson] automatically.
  factory C2cParcelModel.fromJson(
    Map<String, dynamic> json, {
    bool coarse = false,
  }) {
    // ---- New flat offer payload (offer_id present) -------------------------
    if (json['offer_id'] != null) return C2cParcelModel._fromOfferJson(json);

    // ---- Legacy / full parcel payload -------------------------------------
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
      pickup: _stop(
        json['pickup'] ?? json['sender'],
        coarse: hideDetails,
        flatArea: _areaOf(_prefixed(json, const <String>['pickup', 'sender'])),
      ),
      dropoff: _stop(
        json['dropoff'] ?? json['recipient'],
        coarse: hideDetails,
        flatArea: _areaOf(
          _prefixed(json, const <String>['dropoff', 'recipient', 'delivery']),
        ),
      ),
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

  /// Parses the new flat offer payload introduced in the 2026-10-20 API
  /// update. Only coarse data is populated; exact addresses/contacts are not
  /// sent at this stage.
  ///
  /// ```json
  /// {
  ///   "offer_id": 72, "parcel_id": 501, "status": "dispatching",
  ///   "pickup_area":  { "latitude": 30.05, "longitude": 31.24 },
  ///   "dropoff_area": { "latitude": 30.04, "longitude": 31.23 },
  ///   "destination_area": { "id": 10, "name": "Ramses",
  ///                         "display_name": "رمسيس" },
  ///   "total_fee": 25, "currency": "SAR"
  /// }
  /// ```
  factory C2cParcelModel._fromOfferJson(Map<String, dynamic> json) {
    final Map<String, dynamic> pickupArea = _map(json['pickup_area']);
    final Map<String, dynamic> dropoffArea = _map(json['dropoff_area']);
    final Map<String, dynamic> destArea = _map(json['destination_area']);

    final C2cArea? destinationArea = destArea.isEmpty
        ? null
        : C2cArea(
            id: readInt(destArea['id']),
            name: _string(destArea['name']) ?? '',
            displayName: _string(destArea['display_name']) ?? '',
          );

    return C2cParcelModel(
      id: readInt(json['parcel_id']),
      offerId: readInt(json['offer_id']),
      reference: _string(json['reference']) ?? '',
      status: C2cStatus.fromApi(_string(json['status'])),
      // Offer payloads don't carry status_version or is_terminal.
      statusVersion: 0,
      isTerminal: false,
      title: '',
      description: '',
      category: '',
      weightKg: '',
      isFragile: false,
      pickupInstructions: '',
      deliveryInstructions: '',
      // Only coarse coordinates are exposed; no name/phone/address.
      pickup: C2cStop(
        name: '',
        phone: '',
        address: '',
        area: _string(pickupArea['display_name']) ??
            _string(pickupArea['name']) ??
            _string(json['pickup_area_name']) ??
            '',
        latitude: readDouble(pickupArea['latitude']),
        longitude: readDouble(pickupArea['longitude']),
      ),
      dropoff: C2cStop(
        name: '',
        phone: '',
        address: '',
        area: destinationArea?.label ?? '',
        latitude: readDouble(dropoffArea['latitude']),
        longitude: readDouble(dropoffArea['longitude']),
      ),
      destinationArea: destinationArea,
      totalFee: readDecimal(json['total_fee'], fallback: ''),
      currency: _string(json['currency']) ?? '',
      nextActions: const <C2cAction>[],
      // Offer payloads never include an OTP requirement.
      requiresOtpToComplete: false,
      expiresAt: DateTime.tryParse(_string(json['expires_at']) ?? ''),
    );
  }

  /// [flatArea] is the area read from the item's own `pickup_*` /
  /// `dropoff_*` fields, used when the stop object carries none.
  static C2cStop _stop(
    dynamic raw, {
    required bool coarse,
    required String flatArea,
  }) {
    final Map<String, dynamic> json = _map(raw);
    final dynamic address = json['address'];
    final String ownArea = _areaOf(json);
    final String area = ownArea.isNotEmpty
        ? ownArea
        // e.g. `"address": {"district": …, "city": …}`.
        : address is Map<String, dynamic> && _areaOf(address).isNotEmpty
        ? _areaOf(address)
        : flatArea;
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
      address: switch (address) {
        final Map<String, dynamic> m => _string(m['address']) ?? '',
        _ => _string(address) ?? '',
      },
      area: area,
      latitude: readDouble(json['latitude']),
      longitude: readDouble(json['longitude']),
    );
  }

  /// Fields that already name the whole coarse area ("Al Malaz, Riyadh").
  static const List<String> _areaKeys = <String>[
    'area',
    'approximate_area',
    'area_name',
    'region',
  ];
  static const List<String> _districtKeys = <String>[
    'district',
    'district_name',
    'neighborhood',
    'neighbourhood',
    'zone',
    'zone_name',
  ];
  static const List<String> _cityKeys = <String>[
    'city',
    'city_name',
    'governorate',
  ];

  /// The coarse area from whichever of these fields [json] carries: a
  /// whole-area field, else "district, city". Only ever reads coarse
  /// fields — never a street address, name, phone or coordinate (§7).
  static String _areaOf(Map<String, dynamic> json) {
    final String? area = _firstName(json, _areaKeys);
    if (area != null) return area;
    final String? district = _firstName(json, _districtKeys);
    final String? city = _firstName(json, _cityKeys);
    return <String>{?district, ?city}.join(', ');
  }

  /// The first of [keys] holding a name: a string, or an object with one
  /// (`{"id": 3, "name": "Talkha"}`).
  static String? _firstName(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      final String? name = value is Map<String, dynamic>
          ? _string(value['name']) ?? _string(value['title'])
          : _string(value);
      if (name != null) return name.trim();
    }
    return null;
  }

  /// The item's flat `<prefix>_<field>` entries ("pickup_area",
  /// "sender_city"), keyed by `<field>`. The first prefix wins.
  static Map<String, dynamic> _prefixed(
    Map<String, dynamic> json,
    List<String> prefixes,
  ) => <String, dynamic>{
    for (final String prefix in prefixes.reversed)
      for (final MapEntry<String, dynamic> e in json.entries)
        if (e.key.startsWith('${prefix}_'))
          e.key.substring(prefix.length + 1): e.value,
  };
}

String? _string(dynamic value) =>
    value is String && value.trim().isNotEmpty ? value : null;

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

List<dynamic> _list(dynamic value) => value is List ? value : const <dynamic>[];
