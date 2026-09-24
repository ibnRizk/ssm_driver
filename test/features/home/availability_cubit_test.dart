import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/home/presentation/cubit/availability_cubit.dart';
import 'package:ssm_driver/features/home/presentation/cubit/availability_state.dart';

import 'home_test_fakes.dart';

void main() {
  late FakeHomeRepository repository;
  late AvailabilityCubit cubit;

  setUp(() {
    repository = FakeHomeRepository();
    cubit = AvailabilityCubit(repository);
  });

  tearDown(() => cubit.close());

  test('loading reads the server online flag', () async {
    await cubit.load();

    expect(cubit.state, const AvailabilityLoaded(isOnline: false));
  });

  test(
    'toggling while offline goes online after the server confirms',
    () async {
      await cubit.load();

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<AvailabilityState>[
          const AvailabilityLoaded(isOnline: false, isUpdating: true),
          const AvailabilityLoaded(isOnline: true),
        ]),
      );

      await cubit.toggle();
      await expectation;
    },
  );

  test('a refused go-offline keeps the Driver online with the error', () async {
    repository.onlineStatusResult = const Right<Failure, bool>(true);
    repository.goOfflineResult = const Left<Failure, bool>(
      ServerFailure(message: 'You have active work.'),
    );
    await cubit.load();

    await cubit.toggle();

    expect(
      cubit.state,
      const AvailabilityError(message: 'You have active work.', isOnline: true),
    );
  });

  test('a failed first read leaves the status unknown', () async {
    repository.onlineStatusResult = const Left<Failure, bool>(
      NetworkFailure(message: 'No internet'),
    );

    await cubit.load();

    expect(cubit.state, const AvailabilityError(message: 'No internet'));
  });

  test('a second tap while a toggle is in flight is ignored', () async {
    await cubit.load();

    final Future<void> first = cubit.toggle();
    await cubit.toggle();
    await first;

    expect(repository.toggleCalls, 1);
  });
}
