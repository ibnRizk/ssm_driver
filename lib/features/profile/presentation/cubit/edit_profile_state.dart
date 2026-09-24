import 'package:equatable/equatable.dart';

sealed class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

class EditProfileSuccess extends EditProfileState {
  const EditProfileSuccess();
}

class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
