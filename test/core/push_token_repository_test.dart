import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/api/api_endpoints.dart';
import 'package:ssm_driver/core/api/dio_consumer.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/push/push_token_remote_data_source.dart';
import 'package:ssm_driver/core/services/push/push_token_repository.dart';

import '../helpers/key_localizations.dart';

/// Records PUTs; throws [error] when set.
class _FakeDioConsumer implements DioConsumer {
  Object? error;
  int putCalls = 0;
  String? lastPath;
  Map<String, dynamic>? lastBody;

  @override
  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    putCalls++;
    lastPath = path;
    lastBody = body;
    if (error != null) throw error!;
    return <String, dynamic>{'message': 'updated'};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  useKeyLocalizations();

  late _FakeDioConsumer consumer;
  late PushTokenRepository repository;

  setUp(() {
    consumer = _FakeDioConsumer();
    repository = PushTokenRepositoryImpl(PushTokenRemoteDataSource(consumer));
  });

  test('PUTs the token to update-fcm-token', () async {
    await repository.updateFcmToken('device-token');

    expect(consumer.lastPath, ApiEndpoints.updateFcmToken);
    expect(consumer.lastBody, <String, dynamic>{'fcm_token': 'device-token'});
  });

  test('success is unit', () async {
    expect(
      await repository.updateFcmToken('device-token'),
      const Right<Failure, Unit>(unit),
    );
  });

  test('an empty token is refused without a request', () async {
    final Either<Failure, Unit> result = await repository.updateFcmToken('');

    expect(result.isLeft(), isTrue);
    expect(consumer.putCalls, 0);
  });

  test('a 401 maps to UnauthorizedFailure', () async {
    consumer.error = const UnauthorizedException(message: 'Unauthorized.');

    expect(
      await repository.updateFcmToken('device-token'),
      const Left<Failure, Unit>(UnauthorizedFailure(message: 'Unauthorized.')),
    );
  });

  test('an unexpected error maps to ServerFailure', () async {
    consumer.error = StateError('boom');

    final Either<Failure, Unit> result = await repository.updateFcmToken('t');

    expect(result.fold((Failure f) => f, (_) => null), isA<ServerFailure>());
  });
}
