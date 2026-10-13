import '../../api/api_endpoints.dart';
import '../../api/dio_consumer.dart';
import '../../error/exceptions.dart';

/// Registers this device for the Driver's pushes (API docs §8). Throws
/// [AppException]s; the repository maps them.
class PushTokenRemoteDataSource {
  final DioConsumer _consumer;

  const PushTokenRemoteDataSource(this._consumer);

  Future<void> updateFcmToken(String token) async {
    await _consumer.put(
      ApiEndpoints.updateFcmToken,
      body: <String, dynamic>{'fcm_token': token},
    );
  }
}
