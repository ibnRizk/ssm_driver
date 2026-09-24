import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/profile_update.dart';
import '../../domain/repositories/profile_repository.dart';
import 'edit_profile_state.dart';

/// Submits the Edit Profile form. Kept apart from `ProfileCubit` so a failed
/// save never replaces the loaded profile the Profile tab is showing.
class EditProfileCubit extends Cubit<EditProfileState> {
  final ProfileRepository _repository;

  EditProfileCubit(this._repository) : super(const EditProfileInitial());

  Future<void> submit(ProfileUpdate update) async {
    if (state is EditProfileLoading) return;
    emit(const EditProfileLoading());
    final result = await _repository.updateProfile(update);
    if (isClosed) return;
    result.fold(
      (Failure f) =>
          emit(EditProfileError(f.message ?? Strings.somethingWentWrong)),
      (_) => emit(const EditProfileSuccess()),
    );
  }
}
