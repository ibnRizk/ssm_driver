import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/orders/data/repositories/orders_repository_impl.dart';

import '../../helpers/key_localizations.dart';
import 'orders_test_fakes.dart';

void main() {
  useKeyLocalizations();

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

  test('returns the active offer', () async {
    final result = await repository.getActiveOffer();

    expect(result.getOrElse(() => throw 'failed'), sampleOffer);
  });

  test(
    'maps a 409 on accept to a failure carrying the server message',
    () async {
      remote.error = const ServerException(message: 'Assignment conflict.');

      final result = await repository.acceptOffer(501, idempotencyKey: 'k');

      expect(
        result.swap().getOrElse(() => throw 'succeeded'),
        const ServerFailure(message: 'Assignment conflict.'),
      );
    },
  );

  test('maps a timeout on a lifecycle command to a network failure', () async {
    remote.error = const InternetConnectionException(message: 'offline');

    final result = await repository.confirmPickup(
      orderId: 100001,
      idempotencyKey: 'k',
    );

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      const NetworkFailure(message: 'offline'),
    );
  });

  test('returns the transition of a completed delivery', () async {
    final result = await repository.completeWithOtp(
      orderId: 100001,
      otp: '123456',
      codCollected: true,
      idempotencyKey: 'k',
    );

    expect(result.getOrElse(() => throw 'failed'), pickedUpTransition);
  });

  test('an unexpected error becomes a generic server failure', () async {
    remote.error = StateError('boom');

    final result = await repository.getActiveOffer();

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      isA<ServerFailure>(),
    );
  });
}
