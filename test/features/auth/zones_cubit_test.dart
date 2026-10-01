import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/auth/domain/entities/zone.dart';
import 'package:ssm_driver/features/auth/presentation/cubit/zones_cubit.dart';
import 'package:ssm_driver/features/auth/presentation/cubit/zones_state.dart';

import 'auth_test_fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late ZonesCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = ZonesCubit(repository);
  });

  tearDown(() => cubit.close());

  test('starts loading', () {
    expect(cubit.state, const ZonesLoading());
  });

  test('load emits the zones', () async {
    await cubit.load();

    expect(cubit.state, const ZonesLoaded(<Zone>[Zone(id: 1, name: 'Riyadh')]));
  });

  test('a failure emits its message', () async {
    repository.zonesResult = const Left<Failure, List<Zone>>(
      NetworkFailure(message: 'offline'),
    );

    await cubit.load();

    expect(cubit.state, const ZonesError(message: 'offline'));
  });

  test('an empty list is reported as empty', () async {
    repository.zonesResult = const Right<Failure, List<Zone>>(<Zone>[]);

    await cubit.load();

    expect(cubit.state, const ZonesEmpty());
  });

  test('retrying after a failure loads the zones', () async {
    repository.zonesResult = const Left<Failure, List<Zone>>(
      NetworkFailure(message: 'offline'),
    );
    await cubit.load();

    repository.zonesResult = const Right<Failure, List<Zone>>(<Zone>[
      Zone(id: 2, name: 'Jeddah'),
    ]);
    await cubit.load();

    expect(cubit.state, const ZonesLoaded(<Zone>[Zone(id: 2, name: 'Jeddah')]));
  });
}
