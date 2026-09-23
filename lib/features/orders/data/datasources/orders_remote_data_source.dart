import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../models/current_work_model.dart';

/// Raw Driver order API calls. Throws [AppException]s (mapped by
/// [DioConsumer]); the repository turns them into failures.
class OrdersRemoteDataSource {
  final DioConsumer _consumer;

  const OrdersRemoteDataSource(this._consumer);

  /// `null` when there is no active order. The API answers `{"work": null}`
  /// when idle and the bare work object otherwise; a `{"work": {...}}`
  /// envelope is accepted too.
  Future<CurrentWorkModel?> getCurrentWork() async {
    final dynamic data = await _consumer.get(ApiEndpoints.currentWork);
    if (data is! Map<String, dynamic>) throw const ServerException();

    if (data.containsKey('work')) {
      final dynamic work = data['work'];
      if (work == null) return null;
      if (work is! Map<String, dynamic>) throw const ServerException();
      return CurrentWorkModel.fromJson(work);
    }
    return CurrentWorkModel.fromJson(data);
  }
}
