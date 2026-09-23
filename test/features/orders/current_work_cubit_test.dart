import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/orders/domain/entities/current_work.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/current_work_cubit.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/current_work_state.dart';

import 'orders_test_fakes.dart';

void main() {
  late FakeOrdersRepository repository;
  late CurrentWorkCubit cubit;

  setUp(() {
    repository = FakeOrdersRepository();
    cubit = CurrentWorkCubit(repository);
  });

  tearDown(() => cubit.close());

  test('first load emits loading then the active order', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<CurrentWorkState>[
        const CurrentWorkLoading(),
        const CurrentWorkLoaded(sampleWork),
      ]),
    );

    await cubit.loadCurrentWork();
    await expectation;
  });

  test('no active order emits the empty state', () async {
    repository.result = const Right<Failure, CurrentWork?>(null);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<CurrentWorkState>[
        const CurrentWorkLoading(),
        const CurrentWorkEmpty(),
      ]),
    );

    await cubit.loadCurrentWork();
    await expectation;
  });

  test('refreshing loaded content skips the loading state', () async {
    await cubit.loadCurrentWork();
    repository.result = const Right<Failure, CurrentWork?>(null);

    final expectation = expectLater(
      cubit.stream,
      emits(const CurrentWorkEmpty()),
    );

    await cubit.loadCurrentWork();
    await expectation;
  });

  test('a failure emits its message', () async {
    repository.result = const Left<Failure, CurrentWork?>(
      NetworkFailure(message: 'No internet'),
    );

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<CurrentWorkState>[
        const CurrentWorkLoading(),
        const CurrentWorkError('No internet'),
      ]),
    );

    await cubit.loadCurrentWork();
    await expectation;
  });
}
