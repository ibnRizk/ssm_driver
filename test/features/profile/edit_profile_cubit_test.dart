import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:ssm_driver/features/profile/presentation/cubit/edit_profile_state.dart';

import 'profile_test_fakes.dart';

void main() {
  late FakeProfileRepository repository;
  late EditProfileCubit cubit;

  setUp(() {
    repository = FakeProfileRepository();
    cubit = EditProfileCubit(repository);
  });

  tearDown(() => cubit.close());

  test('submit emits loading then success', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<EditProfileState>[
        const EditProfileLoading(),
        const EditProfileSuccess(),
      ]),
    );

    await cubit.submit(sampleUpdate);
    await expectation;
  });

  test('submit emits the server validation message on failure', () async {
    repository.updateResult = const Left<Failure, Unit>(
      ServerFailure(message: 'The phone has already been taken.'),
    );

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<EditProfileState>[
        const EditProfileLoading(),
        const EditProfileError('The phone has already been taken.'),
      ]),
    );

    await cubit.submit(sampleUpdate);
    await expectation;
  });

  test('submit ignores a second tap while a save is in flight', () async {
    final Future<void> first = cubit.submit(sampleUpdate);
    await cubit.submit(sampleUpdate);
    await first;

    expect(repository.updateCalls, 1);
  });
}
