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

  const DriverProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.identityType,
    required this.identityNumber,
    this.imageUrl,
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
  ];
}
