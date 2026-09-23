import 'package:equatable/equatable.dart';

import '../../domain/entities/current_work.dart';

sealed class CurrentWorkState extends Equatable {
  const CurrentWorkState();

  @override
  List<Object?> get props => [];
}

class CurrentWorkInitial extends CurrentWorkState {
  const CurrentWorkInitial();
}

class CurrentWorkLoading extends CurrentWorkState {
  const CurrentWorkLoading();
}

class CurrentWorkLoaded extends CurrentWorkState {
  final CurrentWork work;

  const CurrentWorkLoaded(this.work);

  @override
  List<Object?> get props => [work];
}

/// The Driver has no accepted active order.
class CurrentWorkEmpty extends CurrentWorkState {
  const CurrentWorkEmpty();
}

class CurrentWorkError extends CurrentWorkState {
  final String message;

  const CurrentWorkError(this.message);

  @override
  List<Object?> get props => [message];
}
