import 'package:equatable/equatable.dart';

/// One device position fix. Pure Dart so domain contracts can take it.
class DeviceLocation extends Equatable {
  final double latitude;
  final double longitude;

  /// Metres; `null` when the platform didn't report it (same for the rest).
  final double? accuracy;

  /// Degrees, 0–360.
  final double? heading;

  /// Metres per second.
  final double? speed;

  final DateTime recordedAt;

  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracy,
    this.heading,
    this.speed,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    accuracy,
    heading,
    speed,
    recordedAt,
  ];
}
