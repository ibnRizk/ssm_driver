import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/entities/parcel_proof.dart';
import '../models/parcel_model.dart';

/// Raw Driver parcel API calls (API docs §13). Throws [AppException]s
/// (mapped by [DioConsumer], including the `{"errors": [...]}` envelope);
/// the repository turns them into failures.
class ParcelsRemoteDataSource {
  final DioConsumer _consumer;

  const ParcelsRemoteDataSource(this._consumer);

  /// Paginated: `{"data": [...], "total_size", "limit", "offset"}`.
  ///
  /// `offset` is the 1-based *page number*, not an item index: the
  /// documented first-page answer is `"offset": 1` with every item present.
  Future<ParcelsPage> getParcels({
    ParcelListFilter filter = ParcelListFilter.active,
    required int page,
    required int limit,
  }) async {
    final dynamic body = await _consumer.get(
      ApiEndpoints.parcels,
      queryParameters: <String, dynamic>{
        'status': filter.apiValue,
        'limit': limit,
        'offset': page,
      },
    );
    if (body is! Map<String, dynamic>) throw const ServerException();

    final dynamic data = body['data'];
    if (data is! List) throw const ServerException();
    final List<ParcelModel> parcels = <ParcelModel>[
      for (final dynamic item in data)
        if (item is Map<String, dynamic>) ParcelModel.fromJson(item),
    ];
    return ParcelsPage(
      parcels: parcels,
      totalSize: readInt(body['total_size'], fallback: parcels.length),
    );
  }

  Future<ParcelModel> getParcelDetails(int parcelId) async =>
      _parcelOf(await _consumer.get(ApiEndpoints.parcelDetails(parcelId)));

  Future<ParcelModel> startDelivery(int parcelId) async => _parcelOf(
    await _consumer.post(ApiEndpoints.startParcelDelivery(parcelId)),
  );

  Future<ParcelModel> completeParcel(
    int parcelId, {
    required ParcelProof proof,
    required bool codCollected,
  }) async => _parcelOf(
    await _consumer.post(
      ApiEndpoints.completeParcel(parcelId),
      body: <String, dynamic>{
        ...switch (proof) {
          ParcelOtpProof(:final String otp) => <String, dynamic>{
            'proof_type': 'OTP',
            'otp': otp,
          },
          ParcelLocationProof(:final location) => <String, dynamic>{
            'proof_type': 'LOCATION_TIME',
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
        },
        // Only a cash parcel records a collection; prepaid never sends it.
        if (codCollected) 'cod_collected': true,
      },
    ),
  );

  /// Every single-parcel answer wraps the parcel: `{"data": {...}}`.
  ParcelModel _parcelOf(dynamic body) {
    if (body is! Map<String, dynamic>) throw const ServerException();
    final dynamic data = body['data'];
    if (data is! Map<String, dynamic>) throw const ServerException();
    return ParcelModel.fromJson(data);
  }
}
