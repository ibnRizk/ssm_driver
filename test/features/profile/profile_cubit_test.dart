import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/profile/domain/entities/driver_profile.dart';
import 'package:ssm_driver/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:ssm_driver/features/profile/presentation/cubit/profile_state.dart';

import 'profile_test_fakes.dart';

void main() {
  late FakeProfileRepository repository;
  late ProfileCubit cubit;

  setUp(() {
    repository = FakeProfileRepository();
    cubit = ProfileCubit(repository);
  });

  tearDown(() => cubit.close());

  test('loadProfile emits loading then the loaded profile', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<ProfileState>[
        const ProfileLoading(),
        const ProfileLoaded(sampleProfile),
      ]),
    );

    await cubit.loadProfile();
    await expectation;
  });

  test('loadProfile emits the failure message on error', () async {
    repository.result = const Left<Failure, DriverProfile>(
      NetworkFailure(message: 'No internet'),
    );

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<ProfileState>[
        const ProfileLoading(),
        const ProfileError('No internet'),
      ]),
    );

    await cubit.loadProfile();
    await expectation;
  });
}
