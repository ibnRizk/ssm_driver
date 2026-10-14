import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/location/device_location.dart';
import '../entities/c2c_parcel.dart';

abstract class C2cParcelsRepository {
  /// Offers waiting for this Driver, coarse areas only.
  Future<Either<Failure, List<C2cParcel>>> getOffers();

  /// Accepted, unfinished C2C jobs with full pickup and drop-off details.
  Future<Either<Failure, List<C2cParcel>>> getActiveJobs();

  /// Sends [action] for parcel [parcelId] under [idempotencyKey] — reuse a
  /// key only to retry the identical command after a timeout. [otp] goes
  /// with [C2cAction.complete] when the parcel requires it.
  ///
  /// Succeeds with the updated parcel, or `null` when the answer didn't
  /// carry one (re-read it).
  Future<Either<Failure, C2cParcel?>> runAction(
    int parcelId,
    C2cAction action, {
    required String idempotencyKey,
    String? otp,
  });

  /// A tracking ping for an active job (contract §4).
  Future<Either<Failure, Unit>> sendLocation(
    int parcelId,
    DeviceLocation location,
  );
}
