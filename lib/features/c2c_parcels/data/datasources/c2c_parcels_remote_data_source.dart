import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/location/device_location.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../models/c2c_parcel_model.dart';

/// Raw Driver C2C parcel calls (C2C contract §2–§4). Throws [AppException]s;
/// the repository turns them into failures.
///
/// The contract documents the paths and the item resource only, so the
/// envelopes below are read leniently.
class C2cParcelsRemoteDataSource {
  final DioConsumer _consumer;

  const C2cParcelsRemoteDataSource(this._consumer);

  static const String idempotencyHeader = 'Idempotency-Key';

  /// How many current jobs one read covers — far above a Driver's capacity.
  static const int activeJobsLimit = 50;

  /// Accepts a bare list, `{"offers"|"data": [...]}`, `{"offer": {...}|null}`
  /// or a single offer object. Always parsed coarse.
  Future<List<C2cParcelModel>> getOffers() async {
    final dynamic body = await _consumer.get(ApiEndpoints.c2cOffers);
    if (body == null || body == '') return const <C2cParcelModel>[];

    final dynamic items = switch (body) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map when map['offers'] is List =>
        map['offers'],
      final Map<String, dynamic> map when map['data'] is List => map['data'],
      final Map<String, dynamic> map when map.containsKey('offer') =>
        <dynamic>[map['offer']],
      final Map<String, dynamic> map when _isItem(map) => <dynamic>[map],
      // e.g. {"message": "No offers"} — nothing to offer, not an offer #0.
      Map<String, dynamic>() => const <dynamic>[],
      _ => throw const ServerException(),
    };
    return <C2cParcelModel>[
      for (final dynamic item in items as List<dynamic>)
        if (item is Map<String, dynamic> && _hasId(item))
          C2cParcelModel.fromJson(item, coarse: true),
    ];
  }

  /// The `c2c_parcels` array of `work-history?scope=current` — the only
  /// documented list of the Driver's C2C jobs (contract §3).
  Future<List<C2cParcelModel>> getCurrentJobs() async {
    final dynamic body = await _consumer.get(
      ApiEndpoints.workHistory,
      queryParameters: <String, dynamic>{
        'scope': 'current',
        'limit': activeJobsLimit,
        'offset': 1,
      },
    );
    if (body is! Map<String, dynamic>) throw const ServerException();
    final dynamic items = body['c2c_parcels'];
    if (items is! List) return const <C2cParcelModel>[];
    return <C2cParcelModel>[
      for (final dynamic item in items)
        if (item is Map<String, dynamic> && _hasId(item))
          C2cParcelModel.fromJson(item),
    ];
  }

  /// `null` when the answer carries no parcel resource.
  Future<C2cParcelModel?> runAction(
    int parcelId,
    C2cAction action, {
    required String idempotencyKey,
    String? otp,
  }) async {
    final dynamic body = await _consumer.post(
      ApiEndpoints.c2cAction(parcelId, _pathOf(action)),
      body: <String, dynamic>{
        if (action == C2cAction.complete && otp != null) 'otp': otp,
      },
      headers: <String, dynamic>{idempotencyHeader: idempotencyKey},
    );
    if (body is! Map<String, dynamic>) return null;
    // The item's own `parcel` key is its description block (no `status`),
    // so only an object that looks like the item is taken.
    for (final dynamic candidate in <dynamic>[
      body['data'],
      body['c2c_parcel'],
      body['parcel'],
      body,
    ]) {
      if (candidate is Map<String, dynamic> && _isItem(candidate)) {
        return C2cParcelModel.fromJson(candidate);
      }
    }
    return null;
  }

  /// Same body as the general location ping; identity comes from the token.
  Future<void> sendLocation(int parcelId, DeviceLocation location) =>
      _consumer.post(
        ApiEndpoints.c2cLocation(parcelId),
        body: <String, dynamic>{
          'latitude': location.latitude,
          'longitude': location.longitude,
          if (location.accuracy != null) 'accuracy': location.accuracy,
          if (location.heading != null) 'heading': location.heading,
          if (location.speed != null && location.speed! <= 200)
            'speed': location.speed,
        },
      );

  /// Preferred rejection path (API update 2026-10-20).
  ///
  /// Uses [offerId] in the URL, NOT the parcel ID. [idempotencyKey] MUST be
  /// a freshly generated UUID — do not reuse keys across different offers.
  /// [reason] defaults to `"busy"` but may be any server-accepted value.
  Future<void> rejectOffer(
    int offerId, {
    required String idempotencyKey,
    String reason = 'busy',
  }) =>
      _consumer.post(
        ApiEndpoints.c2cRejectOffer(offerId),
        body: <String, dynamic>{'reason': reason},
        headers: <String, dynamic>{idempotencyHeader: idempotencyKey},
      );

  static String _pathOf(C2cAction action) => switch (action) {
    C2cAction.accept => 'accept',
    C2cAction.arrivePickup => 'arrive-pickup',
    C2cAction.pickup => 'pickup',
    C2cAction.outForDelivery => 'out-for-delivery',
    C2cAction.complete => 'complete',
  };

  static bool _hasId(Map<String, dynamic> json) =>
      json['id'] != null || json['parcel_id'] != null;

  static bool _isItem(Map<String, dynamic> json) =>
      _hasId(json) && json['status'] is String;
}
