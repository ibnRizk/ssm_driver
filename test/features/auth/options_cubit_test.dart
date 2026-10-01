import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/auth/domain/entities/zone.dart';
import 'package:ssm_driver/features/auth/presentation/cubit/options_cubit.dart';
import 'package:ssm_driver/features/auth/presentation/cubit/options_state.dart';

void main() {
  late Either<Failure, List<Zone>> result;
  late OptionsCubit<Zone> cubit;

  setUp(() {
    result = const Right<Failure, List<Zone>>(<Zone>[
      Zone(id: 1, name: 'Riyadh'),
    ]);
    cubit = OptionsCubit<Zone>(() async => result);
  });

  tearDown(() => cubit.close());

  test('starts loading', () {
    expect(cubit.state, const OptionsLoading<Zone>());
  });

  test('load emits the options', () async {
    await cubit.load();

    expect(
      cubit.state,
      const OptionsLoaded<Zone>(<Zone>[Zone(id: 1, name: 'Riyadh')]),
    );
  });

  test('a failure emits its message', () async {
    result = const Left<Failure, List<Zone>>(
      NetworkFailure(message: 'offline'),
    );

    await cubit.load();

    expect(cubit.state, const OptionsError<Zone>(message: 'offline'));
  });

  test('an empty list is reported as empty', () async {
    result = const Right<Failure, List<Zone>>(<Zone>[]);

    await cubit.load();

    expect(cubit.state, const OptionsEmpty<Zone>());
  });

  test('retrying after a failure loads the options', () async {
    result = const Left<Failure, List<Zone>>(
      NetworkFailure(message: 'offline'),
    );
    await cubit.load();

    result = const Right<Failure, List<Zone>>(<Zone>[
      Zone(id: 2, name: 'Jeddah'),
    ]);
    await cubit.load();

    expect(
      cubit.state,
      const OptionsLoaded<Zone>(<Zone>[Zone(id: 2, name: 'Jeddah')]),
    );
  });
}
