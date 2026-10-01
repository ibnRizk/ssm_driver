import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/features/auth/domain/entities/identity_type.dart';
import 'package:ssm_driver/features/profile/data/models/driver_profile_model.dart';
import 'package:ssm_driver/features/profile/domain/entities/driver_profile.dart';

import 'profile_test_fakes.dart';

void main() {
  test('parses the documented GET /delivery-man/profile response', () {
    final DriverProfileModel model =
        DriverProfileModel.fromJson(<String, dynamic>{
          'id': 1,
          'f_name': 'DriverA',
          'l_name': 'Fixture',
          'phone': '+966500000101',
          'email': 'driver.A@ssm.test',
          'identity_number': '1000000A',
          'identity_type': 'nid',
          'identity_image_full_url': <dynamic>[],
          'image_full_url': null,
          'zone_id': 1,
          'active': 1,
          'is_online': false,
        });

    expect(model, sampleProfile);
    expect(model.fullName, 'DriverA Fixture');
  });

  group('zone, rating and vehicle', () {
    test('parse the documented extended fields', () {
      final DriverProfileModel model =
          DriverProfileModel.fromJson(<String, dynamic>{
            'zone': <String, dynamic>{'id': 7, 'name': 'المنصورة'},
            'rating': <String, dynamic>{'average': 4.9, 'count': 132},
            'vehicle': <String, dynamic>{
              'id': 1,
              'name': 'دراجة نارية',
              'plate_number': null,
            },
            'level': null,
            'title': null,
          });

      expect(model.zoneName, 'المنصورة');
      expect(model.rating, const DriverRating(average: 4.9, count: 132));
      expect(
        model.vehicle,
        const AssignedVehicle(id: 1, name: 'دراجة نارية'),
      );
    });

    test('null values mean none — no placeholder data', () {
      final DriverProfileModel model = DriverProfileModel.fromJson(
        <String, dynamic>{'zone': null, 'rating': null, 'vehicle': null},
      );

      expect(model.zoneName, isNull);
      expect(model.rating, isNull);
      expect(model.vehicle, isNull);
    });

    test('a rating without an average is no rating', () {
      final DriverProfileModel model = DriverProfileModel.fromJson(
        <String, dynamic>{
          'rating': <String, dynamic>{'average': null, 'count': 0},
        },
      );

      expect(model.rating, isNull);
    });

    test('keeps the plate number when on file', () {
      final DriverProfileModel model = DriverProfileModel.fromJson(
        <String, dynamic>{
          'vehicle': <String, dynamic>{
            'id': 2,
            'name': 'Car',
            'plate_number': 'ABC 1234',
          },
        },
      );

      expect(model.vehicle?.plateNumber, 'ABC 1234');
    });
  });

  test('missing fields fall back to empty values instead of throwing', () {
    final DriverProfileModel model = DriverProfileModel.fromJson(
      <String, dynamic>{'identity_type': 'unknown'},
    );

    expect(model.firstName, isEmpty);
    expect(model.phone, isEmpty);
    expect(model.identityType, isNull);
  });

  test('identity type maps every API value', () {
    expect(IdentityType.fromApi('passport'), IdentityType.passport);
    expect(
      IdentityType.fromApi('driving_license'),
      IdentityType.drivingLicense,
    );
  });
}
