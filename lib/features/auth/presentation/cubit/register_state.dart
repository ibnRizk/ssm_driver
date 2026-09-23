import 'package:equatable/equatable.dart';

import '../../domain/entities/approval_status.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

/// [approvalStatus] is null when the account was created but the automatic
/// follow-up login failed — the driver has to log in manually.
class RegisterSuccess extends RegisterState {
  final ApprovalStatus? approvalStatus;

  const RegisterSuccess({this.approvalStatus});

  @override
  List<Object?> get props => [approvalStatus];
}

class RegisterError extends RegisterState {
  final String message;

  const RegisterError({required this.message});

  @override
  List<Object?> get props => [message];
}
