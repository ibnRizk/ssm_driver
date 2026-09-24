import 'package:equatable/equatable.dart';

import '../../../../core/services/location/location_failure.dart';

sealed class LocationTrackingState extends Equatable {
  const LocationTrackingState();

  @override
  List<Object?> get props => [];
}

/// Offline (or not started): nothing is being sent.
class TrackingStopped extends LocationTrackingState {
  const TrackingStopped();
}

/// Online, and the location is reaching dispatch.
class TrackingActive extends LocationTrackingState {
  const TrackingActive();
}

/// Online, but the device location can't be read. The heartbeat still goes
/// out; [issue] tells the Driver what to fix to become dispatchable again.
class TrackingBlocked extends LocationTrackingState {
  final LocationIssue issue;

  const TrackingBlocked(this.issue);

  @override
  List<Object?> get props => [issue];
}
