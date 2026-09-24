import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/orders/domain/entities/current_work.dart';
import 'package:ssm_driver/features/orders/domain/entities/work_transition.dart';
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

  test('a load that must not keep stale content shows loading first', () async {
    repository.result = const Right<Failure, CurrentWork?>(null);
    await cubit.loadCurrentWork();
    repository.result = const Right<Failure, CurrentWork?>(sampleWork);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<CurrentWorkState>[
        const CurrentWorkLoading(),
        const CurrentWorkLoaded(sampleWork),
      ]),
    );

    await cubit.loadCurrentWork(keepContent: false);
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

  test('reset drops the loaded order', () async {
    await cubit.loadCurrentWork();

    cubit.reset();

    expect(cubit.state, const CurrentWorkInitial());
  });

  group('applyTransition', () {
    test(
      'updates the loaded order to the confirmed status and version',
      () async {
        await cubit.loadCurrentWork();

        await cubit.applyTransition(pickedUpTransition);

        expect(
          cubit.state,
          CurrentWorkLoaded(sampleWork.withStatus(WorkStatus.pickedUp, 7)),
        );
      },
    );

    test('a delivered order leaves no active work', () async {
      await cubit.loadCurrentWork();

      await cubit.applyTransition(
        const WorkTransition(
          orderId: 100001,
          status: WorkStatus.delivered,
          statusVersion: 8,
        ),
      );

      expect(cubit.state, const CurrentWorkEmpty());
    });

    test('a transition for another order re-reads current work', () async {
      await cubit.loadCurrentWork();
      final int callsBefore = repository.currentWorkCalls;

      await cubit.applyTransition(
        const WorkTransition(
          orderId: 42,
          status: WorkStatus.pickedUp,
          statusVersion: 2,
        ),
      );

      expect(repository.currentWorkCalls, callsBefore + 1);
    });
  });
}
