import 'package:dartz/dartz.dart';
import 'package:ssm_driver/core/services/location/device_location.dart';
import 'package:ssm_driver/core/services/location/location_failure.dart';
import 'package:ssm_driver/core/services/location/location_service.dart';

final DeviceLocation sampleLocation = DeviceLocation(
  latitude: 24.7136,
  longitude: 46.6753,
  accuracy: 8.5,
  heading: 120,
  speed: 9.4,
  recordedAt: DateTime.utc(2026, 9, 23, 9),
);

/// Returns [result] and records how it was asked.
class FakeLocationService implements LocationService {
  Either<LocationFailure, DeviceLocation> result = Right(sampleLocation);

  int calls = 0;
  final List<bool> permissionRequests = <bool>[];
  int appSettingsOpened = 0;
  int locationSettingsOpened = 0;

  @override
  Future<Either<LocationFailure, DeviceLocation>> currentLocation({
    bool requestPermission = false,
  }) async {
    calls++;
    permissionRequests.add(requestPermission);
    return result;
  }

  @override
  Future<void> openAppSettings() async => appSettingsOpened++;

  @override
  Future<void> openLocationSettings() async => locationSettingsOpened++;
}
