import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/work_history.dart';
import '../models/work_history_models.dart';

/// Raw `GET /delivery-man/work-history` call. Throws [AppException]s; the
/// repository turns them into failures.
class WorkHistoryRemoteDataSource {
  final DioConsumer _consumer;

  const WorkHistoryRemoteDataSource(this._consumer);

  /// `offset` is the 1-based page number, as on the other driver feeds.
  Future<WorkHistoryPage> getWorkHistory({
    required HistoryScope scope,
    required int page,
    required int limit,
  }) async {
    final dynamic body = await _consumer.get(
      ApiEndpoints.workHistory,
      queryParameters: <String, dynamic>{
        'scope': scope.apiValue,
        'limit': limit,
        'offset': page,
      },
    );
    if (body is! Map<String, dynamic>) throw const ServerException();
    return workHistoryPageFromJson(body);
  }
}
