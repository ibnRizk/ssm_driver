import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/home/domain/entities/incentive_summary.dart';
import 'package:ssm_driver/features/home/presentation/cubit/home_cubit.dart';
import 'package:ssm_driver/features/home/presentation/cubit/home_state.dart';

import 'home_test_fakes.dart';

void main() {
  late FakeHomeRepository repository;
  late HomeCubit cubit;

  setUp(() {
    repository = FakeHomeRepository();
    cubit = HomeCubit(repository);
  });

  tearDown(() => cubit.close());

  test('loading emits loading, then both summaries', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<HomeState>[
        const HomeLoading(),
        const HomeLoaded(cod: sampleCod, incentive: sampleIncentive),
      ]),
    );

    await cubit.loadDashboard();
    await expectation;
  });

  test('either summary failing emits its message', () async {
    repository.incentiveResult = const Left<Failure, IncentiveSummary>(
      NetworkFailure(message: 'No internet'),
    );

    await cubit.loadDashboard();

    expect(cubit.state, const HomeError(message: 'No internet'));
  });

  test('refreshing loaded numbers skips the loading state', () async {
    await cubit.loadDashboard();
    final List<HomeState> emitted = <HomeState>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.refreshDashboard();
    await subscription.cancel();

    expect(emitted.whereType<HomeLoading>(), isEmpty);
  });

  test('reset drops the loaded numbers', () async {
    await cubit.loadDashboard();

    cubit.reset();

    expect(cubit.state, const HomeInitial());
  });

  test('a fresh load always shows loading, even over old numbers', () async {
    await cubit.loadDashboard();

    final expectation = expectLater(cubit.stream, emits(const HomeLoading()));

    await cubit.loadDashboard();
    await expectation;
  });
}
