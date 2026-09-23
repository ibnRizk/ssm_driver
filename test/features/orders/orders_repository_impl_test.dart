import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/orders/data/repositories/orders_repository_impl.dart';

import 'orders_test_fakes.dart';

void main() {
  late FakeOrdersRemoteDataSource remote;
  late OrdersRepositoryImpl repository;

  setUp(() {
    remote = FakeOrdersRemoteDataSource();
    repository = OrdersRepositoryImpl(remote);
  });

  test('returns the active order', () async {
    final result = await repository.getCurrentWork();

    expect(result.getOrElse(() => throw 'failed'), sampleWork);
  });

  test('returns null when there is no active order', () async {
    remote.work = null;

    final result = await repository.getCurrentWork();

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => throw 'failed'), isNull);
  });

  test('maps a not-approved driver error to a failure', () async {
    remote.error = const ServerException(
      message: 'Driver account is not approved.',
    );

    final result = await repository.getCurrentWork();

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      const ServerFailure(message: 'Driver account is not approved.'),
    );
  });
}
