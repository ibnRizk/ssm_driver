import 'package:equatable/equatable.dart';

import '../../domain/entities/approval_status.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final ApprovalStatus approvalStatus;

  const LoginSuccess({required this.approvalStatus});

  @override
  List<Object?> get props => [approvalStatus];
}

class LoginError extends LoginState {
  final String message;

  const LoginError({required this.message});

  @override
  List<Object?> get props => [message];
}
