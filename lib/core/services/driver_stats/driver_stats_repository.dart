import 'package:dartz/dartz.dart';

import '../../error/exceptions.dart';
import '../../error/failures.dart';
import '../../utils/values/strings.dart';
import 'cod_summary.dart';
import 'driver_stats_remote_data_source.dart';
import 'incentive_summary.dart';

/// The Driver's COD liability and incentive progress. Read-only by design:
/// the Driver API exposes no settlement or collection-editing endpoint.
abstract class DriverStatsRepository {
  Future<Either<Failure, CodSummary>> getCodSummary();

  Future<Either<Failure, IncentiveSummary>> getIncentiveSummary();
}

class DriverStatsRepositoryImpl implements DriverStatsRepository {
  final DriverStatsRemoteDataSource _remote;

  const DriverStatsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, CodSummary>> getCodSummary() =>
      _guard<CodSummary>(_remote.getCodSummary);

  @override
  Future<Either<Failure, IncentiveSummary>> getIncentiveSummary() =>
      _guard<IncentiveSummary>(_remote.getIncentiveSummary);

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
