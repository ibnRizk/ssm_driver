import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../models/support_info_model.dart';

/// Raw support API calls. Throws [AppException]s (mapped by [DioConsumer]);
/// the repository turns them into failures.
class SupportRemoteDataSource {
  final DioConsumer _consumer;

  const SupportRemoteDataSource(this._consumer);

  Future<SupportInfoModel> getSupportInfo() async {
    final dynamic data = await _consumer.get(ApiEndpoints.supportInfo);
    if (data is! Map<String, dynamic>) throw const ServerException();
    return SupportInfoModel.fromJson(data);
  }
}
