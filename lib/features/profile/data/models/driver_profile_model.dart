import '../../../auth/domain/entities/identity_type.dart';
import '../../domain/entities/driver_profile.dart';

class DriverProfileModel extends DriverProfile {
  const DriverProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.email,
    required super.identityType,
    required super.identityNumber,
    super.imageUrl,
  });

  /// The endpoint returns the profile object at the top level (no `data`
  /// envelope).
  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: json['f_name'] as String? ?? '',
      lastName: json['l_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      identityType: IdentityType.fromApi(json['identity_type'] as String?),
      identityNumber: json['identity_number']?.toString() ?? '',
      imageUrl: json['image_full_url'] as String?,
    );
  }
}
