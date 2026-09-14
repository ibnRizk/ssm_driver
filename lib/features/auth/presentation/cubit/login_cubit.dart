import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_state.dart';

/// Screen-scoped cubit for [LoginScreen] — provided at the route, not
/// app-wide (see `AppRoutes.login`).
///
/// No domain/data layer yet: there's no auth API to call, so [submitPhone]
/// just simulates the request. Once the OTP endpoint exists, replace the
/// delay with a use case call the same way `HomeCubit`'s doc comment shows,
/// and fold its `Either<Failure, T>` into [LoginSuccess] / [LoginError].
class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginInitial());

  Future<void> submitPhone(String phone) async {
    try {
      emit(const LoginLoading());
      // TODO: Replace with the real OTP/auth use case once the API exists.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      emit(const LoginSuccess());
    } catch (e) {
      emit(LoginError(message: e.toString()));
    }
  }
}
