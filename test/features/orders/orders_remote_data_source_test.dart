import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/features/orders/data/datasources/orders_remote_data_source.dart';

import 'orders_test_fakes.dart';

void main() {
  test('{"work": null} means no active order', () async {
    final source = OrdersRemoteDataSource(
      FakeDioConsumer(<String, dynamic>{'work': null}),
    );

    expect(await source.getCurrentWork(), isNull);
  });

  test('a bare work object is parsed', () async {
    final source = OrdersRemoteDataSource(FakeDioConsumer(currentWorkJson()));

    expect(await source.getCurrentWork(), sampleWork);
  });

  test('a work object inside the envelope is parsed', () async {
    final source = OrdersRemoteDataSource(
      FakeDioConsumer(<String, dynamic>{'work': currentWorkJson()}),
    );

    expect(await source.getCurrentWork(), sampleWork);
  });

  test('a non-object body is a server error', () async {
    final source = OrdersRemoteDataSource(FakeDioConsumer('<html>'));

    expect(source.getCurrentWork(), throwsA(isA<ServerException>()));
  });
}
