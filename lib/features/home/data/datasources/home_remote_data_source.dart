import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/location/device_location.dart';

/// Raw availability/presence API calls. (The dashboard summaries live in
/// `core/services/driver_stats`, shared with the Earnings tab.) Throws [AppException]s (mapped by
/// [DioConsumer]); the repository turns them into failures.
class HomeRemoteDataSource {
  final DioConsumer _consumer;

  const HomeRemoteDataSource(this._consumer);

  /// There is no dedicated availability read, so the profile's `is_online`
  /// is the source.
  Future<bool> getOnlineStatus() async =>
      _isOnline(await _consumer.get(ApiEndpoints.profile));

  Future<bool> goOnline() async =>
      _isOnline(await _consumer.post(ApiEndpoints.goOnline));

  Future<bool> goOffline() async =>
      _isOnline(await _consumer.post(ApiEndpoints.goOffline));

  Future<void> sendHeartbeat() => _consumer.post(ApiEndpoints.heartbeat);

  /// Never sends `driver_id` — identity comes from the Bearer token, and the
  /// server rejects spoofing with 422 (API docs §9). `recorded_at` is left
  /// out on purpose: the fix is sent right away, and a device clock running
  /// ahead would make it "in the future" and get the whole update rejected.
  Future<void> publishLocation(DeviceLocation location) => _consumer.post(
    ApiEndpoints.location,
    body: <String, dynamic>{
      'latitude': location.latitude,
      'longitude': location.longitude,
      if (location.accuracy != null) 'accuracy': location.accuracy,
      if (location.heading != null) 'heading': location.heading,
      // The API caps speed at 200; anything above is a bad reading.
      if (location.speed != null && location.speed! <= 200)
        'speed': location.speed,
    },
  );

  /// The server's answer is authoritative — a body without a boolean
  /// `is_online` is treated as a failure rather than guessed.
  bool _isOnline(dynamic data) {
    final dynamic isOnline = _asMap(data)['is_online'];
    return switch (isOnline) {
      final bool b => b,
      1 || '1' => true,
      0 || '0' => false,
      _ => throw const ServerException(),
    };
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is! Map<String, dynamic>) throw const ServerException();
    return data;
  }
}
