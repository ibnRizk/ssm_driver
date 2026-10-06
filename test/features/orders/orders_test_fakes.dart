import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show FormData;
import 'package:ssm_driver/core/api/dio_consumer.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/location/device_location.dart';
import 'package:ssm_driver/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:ssm_driver/features/orders/data/models/active_offer_model.dart';
import 'package:ssm_driver/features/orders/data/models/current_work_model.dart';
import 'package:ssm_driver/features/orders/data/models/problem_report_model.dart';
import 'package:ssm_driver/features/orders/data/models/work_transition_model.dart';
import 'package:ssm_driver/features/orders/domain/entities/active_offer.dart';
import 'package:ssm_driver/features/orders/domain/entities/current_work.dart';
import 'package:ssm_driver/features/orders/domain/entities/problem_report.dart';
import 'package:ssm_driver/features/orders/domain/entities/work_transition.dart';
import 'package:ssm_driver/features/orders/domain/repositories/orders_repository.dart';

/// The documented `GET /delivery-man/current-work` 200 body.
Map<String, dynamic> currentWorkJson() => <String, dynamic>{
  'assignment_id': 3,
  'order_id': 100001,
  'ssm_status': 'driver_accepted',
  'ssm_status_version': 6,
  'pickup': <String, dynamic>{
    'name': 'SSM Fixture Store',
    'address': 'Olaya St, Riyadh',
    'latitude': 24.7136,
    'longitude': 46.6753,
  },
  'delivery_address': <String, dynamic>{
    'contact_person_name': 'Sara Customer',
    'contact_person_number': '+966574577391',
    'address_type': 'Delivery',
    'address': 'Olaya St 12, Riyadh',
    'longitude': '46.6800',
    'latitude': '24.7100',
  },
  'delivery_coordinates': <String, dynamic>{
    'latitude': 24.71,
    'longitude': 46.68,
  },
  'customer': <String, dynamic>{
    'name': 'Sara Customer',
    'phone': '+966574577391',
  },
  'order_note': null,
  'payment_method': 'cash_on_delivery',
  'cod_amount': '31.00',
  'order_type': 'delivery',
  'accepted_at': '2026-09-22 01:31:48',
  'picked_up_at': null,
  'delivery_completed_at': null,
};

const CurrentWorkModel sampleWork = CurrentWorkModel(
  assignmentId: 3,
  orderId: 100001,
  status: WorkStatus.driverAccepted,
  statusVersion: 6,
  storeName: 'SSM Fixture Store',
  storeAddress: 'Olaya St, Riyadh',
  storeLatitude: 24.7136,
  storeLongitude: 46.6753,
  customerName: 'Sara Customer',
  customerPhone: '+966574577391',
  deliveryAddress: 'Olaya St 12, Riyadh',
  deliveryLatitude: 24.71,
  deliveryLongitude: 46.68,
  orderNote: null,
  isCashOnDelivery: true,
  codAmount: '31.00',
);

/// The documented `offer` object of `GET /delivery-man/active-offer`.
Map<String, dynamic> activeOfferJson() => <String, dynamic>{
  'assignment_id': 501,
  'order_id': 9001,
  'attempt_number': 1,
  'offered_at': '2026-09-23T12:00:00+03:00',
  'expires_at': '2026-09-23T12:00:30+03:00',
  'server_now': '2026-09-23T12:00:05+03:00',
  'remaining_seconds': 25,
  'distance_meters_snapshot': 840,
  'pickup': <String, dynamic>{
    'name': 'Store name',
    'address': 'Store address',
    'latitude': 24.71,
    'longitude': 46.67,
  },
  'delivery_address': 'Delivery address',
  'payment_method': 'cash_on_delivery',
  'cod_amount': '125.00',
  'order_type': 'delivery',
};

const ActiveOfferModel sampleOffer = ActiveOfferModel(
  assignmentId: 501,
  orderId: 9001,
  remainingSeconds: 25,
  distanceMeters: 840,
  pickupName: 'Store name',
  pickupAddress: 'Store address',
  deliveryAddress: 'Delivery address',
  isCashOnDelivery: true,
  codAmount: '125.00',
);

const WorkTransitionModel pickedUpTransition = WorkTransitionModel(
  orderId: 100001,
  status: WorkStatus.pickedUp,
  statusVersion: 7,
);

/// Answers every GET/POST with [response] (or throws [error]) and records
/// the last request so tests can assert on path, body and headers.
class FakeDioConsumer implements DioConsumer {
  dynamic response;
  Object? error;

  String? lastPath;
  Map<String, dynamic>? lastBody;
  Map<String, dynamic>? lastHeaders;

  FakeDioConsumer(this.response);

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
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
    lastHeaders = headers;
    if (error != null) throw error!;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Throws [error] when set, otherwise returns the configured values.
class FakeOrdersRemoteDataSource implements OrdersRemoteDataSource {
  Object? error;
  CurrentWorkModel? work = sampleWork;
  ActiveOfferModel? offer = sampleOffer;
  WorkTransitionModel transition = pickedUpTransition;

  Future<T> _answer<T>(T value) async {
    if (error != null) throw error!;
    return value;
  }

  @override
  Future<CurrentWorkModel?> getCurrentWork() => _answer(work);

  @override
  Future<ActiveOfferModel?> getActiveOffer() => _answer(offer);

  @override
  Future<void> acceptOffer(
    int assignmentId, {
    required String idempotencyKey,
  }) => _answer(null);

  @override
  Future<void> rejectOffer(
    int assignmentId, {
    required String idempotencyKey,
  }) => _answer(null);

  @override
  Future<WorkTransitionModel> confirmPickup({
    required int orderId,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _answer(transition);

  @override
  Future<WorkTransitionModel> startDelivery({
    required int orderId,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _answer(transition);

  @override
  Future<WorkTransitionModel> completeWithOtp({
    required int orderId,
    required String otp,
    required bool codCollected,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _answer(transition);

  @override
  Future<WorkTransitionModel> completeWithLocation({
    required int orderId,
    required DeviceLocation location,
    required bool codCollected,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _answer(transition);

  @override
  Future<List<ProblemReasonModel>> getProblemReasons() =>
      _answer(const <ProblemReasonModel>[
        ProblemReasonModel(code: 'store_closed', label: 'Store closed'),
      ]);

  @override
  Future<ProblemReportModel> reportProblem({
    required int orderId,
    required String reasonCode,
    required String idempotencyKey,
    String? note,
  }) => _answer(sampleReport);

  @override
  Future<void> giveUpOrder({
    required int orderId,
    required bool pickedUp,
    required String reasonCode,
    required String idempotencyKey,
    String? note,
    int? expectedVersion,
  }) => _answer<void>(null);
}

const ProblemReason storeClosed = ProblemReason(
  code: 'store_closed',
  label: 'Store closed',
);

const ProblemReportModel sampleReport = ProblemReportModel(
  reportId: 12,
  nextAction: 'continue_order',
  isReplay: false,
);

/// Returns the configured results and records what each command was sent.
class FakeOrdersRepository implements OrdersRepository {
  Either<Failure, CurrentWork?> result = const Right<Failure, CurrentWork?>(
    sampleWork,
  );
  Either<Failure, ActiveOffer?> offerResult =
      const Right<Failure, ActiveOffer?>(sampleOffer);
  Either<Failure, Unit> offerCommandResult = const Right<Failure, Unit>(unit);

  /// When set, accept/reject wait for it — an answer still on its way.
  Completer<void>? commandGate;
  Either<Failure, WorkTransition> transitionResult =
      const Right<Failure, WorkTransition>(pickedUpTransition);

  int currentWorkCalls = 0;
  int activeOfferCalls = 0;
  final List<String> usedKeys = <String>[];
  int? lastExpectedVersion;
  String? lastOtp;
  bool? lastCodCollected;
  final List<DeviceLocation> sentLocations = <DeviceLocation>[];

  @override
  Future<Either<Failure, CurrentWork?>> getCurrentWork() async {
    currentWorkCalls++;
    return result;
  }

  @override
  Future<Either<Failure, ActiveOffer?>> getActiveOffer() async {
    activeOfferCalls++;
    return offerResult;
  }

  @override
  Future<Either<Failure, Unit>> acceptOffer(
    int assignmentId, {
    required String idempotencyKey,
  }) async {
    usedKeys.add(idempotencyKey);
    await commandGate?.future;
    return offerCommandResult;
  }

  @override
  Future<Either<Failure, Unit>> rejectOffer(
    int assignmentId, {
    required String idempotencyKey,
  }) async {
    usedKeys.add(idempotencyKey);
    await commandGate?.future;
    return offerCommandResult;
  }

  @override
  Future<Either<Failure, WorkTransition>> confirmPickup({
    required int orderId,
    required String idempotencyKey,
    int? expectedVersion,
  }) async {
    usedKeys.add(idempotencyKey);
    lastExpectedVersion = expectedVersion;
    return transitionResult;
  }

  @override
  Future<Either<Failure, WorkTransition>> startDelivery({
    required int orderId,
    required String idempotencyKey,
    int? expectedVersion,
  }) async {
    usedKeys.add(idempotencyKey);
    lastExpectedVersion = expectedVersion;
    return transitionResult;
  }

  @override
  Future<Either<Failure, WorkTransition>> completeWithOtp({
    required int orderId,
    required String otp,
    required bool codCollected,
    required String idempotencyKey,
    int? expectedVersion,
  }) async {
    usedKeys.add(idempotencyKey);
    lastOtp = otp;
    lastCodCollected = codCollected;
    lastExpectedVersion = expectedVersion;
    return transitionResult;
  }

  @override
  Future<Either<Failure, WorkTransition>> completeWithLocation({
    required int orderId,
    required DeviceLocation location,
    required bool codCollected,
    required String idempotencyKey,
    int? expectedVersion,
  }) async {
    usedKeys.add(idempotencyKey);
    sentLocations.add(location);
    lastCodCollected = codCollected;
    lastExpectedVersion = expectedVersion;
    return transitionResult;
  }

  Either<Failure, List<ProblemReason>> reasonsResult =
      const Right<Failure, List<ProblemReason>>(<ProblemReason>[storeClosed]);
  Either<Failure, ProblemReport> reportResult =
      const Right<Failure, ProblemReport>(sampleReport);
  String? lastReasonCode;
  String? lastNote;
  Either<Failure, Unit> giveUpResult = const Right<Failure, Unit>(unit);
  bool? lastGiveUpPickedUp;

  @override
  Future<Either<Failure, List<ProblemReason>>> getProblemReasons() async =>
      reasonsResult;

  @override
  Future<Either<Failure, ProblemReport>> reportProblem({
    required int orderId,
    required String reasonCode,
    required String idempotencyKey,
    String? note,
  }) async {
    usedKeys.add(idempotencyKey);
    lastReasonCode = reasonCode;
    lastNote = note;
    return reportResult;
  }

  @override
  Future<Either<Failure, Unit>> giveUpOrder({
    required int orderId,
    required bool pickedUp,
    required String reasonCode,
    required String idempotencyKey,
    String? note,
    int? expectedVersion,
  }) async {
    usedKeys.add(idempotencyKey);
    lastReasonCode = reasonCode;
    lastNote = note;
    lastGiveUpPickedUp = pickedUp;
    lastExpectedVersion = expectedVersion;
    return giveUpResult;
  }
}

/// Deterministic idempotency keys: key-1, key-2, …
String Function() sequentialKeys() {
  int next = 0;
  return () => 'key-${++next}';
}
