import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/auth/data/models/zone_model.dart';
import 'package:ssm_driver/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ssm_driver/features/auth/domain/entities/approval_status.dart';
import 'package:ssm_driver/features/auth/domain/entities/identity_type.dart';
import 'package:ssm_driver/features/auth/domain/entities/registration_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_test_fakes.dart';

void main() {
  late FakeAuthRemoteDataSource remote;
  late FakeSecureStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = FakeAuthRemoteDataSource();
    storage = FakeSecureStorage();
    repository = AuthRepositoryImpl(remote: remote, storage: storage);
  });

  test('login stores the token and returns the approval status', () async {
    final result = await repository.login(phone: '0500000000', password: 'x');

    expect(result.getOrElse(() => throw 'failed'), ApprovalStatus.pending);
    expect(storage.token, 'opaque-token');
  });

  test('wrong credentials surface the backend message and store nothing', () async {
    remote.error = const UnauthorizedException(
      message: 'Incorrect credential, please try again',
    );

    final result = await repository.login(phone: '0500000000', password: 'x');

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      const UnauthorizedFailure(message: 'Incorrect credential, please try again'),
    );
    expect(storage.token, isNull);
  });

  test('register validation errors surface the backend message', () async {
    remote.error = const ServerException(
      message: 'The phone has already been taken.',
    );

    final result = await repository.register(
      const RegistrationData(
        firstName: 'Ahmed',
        lastName: 'Ali',
        phone: '0500000000',
        email: 'driver@example.com',
        identityType: IdentityType.nid,
        identityNumber: '1099887766',
        password: 'Strong#Pass2026',
        zoneId: 1,
        vehicleId: 1,
      ),
    );

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      const ServerFailure(message: 'The phone has already been taken.'),
    );
  });

  test('getZones returns the zones', () async {
    final result = await repository.getZones();

    expect(
      result.getOrElse(() => throw 'failed'),
      const <ZoneModel>[ZoneModel(id: 1, name: 'Riyadh')],
    );
  });

  test('a zones network error becomes a failure', () async {
    remote.error = const InternetConnectionException(message: 'offline');

    final result = await repository.getZones();

    expect(result.isLeft(), isTrue);
  });

  test('logout clears the stored session', () async {
    storage.token = 'opaque-token';

    await repository.logout();

    expect(await repository.hasStoredSession(), isFalse);
  });
}
