import '../../../../core/utils/json_readers.dart';
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
    super.zoneName,
    super.rating,
    super.vehicle,
  });

  /// The endpoint returns the profile object at the top level (no `data`
  /// envelope). `zone`, `rating` and `vehicle` are each an object or null;
  /// `level`/`title` are always null (not modeled) and are ignored.
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
      zoneName: switch (json['zone']) {
        final Map<dynamic, dynamic> zone => _text(zone['name']),
        _ => null,
      },
      rating: switch (json['rating']) {
        final Map<dynamic, dynamic> r => switch (readDouble(r['average'])) {
          final double average => DriverRating(
            average: average,
            count: readInt(r['count']),
          ),
          null => null,
        },
        _ => null,
      },
      vehicle: switch (json['vehicle']) {
        final Map<dynamic, dynamic> v => switch (_text(v['name'])) {
          final String name => AssignedVehicle(
            id: readInt(v['id']),
            name: name,
            plateNumber: _text(v['plate_number']),
          ),
          null => null,
        },
        _ => null,
      },
    );
  }

  static String? _text(dynamic value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;
}
