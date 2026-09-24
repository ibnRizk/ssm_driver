import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/location/device_location.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/cod_summary.dart';
import '../../domain/entities/incentive_summary.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remote;

  const HomeRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, CodSummary>> getCodSummary() =>
      _guard<CodSummary>(_remote.getCodSummary);

  @override
  Future<Either<Failure, IncentiveSummary>> getIncentiveSummary() =>
      _guard<IncentiveSummary>(_remote.getIncentiveSummary);

  @override
  Future<Either<Failure, bool>> getOnlineStatus() =>
      _guard<bool>(_remote.getOnlineStatus);

  @override
  Future<Either<Failure, bool>> goOnline() => _guard<bool>(_remote.goOnline);

  @override
  Future<Either<Failure, bool>> goOffline() => _guard<bool>(_remote.goOffline);

  @override
  Future<Either<Failure, Unit>> sendHeartbeat() => _guard<Unit>(() async {
    await _remote.sendHeartbeat();
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> publishLocation(DeviceLocation location) =>
      _guard<Unit>(() async {
        await _remote.publishLocation(location);
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
