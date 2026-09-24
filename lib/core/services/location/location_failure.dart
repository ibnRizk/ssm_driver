import '../../error/failures.dart';
import '../../utils/values/strings.dart';

/// Why the device location couldn't be read — each needs a different fix
/// from the Driver.
enum LocationIssue {
  /// Not granted yet; asking again can still show the system prompt.
  permissionDenied,

  /// Blocked; only the app's system settings can grant it now.
  permissionDeniedForever,

  /// Device-wide location services are off.
  serviceDisabled,

  /// Granted and on, but no fix arrived (timeout, no signal, …).
  unavailable,
}

class LocationFailure extends Failure {
  final LocationIssue issue;

  const LocationFailure(this.issue);

  @override
  String get message => switch (issue) {
    LocationIssue.permissionDenied => Strings.locationPermissionDenied,
    LocationIssue.permissionDeniedForever =>
      Strings.locationPermissionDeniedForever,
    LocationIssue.serviceDisabled => Strings.locationServiceDisabled,
    LocationIssue.unavailable => Strings.locationUnavailable,
  };

  @override
  List<Object?> get props => [issue];
}
