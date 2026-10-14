import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/location/device_location.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/repositories/c2c_parcels_repository.dart';
import '../datasources/c2c_parcels_remote_data_source.dart';

class C2cParcelsRepositoryImpl implements C2cParcelsRepository {
  final C2cParcelsRemoteDataSource _remote;

  const C2cParcelsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<C2cParcel>>> getOffers() =>
      _guard<List<C2cParcel>>(_remote.getOffers);

  /// The current feed may still list an unaccepted assignment or a parcel
  /// that just finished; neither is work to do.
  @override
  Future<Either<Failure, List<C2cParcel>>> getActiveJobs() =>
      _guard<List<C2cParcel>>(() async {
        final jobs = await _remote.getCurrentJobs();
        return <C2cParcel>[
          for (final C2cParcel job in jobs)
            if (!job.isOffer && !job.isTerminal) job,
        ];
      });

  @override
  Future<Either<Failure, C2cParcel?>> runAction(
    int parcelId,
    C2cAction action, {
    required String idempotencyKey,
    String? otp,
  }) => _guard<C2cParcel?>(
    () => _remote.runAction(
      parcelId,
      action,
      idempotencyKey: idempotencyKey,
      otp: otp,
    ),
  );

  @override
  Future<Either<Failure, Unit>> sendLocation(
    int parcelId,
    DeviceLocation location,
  ) => _guard<Unit>(() async {
    await _remote.sendLocation(parcelId, location);
    return unit;
  });

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
