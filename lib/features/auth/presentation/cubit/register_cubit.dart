import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/registration_data.dart';
import '../../domain/repositories/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit(this._authRepository) : super(const RegisterInitial());

  /// Registers, then logs straight in — a new Driver can authenticate while
  /// still pending, and needs the token for onboarding.
  Future<void> register(RegistrationData data) async {
    emit(const RegisterLoading());

    final Failure? registerFailure = (await _authRepository.register(
      data,
    )).fold((Failure f) => f, (_) => null);
    if (registerFailure != null) {
      emit(
        RegisterError(
          message: registerFailure.message ?? Strings.somethingWentWrong,
        ),
      );
      return;
    }

    final loginResult = await _authRepository.login(
      phone: data.phone,
      password: data.password,
    );
    emit(RegisterSuccess(approvalStatus: loginResult.toOption().toNullable()));
  }
}
