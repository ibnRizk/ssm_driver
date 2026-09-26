import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/location/device_location.dart';
import '../../../../core/utils/log_utils.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/active_offer.dart';
import '../../domain/entities/current_work.dart';
import '../../domain/entities/work_transition.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remote;

  const OrdersRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, CurrentWork?>> getCurrentWork() =>
      _guard<CurrentWork?>(_remote.getCurrentWork);

  @override
  Future<Either<Failure, ActiveOffer?>> getActiveOffer() =>
      _guard<ActiveOffer?>(_remote.getActiveOffer);

  @override
  Future<Either<Failure, Unit>> acceptOffer(
    int assignmentId, {
    required String idempotencyKey,
  }) => _guard<Unit>(() async {
    await _remote.acceptOffer(assignmentId, idempotencyKey: idempotencyKey);
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> rejectOffer(
    int assignmentId, {
    required String idempotencyKey,
  }) => _guard<Unit>(() async {
    await _remote.rejectOffer(assignmentId, idempotencyKey: idempotencyKey);
    return unit;
  });

  @override
  Future<Either<Failure, WorkTransition>> confirmPickup({
    required int orderId,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _guard<WorkTransition>(
    () => _remote.confirmPickup(
      orderId: orderId,
      idempotencyKey: idempotencyKey,
      expectedVersion: expectedVersion,
    ),
  );

  @override
  Future<Either<Failure, WorkTransition>> startDelivery({
    required int orderId,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _guard<WorkTransition>(
    () => _remote.startDelivery(
      orderId: orderId,
      idempotencyKey: idempotencyKey,
      expectedVersion: expectedVersion,
    ),
  );

  @override
  Future<Either<Failure, WorkTransition>> completeWithOtp({
    required int orderId,
    required String otp,
    required bool codCollected,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _guard<WorkTransition>(
    () => _remote.completeWithOtp(
      orderId: orderId,
      otp: otp,
      codCollected: codCollected,
      idempotencyKey: idempotencyKey,
      expectedVersion: expectedVersion,
    ),
  );

  @override
  Future<Either<Failure, WorkTransition>> completeWithLocation({
    required int orderId,
    required DeviceLocation location,
    required bool codCollected,
    required String idempotencyKey,
    int? expectedVersion,
  }) => _guard<WorkTransition>(
    () => _remote.completeWithLocation(
      orderId: orderId,
      location: location,
      codCollected: codCollected,
      idempotencyKey: idempotencyKey,
      expectedVersion: expectedVersion,
    ),
  );

  /// The single exception-to-failure boundary for this repository.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right<Failure, T>(await call());
    } on AppException catch (e) {
      return Left<Failure, T>(e.toFailure());
    } catch (error, stackTrace) {
      // Usually a parsing bug (e.g. a TypeError in fromJson). The failure
      // below is generic, so this log is the only trace of the real cause.
      Log.e('OrdersRepository: unexpected error: $error\n$stackTrace');
      return Left<Failure, T>(
        ServerFailure(message: Strings.somethingWentWrong),
      );
    }
  }
}
