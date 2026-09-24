import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/location/device_location.dart';
import '../entities/cod_summary.dart';
import '../entities/incentive_summary.dart';

abstract class HomeRepository {
  Future<Either<Failure, CodSummary>> getCodSummary();

  Future<Either<Failure, IncentiveSummary>> getIncentiveSummary();

  /// The Driver's current online flag, as the server last recorded it.
  Future<Either<Failure, bool>> getOnlineStatus();

  /// Both return the server's `is_online` after the call. Going offline can
  /// be refused while the Driver owns active work — that arrives as a
  /// failure, and the Driver stays online.
  Future<Either<Failure, bool>> goOnline();

  Future<Either<Failure, bool>> goOffline();

  /// Presence for dispatch: an online Driver is only offered orders while
  /// both the heartbeat and the location are under 120 s old (API docs §9).
  Future<Either<Failure, Unit>> sendHeartbeat();

  Future<Either<Failure, Unit>> publishLocation(DeviceLocation location);
}
