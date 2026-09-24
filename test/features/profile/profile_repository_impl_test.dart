import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/config/locale/app_localizations.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ssm_driver/injection_container.dart';

import 'profile_test_fakes.dart';

/// Echoes keys back so `Strings.*` resolve without loading `lang/*.json`.
class _KeyLocalizations extends AppLocalizations {
  _KeyLocalizations() : super(null);

  @override
  String text(String key) => key;
}

void main() {
  late FakeProfileRemoteDataSource remote;
  late ProfileRepositoryImpl repository;

  setUpAll(() => ServiceLocator.injectAppLocalizations(_KeyLocalizations()));

  tearDownAll(() => ServiceLocator.instance.unregister<AppLocalizations>());

  setUp(() {
    remote = FakeProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(remote);
  });

  test('returns the profile on success', () async {
    final result = await repository.getProfile();

    expect(result.getOrElse(() => throw 'failed'), sampleProfile);
  });

  test('maps an expired token to UnauthorizedFailure', () async {
    remote.error = const UnauthorizedException(message: 'Unauthenticated.');

    final result = await repository.getProfile();

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      const UnauthorizedFailure(message: 'Unauthenticated.'),
    );
  });

  test('updateProfile passes the update to the data source', () async {
    final result = await repository.updateProfile(sampleUpdate);

    expect(result.isRight(), isTrue);
    expect(remote.lastUpdate, same(sampleUpdate));
  });

  test('updateProfile maps a validation error to its message', () async {
    remote.error = const ServerException(
      message: 'The phone has already been taken.',
    );

    final result = await repository.updateProfile(sampleUpdate);

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      const ServerFailure(message: 'The phone has already been taken.'),
    );
  });

  test('maps an unexpected error to a generic ServerFailure', () async {
    remote.error = const FormatException('bad payload');

    final result = await repository.getProfile();

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      const ServerFailure(message: 'something_went_wrong'),
    );
  });
}
