import 'dart:async';
import 'dart:io' show Platform;

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/values/strings.dart';
import 'device_location.dart';
import 'location_failure.dart';

/// Device location ("while in use" permission). This is the boundary for
/// the platform plugin: nothing past it throws — every problem comes back
/// as a [LocationFailure].
abstract class LocationService {
  /// A fresh fix. With [requestPermission] the system prompt is shown if
  /// the permission hasn't been decided yet — pass it only for a Driver's
  /// explicit action, so background ticks never nag.
  Future<Either<LocationFailure, DeviceLocation>> currentLocation({
    bool requestPermission = false,
  });

  /// Keeps location updates — and with them the app's own timers — running
  /// while the app is in the background, e.g. while the Driver follows
  /// Google Maps: an Android foreground service with an ongoing
  /// notification, and iOS background location updates (blue status-bar
  /// indicator). Idempotent. False when it couldn't start: no permission
  /// yet, or Android refused to start the service from the background —
  /// call again later.
  Future<bool> startBackgroundUpdates();

  /// Ends [startBackgroundUpdates]; removes the notification.
  Future<void> stopBackgroundUpdates();

  /// Where the Driver fixes [LocationIssue.permissionDeniedForever].
  Future<void> openAppSettings();

  /// Where the Driver fixes [LocationIssue.serviceDisabled].
  Future<void> openLocationSettings();
}

/// Register as a singleton: it owns the background stream.
class GeolocatorLocationService implements LocationService {
  GeolocatorLocationService();

  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 15),
  );

  /// A streamed fix younger than this is answered from memory: a one-shot
  /// request from the background is unreliable on iOS, and the stream
  /// already has the position.
  static const Duration _maxStreamedFixAge = Duration(seconds: 30);

  StreamSubscription<Position>? _backgroundUpdates;
  Position? _latestStreamed;

  @override
  Future<Either<LocationFailure, DeviceLocation>> currentLocation({
    bool requestPermission = false,
  }) async {
    final Position? streamed = _latestStreamed;
    if (_backgroundUpdates != null &&
        streamed != null &&
        DateTime.now().difference(streamed.timestamp) < _maxStreamedFixAge) {
      return Right(_toDeviceLocation(streamed));
    }
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
      return Right(_toDeviceLocation(position));
    } on Exception {
      // Timeout, a permission prompt already open, platform errors, …
      return const Left(LocationFailure(LocationIssue.unavailable));
    }
  }

  @override
  Future<bool> startBackgroundUpdates() async {
    if (_backgroundUpdates != null) return true;
    try {
      final LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return false;
      }
      final Completer<bool> started = Completer<bool>();
      _backgroundUpdates = Geolocator.getPositionStream(
        locationSettings: _backgroundSettings(),
      ).listen(
        (Position position) {
          _latestStreamed = position;
          if (!started.isCompleted) started.complete(true);
        },
        // The stream ends on errors such as the service being refused or
        // location turned off; the next call starts it again.
        onError: (Object _) {
          _clearBackgroundUpdates();
          if (!started.isCompleted) started.complete(false);
        },
        onDone: _clearBackgroundUpdates,
        cancelOnError: true,
      );
      // The service starts with the stream; a quiet GPS isn't a failure.
      return await started.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => _backgroundUpdates != null,
      );
    } on Exception {
      await stopBackgroundUpdates();
      return false;
    }
  }

  @override
  Future<void> stopBackgroundUpdates() async {
    final StreamSubscription<Position>? updates = _backgroundUpdates;
    _clearBackgroundUpdates();
    await updates?.cancel();
  }

  void _clearBackgroundUpdates() {
    _backgroundUpdates = null;
    _latestStreamed = null;
  }

  /// The distance filter keeps a parked Driver from waking the CPU; the
  /// heartbeat timer still reports every tick.
  static LocationSettings _backgroundSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: Strings.locationServiceNotificationTitle,
          notificationText: Strings.locationServiceNotificationText,
          notificationChannelName: Strings.locationServiceChannelName,
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }

  static DeviceLocation _toDeviceLocation(Position position) => DeviceLocation(
    latitude: position.latitude,
    longitude: position.longitude,
    // The platforms report "unknown" as a negative number.
    accuracy: position.accuracy >= 0 ? position.accuracy : null,
    heading: position.heading >= 0 && position.heading <= 360
        ? position.heading
        : null,
    speed: position.speed >= 0 ? position.speed : null,
    recordedAt: position.timestamp,
  );

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
