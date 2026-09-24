import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import 'device_location.dart';
import 'location_failure.dart';

/// Foreground ("while in use") device location. This is the boundary for
/// the platform plugin: nothing past it throws — every problem comes back
/// as a [LocationFailure].
abstract class LocationService {
  /// A fresh fix. With [requestPermission] the system prompt is shown if
  /// the permission hasn't been decided yet — pass it only for a Driver's
  /// explicit action, so background ticks never nag.
  Future<Either<LocationFailure, DeviceLocation>> currentLocation({
    bool requestPermission = false,
  });

  /// Where the Driver fixes [LocationIssue.permissionDeniedForever].
  Future<void> openAppSettings();

  /// Where the Driver fixes [LocationIssue.serviceDisabled].
  Future<void> openLocationSettings();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 15),
  );

  @override
  Future<Either<LocationFailure, DeviceLocation>> currentLocation({
    bool requestPermission = false,
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const Left(LocationFailure(LocationIssue.serviceDisabled));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }
      switch (permission) {
        case LocationPermission.denied:
          return const Left(LocationFailure(LocationIssue.permissionDenied));
        case LocationPermission.deniedForever:
          return const Left(
            LocationFailure(LocationIssue.permissionDeniedForever),
          );
        case LocationPermission.whileInUse:
        case LocationPermission.always:
        case LocationPermission.unableToDetermine:
          break;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );
      return Right(
        DeviceLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          // The platforms report "unknown" as a negative number.
          accuracy: position.accuracy >= 0 ? position.accuracy : null,
          heading: position.heading >= 0 && position.heading <= 360
              ? position.heading
              : null,
          speed: position.speed >= 0 ? position.speed : null,
          recordedAt: position.timestamp,
        ),
      );
    } on Exception {
      // Timeout, a permission prompt already open, platform errors, …
      return const Left(LocationFailure(LocationIssue.unavailable));
    }
  }

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
