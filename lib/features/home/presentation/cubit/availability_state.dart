import 'package:equatable/equatable.dart';

sealed class AvailabilityState extends Equatable {
  const AvailabilityState();

  /// The server's last confirmed value; `null` while it isn't known yet.
  bool? get isOnline;

  @override
  List<Object?> get props => [isOnline];
}

class AvailabilityLoading extends AvailabilityState {
  const AvailabilityLoading();

  @override
  bool? get isOnline => null;
}

/// [isUpdating] is true while an online/offline request is in flight;
/// [isOnline] still shows the confirmed value until the server answers.
class AvailabilityLoaded extends AvailabilityState {
  @override
  final bool isOnline;
  final bool isUpdating;

  const AvailabilityLoaded({required this.isOnline, this.isUpdating = false});

  @override
  List<Object?> get props => [isOnline, isUpdating];
}

/// A failed read or toggle. [isOnline] keeps the last confirmed value —
/// e.g. going offline refused while the Driver owns active work.
class AvailabilityError extends AvailabilityState {
  final String message;
  @override
  final bool? isOnline;

  const AvailabilityError({required this.message, this.isOnline});

  @override
  List<Object?> get props => [message, isOnline];
}
