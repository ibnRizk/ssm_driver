import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/services/location/device_location.dart';
import 'package:ssm_driver/features/home/data/datasources/home_remote_data_source.dart';

import '../../helpers/fake_location_service.dart' show sampleLocation;
import '../orders/orders_test_fakes.dart' show FakeDioConsumer;

void main() {
  test('going online returns the server is_online', () async {
    final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{
      'message': 'You are online.',
      'is_online': true,
      'last_seen_at': '2026-09-23T12:00:00+03:00',
      'availability_version': 4,
    });

    expect(await HomeRemoteDataSource(consumer).goOnline(), isTrue);
    expect(consumer.lastPath, '/delivery-man/online');
  });

  test('going offline posts to the offline endpoint', () async {
    final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{
      'is_online': false,
    });

    expect(await HomeRemoteDataSource(consumer).goOffline(), isFalse);
    expect(consumer.lastPath, '/delivery-man/offline');
  });

  test('the current online flag is read from the profile', () async {
    final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{
      'id': 1,
      'is_online': 1,
    });

    expect(await HomeRemoteDataSource(consumer).getOnlineStatus(), isTrue);
    expect(consumer.lastPath, '/delivery-man/profile');
  });

  test('an answer without is_online is a server error, not a guess', () {
    final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{
      'message': 'ok',
    });

    expect(
      HomeRemoteDataSource(consumer).goOnline(),
      throwsA(isA<ServerException>()),
    );
  });

  test('heartbeat posts to the heartbeat endpoint', () async {
    final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{});

    await HomeRemoteDataSource(consumer).sendHeartbeat();

    expect(consumer.lastPath, '/delivery-man/heartbeat');
  });

  test('location sends the fix without any driver id', () async {
    final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{});

    await HomeRemoteDataSource(consumer).publishLocation(sampleLocation);

    expect(consumer.lastPath, '/delivery-man/location');
    expect(consumer.lastBody, <String, dynamic>{
      'latitude': 24.7136,
      'longitude': 46.6753,
      'accuracy': 8.5,
      'heading': 120.0,
      'speed': 9.4,
    });
  });

  test('location omits readings the device did not report', () async {
    final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{});

    await HomeRemoteDataSource(consumer).publishLocation(
      DeviceLocation(latitude: 1, longitude: 2, recordedAt: DateTime.utc(2026)),
    );

    expect(consumer.lastBody, <String, dynamic>{
      'latitude': 1.0,
      'longitude': 2.0,
    });
  });
}
