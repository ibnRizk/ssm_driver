import 'identity_type.dart';

class RegistrationData {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final IdentityType identityType;
  final String identityNumber;
  final String password;
  final int zoneId;
  final int vehicleId;

  const RegistrationData({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.identityType,
    required this.identityNumber,
    required this.password,
    required this.zoneId,
    required this.vehicleId,
  });
}
