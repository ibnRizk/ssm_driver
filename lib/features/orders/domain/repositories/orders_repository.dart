import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/location/device_location.dart';
import '../entities/active_offer.dart';
import '../entities/current_work.dart';
import '../entities/problem_report.dart';
import '../entities/work_transition.dart';

abstract class OrdersRepository {
  /// `Right(null)` means the Driver has no accepted active order.
  Future<Either<Failure, CurrentWork?>> getCurrentWork();

  /// `Right(null)` means there is no offer waiting for this Driver.
  Future<Either<Failure, ActiveOffer?>> getActiveOffer();

  /// Offer commands. [idempotencyKey] must stay the same across retries of
  /// one tap and change for the next action.
  Future<Either<Failure, Unit>> acceptOffer(
    int assignmentId, {
    required String idempotencyKey,
  });

  Future<Either<Failure, Unit>> rejectOffer(
    int assignmentId, {
    required String idempotencyKey,
  });

  /// Lifecycle commands, in the only order the server accepts:
  /// pickup → out for delivery → complete. [expectedVersion] is the optional
  /// optimistic lock (the order's last known status version).
  Future<Either<Failure, WorkTransition>> confirmPickup({
    required int orderId,
    required String idempotencyKey,
    int? expectedVersion,
  });

  Future<Either<Failure, WorkTransition>> startDelivery({
    required int orderId,
    required String idempotencyKey,
    int? expectedVersion,
  });

  /// Completes with the customer's OTP. [codCollected] must be true for a
  /// cash order whose cash the Driver received; the server owns the amount.
  Future<Either<Failure, WorkTransition>> completeWithOtp({
    required int orderId,
    required String otp,
    required bool codCollected,
    required String idempotencyKey,
    int? expectedVersion,
  });

  /// Completes with the device's position and time as proof instead of an
  /// OTP. Same [codCollected] rule as [completeWithOtp].
  Future<Either<Failure, WorkTransition>> completeWithLocation({
    required int orderId,
    required DeviceLocation location,
    required bool codCollected,
    required String idempotencyKey,
    int? expectedVersion,
  });

  /// The reasons a Driver can report, translated by the server.
  Future<Either<Failure, List<ProblemReason>>> getProblemReasons();

  /// Opens a support case for an active order the Driver owns; the order
  /// itself is unchanged. Same [idempotencyKey] rule as the commands above.
  Future<Either<Failure, ProblemReport>> reportProblem({
    required int orderId,
    required String reasonCode,
    required String idempotencyKey,
    String? note,
  });
}
