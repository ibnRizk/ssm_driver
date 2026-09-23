import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

/// Holds the signed-in Driver's profile. One instance is created by the
/// Profile tab and shared with the screens it pushes (e.g. My Data).
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await _repository.getProfile();
    if (isClosed) return;
    result.fold(
      (Failure f) =>
          emit(ProfileError(f.message ?? Strings.somethingWentWrong)),
      (DriverProfile profile) => emit(ProfileLoaded(profile)),
    );
  }
}
