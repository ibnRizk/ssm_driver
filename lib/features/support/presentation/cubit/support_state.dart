import 'package:equatable/equatable.dart';

import '../../domain/entities/support_info.dart';

sealed class SupportState extends Equatable {
  const SupportState();

  @override
  List<Object?> get props => [];
}

class SupportLoading extends SupportState {
  const SupportLoading();
}

class SupportLoaded extends SupportState {
  final SupportInfo info;

  const SupportLoaded(this.info);

  @override
  List<Object?> get props => [info];
}

class SupportError extends SupportState {
  final String message;

  const SupportError(this.message);

  @override
  List<Object?> get props => [message];
}
