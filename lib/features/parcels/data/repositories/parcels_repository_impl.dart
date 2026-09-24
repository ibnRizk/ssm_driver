import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/entities/parcel_proof.dart';
import '../../domain/repositories/parcels_repository.dart';
import '../datasources/parcels_remote_data_source.dart';

class ParcelsRepositoryImpl implements ParcelsRepository {
  final ParcelsRemoteDataSource _remote;

  const ParcelsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, ParcelsPage>> getParcels({
    ParcelListFilter filter = ParcelListFilter.active,
    required int page,
    required int limit,
  }) => _guard<ParcelsPage>(
    () => _remote.getParcels(filter: filter, page: page, limit: limit),
  );

  @override
  Future<Either<Failure, Parcel>> getParcelDetails(int parcelId) =>
      _guard<Parcel>(() => _remote.getParcelDetails(parcelId));

  @override
  Future<Either<Failure, Parcel>> startDelivery(int parcelId) =>
      _guard<Parcel>(() => _remote.startDelivery(parcelId));

  @override
  Future<Either<Failure, Parcel>> completeParcel(
    int parcelId, {
    required ParcelProof proof,
    required bool codCollected,
  }) => _guard<Parcel>(
    () => _remote.completeParcel(
      parcelId,
      proof: proof,
      codCollected: codCollected,
    ),
  );

  /// The single exception-to-failure boundary for this repository.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right<Failure, T>(await call());
    } on AppException catch (e) {
      return Left<Failure, T>(e.toFailure());
    } catch (_) {
      return Left<Failure, T>(
        ServerFailure(message: Strings.somethingWentWrong),
      );
    }
  }
}
