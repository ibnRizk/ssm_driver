import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show FormData;
import 'package:ssm_driver/core/api/dio_consumer.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/parcels/data/datasources/parcels_remote_data_source.dart';
import 'package:ssm_driver/features/parcels/data/models/parcel_model.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel_proof.dart';
import 'package:ssm_driver/features/parcels/domain/repositories/parcels_repository.dart';

/// A parcel object as documented in the Postman collection (§13).
Map<String, dynamic> parcelJson({
  int id = 2,
  String status = 'ARRIVED_AT_WAREHOUSE',
  String paymentType = 'COD',
}) => <String, dynamic>{
  'id': id,
  'shipping_company_id': 1,
  'parcel_tracking_number': 'FX-COD-1',
  'customer_id': 1,
  'recipient_name': 'Sara Customer',
  'recipient_phone': '+966574577391',
  'delivery_address': 'Al Malaz, Riyadh',
  'zone_id': 1,
  'latitude': 24.7,
  'longitude': 46.7,
  'payment_type': paymentType,
  'customer_delivery_fee': '0.00',
  'cod_amount': '75.50',
  'cod_status': 'PENDING',
  'parcel_status': status,
  'driver_id': 1,
  'warehouse_shelf_location': null,
  'weight_kg': '1.20',
  'description': 'Fixture parcel',
  'metadata': <String, dynamic>{'customer_notes': 'Call on arrival'},
  'shipping_company': <String, dynamic>{
    'id': 1,
    'name': 'Fixture Shipping Co',
    'company_code': 'FIXTURECO',
  },
  'customer': <String, dynamic>{'id': 1, 'f_name': 'Sara', 'l_name': 'Customer'},
};

const ParcelModel sampleParcel = ParcelModel(
  id: 2,
  trackingNumber: 'FX-COD-1',
  status: ParcelStatus.arrivedAtWarehouse,
  recipientName: 'Sara Customer',
  recipientPhone: '+966574577391',
  deliveryAddress: 'Al Malaz, Riyadh',
  latitude: 24.7,
  longitude: 46.7,
  shippingCompanyName: 'Fixture Shipping Co',
  customerNotes: 'Call on arrival',
  isCashOnDelivery: true,
  codAmount: '75.50',
);

const ParcelModel startedParcel = ParcelModel(
  id: 2,
  trackingNumber: 'FX-COD-1',
  status: ParcelStatus.outForDelivery,
  recipientName: 'Sara Customer',
  recipientPhone: '+966574577391',
  deliveryAddress: 'Al Malaz, Riyadh',
  latitude: 24.7,
  longitude: 46.7,
  shippingCompanyName: 'Fixture Shipping Co',
  customerNotes: 'Call on arrival',
  isCashOnDelivery: true,
  codAmount: '75.50',
);

/// A distinct parcel for multi-page lists.
Parcel parcelWithId(int id) => ParcelModel.fromJson(parcelJson(id: id));

const ParcelsPage samplePage = ParcelsPage(
  parcels: <Parcel>[sampleParcel],
  totalSize: 1,
);

/// Answers every GET/POST with [response] (or throws [error]) and records
/// the last request.
class FakeDioConsumer implements DioConsumer {
  dynamic response;
  Object? error;

  String? lastPath;
  Map<String, dynamic>? lastQuery;
  Map<String, dynamic>? lastBody;

  FakeDioConsumer(this.response);

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
    lastQuery = queryParameters;
    if (error != null) throw error!;
    return response;
  }

  @override
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    lastPath = path;
    lastBody = body;
    if (error != null) throw error!;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Throws [error] when set, otherwise returns the configured values.
class FakeParcelsRemoteDataSource implements ParcelsRemoteDataSource {
  Object? error;
  ParcelsPage page = samplePage;
  ParcelModel parcel = sampleParcel;

  Future<T> _answer<T>(T value) async {
    if (error != null) throw error!;
    return value;
  }

  @override
  Future<ParcelsPage> getParcels({
    ParcelListFilter filter = ParcelListFilter.active,
    required int page,
    required int limit,
  }) => _answer(this.page);

  @override
  Future<ParcelModel> getParcelDetails(int parcelId) => _answer(parcel);

  @override
  Future<ParcelModel> startDelivery(int parcelId) => _answer(parcel);

  @override
  Future<ParcelModel> completeParcel(
    int parcelId, {
    required ParcelProof proof,
    required bool codCollected,
  }) => _answer(parcel);
}

/// Returns the configured results and records what each command was sent.
class FakeParcelsRepository implements ParcelsRepository {
  Either<Failure, ParcelsPage> pageResult = const Right<Failure, ParcelsPage>(
    samplePage,
  );
  Either<Failure, Parcel> parcelResult = const Right<Failure, Parcel>(
    sampleParcel,
  );

  /// Per-page answers; pages not listed get [pageResult].
  final Map<int, Either<Failure, ParcelsPage>> pageResults =
      <int, Either<Failure, ParcelsPage>>{};
  /// Holds a page's answer until the test completes its gate.
  final Map<int, Completer<void>> pageGates = <int, Completer<void>>{};
  final List<int> requestedPages = <int>[];
  int? lastLimit;

  int startCalls = 0;
  int completeCalls = 0;
  ParcelProof? lastProof;
  bool? lastCodCollected;

  @override
  Future<Either<Failure, ParcelsPage>> getParcels({
    ParcelListFilter filter = ParcelListFilter.active,
    required int page,
    required int limit,
  }) async {
    requestedPages.add(page);
    lastLimit = limit;
    await pageGates[page]?.future;
    return pageResults[page] ?? pageResult;
  }

  @override
  Future<Either<Failure, Parcel>> getParcelDetails(int parcelId) async =>
      parcelResult;

  @override
  Future<Either<Failure, Parcel>> startDelivery(int parcelId) async {
    startCalls++;
    return parcelResult;
  }

  @override
  Future<Either<Failure, Parcel>> completeParcel(
    int parcelId, {
    required ParcelProof proof,
    required bool codCollected,
  }) async {
    completeCalls++;
    lastProof = proof;
    lastCodCollected = codCollected;
    return parcelResult;
  }
}
