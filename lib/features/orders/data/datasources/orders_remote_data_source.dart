import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/location/device_location.dart';
import '../models/active_offer_model.dart';
import '../models/current_work_model.dart';
import '../models/problem_report_model.dart';
import '../models/work_transition_model.dart';

/// Raw Driver order API calls. Throws [AppException]s (mapped by
/// [DioConsumer]); the repository turns them into failures.
class OrdersRemoteDataSource {
  final DioConsumer _consumer;

  const OrdersRemoteDataSource(this._consumer);

  static const String idempotencyHeader = 'Idempotency-Key';

  /// `null` when there is no active order. The API answers `{"work": null}`
  /// when idle and the bare work object otherwise; a `{"work": {...}}`
  /// envelope is accepted too.
  Future<CurrentWorkModel?> getCurrentWork() async {
    final dynamic data = await _consumer.get(ApiEndpoints.currentWork);
    if (data is! Map<String, dynamic>) throw const ServerException();

    if (data.containsKey('work')) {
      final dynamic work = data['work'];
      if (work == null) return null;
      if (work is! Map<String, dynamic>) throw const ServerException();
      return CurrentWorkModel.fromJson(work);
    }
    return CurrentWorkModel.fromJson(data);
  }

  /// `null` when no offer is waiting. The API answers with the bare offer
  /// object; an `{"offer": {...}}` / `{"offer": null}` envelope and an empty
  /// body are accepted too.
  Future<ActiveOfferModel?> getActiveOffer() async {
    final dynamic data = await _consumer.get(ApiEndpoints.activeOffer);
    if (data == null || data == '') return null;
    if (data is! Map<String, dynamic>) throw const ServerException();

    final dynamic offer = data.containsKey('offer') ? data['offer'] : data;
    if (offer == null) return null;
    if (offer is! Map<String, dynamic>) throw const ServerException();
    // An object without offer ids (e.g. {"message": "No active offers"})
    // is not an offer; parsing it would announce a phantom offer #0.
    if (offer['assignment_id'] == null && offer['order_id'] == null) {
      return null;
    }
    return ActiveOfferModel.fromJson(offer);
  }

  Future<void> acceptOffer(
    int assignmentId, {
    required String idempotencyKey,
  }) => _consumer.post(
    ApiEndpoints.acceptOffer(assignmentId),
    headers: <String, dynamic>{idempotencyHeader: idempotencyKey},
  );

  Future<void> rejectOffer(
    int assignmentId, {
    required String idempotencyKey,
  }) => _consumer.post(
    ApiEndpoints.rejectOffer(assignmentId),
    headers: <String, dynamic>{idempotencyHeader: idempotencyKey},
  );

  Future<WorkTransitionModel> confirmPickup({
    required int orderId,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _transition(
    ApiEndpoints.pickupOrder(orderId),
    idempotencyKey: idempotencyKey,
    body: <String, dynamic>{
      if (expectedVersion != null) 'expected_version': expectedVersion,
    },
  );

  Future<WorkTransitionModel> startDelivery({
    required int orderId,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _transition(
    ApiEndpoints.outForDelivery(orderId),
    idempotencyKey: idempotencyKey,
    body: <String, dynamic>{
      if (expectedVersion != null) 'expected_version': expectedVersion,
    },
  );

  Future<WorkTransitionModel> completeWithOtp({
    required int orderId,
    required String otp,
    required bool codCollected,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _transition(
    ApiEndpoints.completeOrder(orderId),
    idempotencyKey: idempotencyKey,
    body: <String, dynamic>{
      'proof_method': 'otp',
      'otp': otp,
      'cod_collected': codCollected,
      if (expectedVersion != null) 'expected_version': expectedVersion,
    },
  );

  /// Completes with the device's location and time as proof (API docs §11).
  Future<WorkTransitionModel> completeWithLocation({
    required int orderId,
    required DeviceLocation location,
    required bool codCollected,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _transition(
    ApiEndpoints.completeOrder(orderId),
    idempotencyKey: idempotencyKey,
    body: <String, dynamic>{
      'proof_method': 'location_time',
      'latitude': location.latitude,
      'longitude': location.longitude,
      if (location.accuracy != null) 'accuracy': location.accuracy,
      'device_timestamp': location.recordedAt.toUtc().toIso8601String(),
      'cod_collected': codCollected,
      if (expectedVersion != null) 'expected_version': expectedVersion,
    },
  );

  Future<List<ProblemReasonModel>> getProblemReasons() async =>
      ProblemReasonModel.listFromJson(
        await _consumer.get(ApiEndpoints.problemReasons),
      );

  /// Opens a support case for the order; it never changes the order's
  /// status. A 409 means [idempotencyKey] was used for a different report.
  Future<ProblemReportModel> reportProblem({
    required int orderId,
    required String reasonCode,
    required String idempotencyKey,
    String? note,
  }) async {
    final dynamic data = await _consumer.post(
      ApiEndpoints.reportProblem(orderId),
      body: <String, dynamic>{
        'reason_code': reasonCode,
        if (note != null && note.isNotEmpty) 'note': note,
      },
      headers: <String, dynamic>{idempotencyHeader: idempotencyKey},
    );
    if (data is! Map<String, dynamic>) throw const ServerException();
    return ProblemReportModel.fromJson(data);
  }

  Future<WorkTransitionModel> _transition(
    String path, {
    required String idempotencyKey,
    required Map<String, dynamic> body,
  }) async {
    final dynamic data = await _consumer.post(
      path,
      body: body,
      headers: <String, dynamic>{idempotencyHeader: idempotencyKey},
    );
    if (data is! Map<String, dynamic>) throw const ServerException();
    return WorkTransitionModel.fromJson(data);
  }
}
