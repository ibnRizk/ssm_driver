import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/push/push_service.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/approval_status.dart';
import '../../domain/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  final PushService _push;

  LoginCubit(this._authRepository, this._push) : super(const LoginInitial());

  Future<void> login({required String phone, required String password}) async {
    emit(const LoginLoading());
    final result = await _authRepository.login(
      phone: phone,
      password: password,
    );
    result.fold(
      (Failure f) =>
          emit(LoginError(message: f.message ?? Strings.somethingWentWrong)),
      (ApprovalStatus status) {
        // Not awaited: navigation shouldn't wait on the permission prompt.
        unawaited(_push.registerDevice());
        emit(LoginSuccess(approvalStatus: status));
      },
    );
  }
}
