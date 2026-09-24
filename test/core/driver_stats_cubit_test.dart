import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/general_cubit/driver_stats_cubit.dart';
import 'package:ssm_driver/core/general_cubit/driver_stats_state.dart';
import 'package:ssm_driver/core/services/driver_stats/incentive_summary.dart';

import 'driver_stats_test_fakes.dart';

void main() {
  late FakeDriverStatsRepository repository;
  late DriverStatsCubit cubit;

  setUp(() {
    repository = FakeDriverStatsRepository();
    cubit = DriverStatsCubit(repository);
  });

  tearDown(() => cubit.close());

  test('loading emits loading, then both summaries', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<DriverStatsState>[
        const DriverStatsLoading(),
        const DriverStatsLoaded(cod: sampleCod, incentive: sampleIncentive),
      ]),
    );

    await cubit.loadStats();
    await expectation;
  });

  test('either summary failing emits its message', () async {
    repository.incentiveResult = const Left<Failure, IncentiveSummary>(
      NetworkFailure(message: 'No internet'),
    );

    await cubit.loadStats();

    expect(cubit.state, const DriverStatsError(message: 'No internet'));
  });

  test('refreshing loaded numbers skips the loading state', () async {
    await cubit.loadStats();
    final List<DriverStatsState> emitted = <DriverStatsState>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.refreshStats();
    await subscription.cancel();

    expect(emitted.whereType<DriverStatsLoading>(), isEmpty);
  });

  test('reset drops the loaded numbers', () async {
    await cubit.loadStats();

    cubit.reset();

    expect(cubit.state, const DriverStatsInitial());
  });

  test('a fresh load always shows loading, even over old numbers', () async {
    await cubit.loadStats();

    final expectation = expectLater(cubit.stream, emits(const DriverStatsLoading()));

    await cubit.loadStats();
    await expectation;
  });
}
