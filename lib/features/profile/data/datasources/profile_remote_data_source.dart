import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../models/driver_profile_model.dart';

/// Raw Driver profile API calls. Throws [AppException]s (mapped by
/// [DioConsumer]); the repository turns them into failures.
class ProfileRemoteDataSource {
  final DioConsumer _consumer;

  const ProfileRemoteDataSource(this._consumer);

  Future<DriverProfileModel> getProfile() async {
    final dynamic data = await _consumer.get(ApiEndpoints.profile);
    if (data is! Map<String, dynamic>) throw const ServerException();
    return DriverProfileModel.fromJson(data);
  }
}
