import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/work_history.dart';

abstract class WorkHistoryRepository {
  /// One page of up to [limit] orders and up to [limit] parcels in [scope];
  /// [page] is 1-based.
  Future<Either<Failure, WorkHistoryPage>> getWorkHistory({
    required HistoryScope scope,
    required int page,
    required int limit,
  });
}
