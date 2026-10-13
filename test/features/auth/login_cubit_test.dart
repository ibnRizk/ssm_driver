import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/auth/domain/entities/approval_status.dart';
import 'package:ssm_driver/features/auth/presentation/cubit/login_cubit.dart';
import 'package:ssm_driver/features/auth/presentation/cubit/login_state.dart';

import '../../helpers/fake_push_service.dart';
import 'auth_test_fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late FakePushService push;
  late LoginCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    push = FakePushService();
    cubit = LoginCubit(repository, push);
  });

  tearDown(() => cubit.close());

  Future<void> login() => cubit.login(phone: '500000000', password: 'x');

  test('a successful login registers the device for push', () async {
    await login();

    expect(cubit.state, const LoginSuccess(approvalStatus: ApprovalStatus.approved));
    expect(push.registerCalls, 1);
  });

  test('a failed login does not register the device', () async {
    repository.loginResult = const Left<Failure, ApprovalStatus>(
      UnauthorizedFailure(message: 'Wrong credentials'),
    );

    await login();

    expect(push.registerCalls, 0);
  });
}
