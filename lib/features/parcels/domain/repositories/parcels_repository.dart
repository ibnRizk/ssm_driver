import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/parcel.dart';
import '../entities/parcel_proof.dart';

abstract class ParcelsRepository {
  /// One page of up to [limit] parcels; [page] is 1-based.
  Future<Either<Failure, ParcelsPage>> getParcels({
    ParcelListFilter filter = ParcelListFilter.active,
    required int page,
    required int limit,
  });

  /// A parcel not assigned to this Driver fails (the server answers 404).
  Future<Either<Failure, Parcel>> getParcelDetails(int parcelId);

  /// Moves the parcel to out-for-delivery. Optional — see [completeParcel].
  Future<Either<Failure, Parcel>> startDelivery(int parcelId);

  /// Completes with [proof], from the warehouse or out-for-delivery state.
  /// [codCollected] must be true for a cash parcel whose cash the Driver
  /// received; the server owns the amount. Repeating it after delivery is
  /// idempotent.
  Future<Either<Failure, Parcel>> completeParcel(
    int parcelId, {
    required ParcelProof proof,
    required bool codCollected,
  });
}
