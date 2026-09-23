import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/values/strings.dart';
import 'register_state.dart';

/// Matches the API contract's `identity_type` values exactly.
enum IdentityType {
  nid('nid'),
  passport('passport'),
  drivingLicense('driving_license');

  final String apiValue;
  const IdentityType(this.apiValue);

  String get label {
    switch (this) {
      case IdentityType.nid:
        return Strings.authIdentityTypeNid;
      case IdentityType.passport:
        return Strings.authIdentityTypePassport;
      case IdentityType.drivingLicense:
        return Strings.authIdentityTypeDrivingLicense;
    }
  }
}

/// Screen-scoped cubit for [RegisterScreen] — provided at the route, not
/// app-wide (see `AppRoutes.register`).
///
/// No domain/data layer yet: there's no registration API to call, so
/// [register] just simulates the request. Once the endpoint exists, replace
/// the delay with a use case call the same way `HomeCubit`'s doc comment
/// shows, and fold its `Either<Failure, T>` into [RegisterSuccess] /
/// [RegisterError].
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterInitial());

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required IdentityType identityType,
    required String identityNumber,
    required String password,
    required String zone,
    required String vehicleType,
  }) async {
    try {
      emit(const RegisterLoading());
      // TODO: Replace with the real registration use case once the API exists.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      emit(const RegisterSuccess());
    } catch (e) {
      emit(RegisterError(message: e.toString()));
    }
  }
}
