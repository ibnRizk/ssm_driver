import 'package:equatable/equatable.dart';

import '../../domain/entities/work_transition.dart';

/// The three delivery commands, in the only order the server accepts.
enum LifecycleAction { pickup, startDelivery, complete }

sealed class OrderLifecycleState extends Equatable {
  const OrderLifecycleState();

  @override
  List<Object?> get props => [];
}

class LifecycleIdle extends OrderLifecycleState {
  const LifecycleIdle();
}

class LifecycleInProgress extends OrderLifecycleState {
  final LifecycleAction action;

  const LifecycleInProgress(this.action);

  @override
  List<Object?> get props => [action];
}

class LifecycleSuccess extends OrderLifecycleState {
  final LifecycleAction action;
  final WorkTransition transition;

  const LifecycleSuccess(this.action, this.transition);

  @override
  List<Object?> get props => [action, transition];
}

/// [shouldRefreshWork] is true when the server gave a definitive answer
/// (e.g. 409 wrong sequence / stale version) — re-read `current-work` before
/// showing the next action. False for a network failure, which is retried
/// with the same idempotency key instead.
class LifecycleFailure extends OrderLifecycleState {
  final LifecycleAction action;
  final String message;
  final bool shouldRefreshWork;

  const LifecycleFailure(
    this.action,
    this.message, {
    required this.shouldRefreshWork,
  });

  @override
  List<Object?> get props => [action, message, shouldRefreshWork];
}
