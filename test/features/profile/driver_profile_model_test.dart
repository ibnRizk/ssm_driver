import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/features/auth/domain/entities/identity_type.dart';
import 'package:ssm_driver/features/profile/data/models/driver_profile_model.dart';

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
