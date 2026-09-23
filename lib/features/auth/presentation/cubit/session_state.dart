import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding_status.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionChecking extends SessionState {
  const SessionChecking();
}

class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

class SessionApproved extends SessionState {
  const SessionApproved();
}

/// Pending or rejected. [isRefreshing] keeps the last status on screen while
/// a re-check is in flight.
class SessionNotApproved extends SessionState {
  final OnboardingStatus status;
  final bool isRefreshing;

  const SessionNotApproved({required this.status, this.isRefreshing = false});

  @override
  List<Object?> get props => [status, isRefreshing];
}

class SessionError extends SessionState {
  final String message;

  const SessionError({required this.message});

  @override
  List<Object?> get props => [message];
}
