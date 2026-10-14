import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/work_history.dart';
import '../../domain/repositories/work_history_repository.dart';
import '../datasources/work_history_remote_data_source.dart';

class WorkHistoryRepositoryImpl implements WorkHistoryRepository {
  final WorkHistoryRemoteDataSource _remote;

  const WorkHistoryRepositoryImpl(this._remote);

  /// The single exception-to-failure boundary for this repository.
  @override
  Future<Either<Failure, WorkHistoryPage>> getWorkHistory({
    required HistoryScope scope,
    required int page,
    required int limit,
  }) async {
    try {
      return Right<Failure, WorkHistoryPage>(
        await _remote.getWorkHistory(scope: scope, page: page, limit: limit),
      );
    } on AppException catch (e) {
      return Left<Failure, WorkHistoryPage>(e.toFailure());
    } catch (_) {
      return Left<Failure, WorkHistoryPage>(
        ServerFailure(message: Strings.somethingWentWrong),
      );
    }
  }
}
