import 'package:dartz/dartz.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/auth/domain/entities/approval_status.dart';
import 'package:ssm_driver/features/auth/domain/entities/onboarding_status.dart';
import 'package:ssm_driver/features/auth/presentation/cubit/session_cubit.dart';
import 'package:ssm_driver/features/auth/presentation/cubit/session_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_push_service.dart';
import 'auth_test_fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late FakePushService push;
  late SessionCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    push = FakePushService();
    cubit = SessionCubit(repository, push);
  });

  tearDown(() => cubit.close());

  test('no stored token goes straight to unauthenticated', () async {
    repository.hasSession = false;

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<SessionState>[
        const SessionChecking(),
        const SessionUnauthenticated(),
      ]),
    );
    await cubit.checkSession();
    await expectation;
  });

  test('a rejected token (401) logs out', () async {
    repository.validateResult = const Left<Failure, Unit>(
      UnauthorizedFailure(message: 'Unauthorized.'),
    );

    await cubit.checkSession();

    expect(repository.loggedOut, isTrue);
    expect(cubit.state, const SessionUnauthenticated());
  });

  test('a pending driver is held at the onboarding status', () async {
    await cubit.checkSession();

    expect(
      cubit.state,
      const SessionNotApproved(status: FakeAuthRepository.pendingStatus),
    );
  });

  test('an approved driver is let through', () async {
    repository.statusResult = const Right<Failure, OnboardingStatus>(
      OnboardingStatus(
        name: 'Driver',
        approvalStatus: ApprovalStatus.approved,
        canOperate: true,
      ),
    );

    await cubit.checkSession();

    expect(cubit.state, const SessionApproved());
  });

  test('a network failure shows the error instead of logging out', () async {
    repository.validateResult = const Left<Failure, Unit>(
      NetworkFailure(message: 'No internet connection'),
    );

    await cubit.checkSession();

    expect(repository.loggedOut, isFalse);
    expect(cubit.state, const SessionError(message: 'No internet connection'));
  });

  group('push registration', () {
    test('a validated session registers the device', () async {
      await cubit.checkSession();

      expect(push.registerCalls, 1);
    });

    test('a rejected token does not register the device', () async {
      repository.validateResult = const Left<Failure, Unit>(
        UnauthorizedFailure(message: 'Unauthorized.'),
      );

      await cubit.checkSession();

      expect(push.registerCalls, 0);
    });

    test('logging out unregisters the device', () async {
      await cubit.logout();

      expect(push.unregisterCalls, 1);
    });
  });
}
