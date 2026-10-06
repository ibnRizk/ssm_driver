import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/location/device_location.dart';
import '../../../../core/services/location/location_failure.dart';
import '../../../../core/services/location/location_service.dart';
import '../../domain/repositories/home_repository.dart';
import 'location_tracking_state.dart';

/// Keeps an online Driver dispatchable: every [interval] it publishes the
/// device location and sends a heartbeat. The server only offers orders to
/// Drivers whose heartbeat *and* location are under 120 s old (API docs §9).
///
/// While tracking, [LocationService.startBackgroundUpdates] keeps the app
/// alive in the background (Android foreground service, iOS background
/// location updates), so this timer keeps ticking while the Driver follows
/// Google Maps or locks the phone mid-trip.
class LocationTrackingCubit extends Cubit<LocationTrackingState> {
  final HomeRepository _repository;
  final LocationService _location;
  final Duration interval;

  Timer? _timer;
  bool _inFlight = false;

  LocationTrackingCubit(
    this._repository,
    this._location, {
    this.interval = const Duration(seconds: 20),
  }) : super(const TrackingStopped());

  bool get isTracking => _timer != null;

  /// Reports right away — asking for the location permission if it hasn't
  /// been decided — then every [interval]. No-op when already tracking.
  void start() {
    if (isTracking) return;
    _timer = Timer.periodic(interval, (_) => reportNow());
    emit(const TrackingActive());
    reportNow(requestPermission: true);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    unawaited(_location.stopBackgroundUpdates());
    if (!isClosed) emit(const TrackingStopped());
  }

  /// One location + heartbeat round. Periodic ticks never show the
  /// permission prompt; only the Driver's own actions do.
  Future<void> reportNow({bool requestPermission = false}) async {
    if (!isTracking || _inFlight) return;
    _inFlight = true;
    try {
      final Either<LocationFailure, DeviceLocation> fix = await _location
          .currentLocation(requestPermission: requestPermission);
      if (isClosed || !isTracking) return;

      final DeviceLocation? location = fix.fold((LocationFailure f) {
        emit(TrackingBlocked(f.issue));
        return null;
      }, (DeviceLocation l) => l);
      if (location != null) {
        emit(const TrackingActive());
        // Idempotent, so every tick retries until it runs: it needs the
        // permission, and Android only starts it from the foreground.
        await _location.startBackgroundUpdates();
        // Stopped while the service was starting: don't leave it running.
        if (isClosed || !isTracking) {
          await _location.stopBackgroundUpdates();
          return;
        }
        await _repository.publishLocation(location);
      }

      // Sent even without a fix, so a GPS hiccup doesn't look like the app
      // went away (API docs §9). Send failures are dropped on purpose: the
      // next tick retries, and a snackbar every 20 s would bury the screen.
      if (isClosed || !isTracking) return;
      await _repository.sendHeartbeat();
    } finally {
      _inFlight = false;
    }
  }

  /// The banner's action: send the Driver where the current issue is fixed,
  /// or ask again when a plain prompt can still solve it.
  Future<void> resolveIssue() async {
    final LocationTrackingState current = state;
    if (current is! TrackingBlocked) return;
    switch (current.issue) {
      case LocationIssue.permissionDeniedForever:
        await _location.openAppSettings();
      case LocationIssue.serviceDisabled:
        await _location.openLocationSettings();
      case LocationIssue.permissionDenied:
      case LocationIssue.unavailable:
        await reportNow(requestPermission: true);
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;
    unawaited(_location.stopBackgroundUpdates());
    return super.close();
  }
}
