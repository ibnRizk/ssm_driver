import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/home/data/repositories/home_repository_impl.dart';

import '../../helpers/key_localizations.dart';
import 'home_test_fakes.dart';

void main() {
  useKeyLocalizations();

  late FakeHomeRemoteDataSource remote;
  late HomeRepositoryImpl repository;

  setUp(() {
    remote = FakeHomeRemoteDataSource();
    repository = HomeRepositoryImpl(remote);
  });

  test('returns the server online flag', () async {
    final result = await repository.goOnline();

    expect(result.getOrElse(() => throw 'failed'), isTrue);
  });

  test(
    'a refused go-offline becomes a failure with the server message',
    () async {
      remote.error = const ServerException(
        message: 'You have active work and cannot go offline.',
      );

      final result = await repository.goOffline();

      expect(
        result.swap().getOrElse(() => throw 'succeeded'),
        const ServerFailure(
          message: 'You have active work and cannot go offline.',
        ),
      );
    },
  );

  test('an unexpected error becomes a generic server failure', () async {
    remote.error = StateError('boom');

    final result = await repository.getOnlineStatus();

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      isA<ServerFailure>(),
    );
  });
}
