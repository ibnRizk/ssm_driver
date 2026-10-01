import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/identity_type.dart';

/// The signed-in Driver's own profile (`GET /delivery-man/profile`).
class DriverProfile extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final IdentityType? identityType;
  final String identityNumber;
  final String? imageUrl;

  /// The registered zone's name; null when the server sent none.
  final String? zoneName;

  /// Null means no ratings yet — never show a made-up number.
  final DriverRating? rating;

  /// Null means no vehicle is assigned.
  final AssignedVehicle? vehicle;

  const DriverProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.identityType,
    required this.identityNumber,
    this.imageUrl,
    this.zoneName,
    this.rating,
    this.vehicle,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    phone,
    email,
    identityType,
    identityNumber,
    imageUrl,
    zoneName,
    rating,
    vehicle,
  ];
}

class DriverRating extends Equatable {
  final double average;
  final int count;

  const DriverRating({required this.average, required this.count});

  @override
  List<Object?> get props => [average, count];
}

class AssignedVehicle extends Equatable {
  final int id;
  final String name;

  /// Null when no plate is on file.
  final String? plateNumber;

  const AssignedVehicle({
    required this.id,
    required this.name,
    this.plateNumber,
  });

  @override
  List<Object?> get props => [id, name, plateNumber];
}
