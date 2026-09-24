import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/api/api_endpoints.dart';
import 'package:ssm_driver/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ssm_driver/features/profile/domain/entities/profile_update.dart';

import 'profile_test_fakes.dart';

void main() {
  late FakeProfileDioConsumer consumer;
  late ProfileRemoteDataSource dataSource;

  setUp(() {
    consumer = FakeProfileDioConsumer();
    dataSource = ProfileRemoteDataSource(consumer);
  });

  test('updateProfile PATCHes the profile endpoint', () async {
    await dataSource.updateProfile(sampleUpdate);

    expect(consumer.lastPath, ApiEndpoints.profile);
  });

  test('updateProfile sends the profile fields without a password', () async {
    await dataSource.updateProfile(sampleUpdate);

    expect(consumer.lastBody, <String, dynamic>{
      'f_name': 'Mobile',
      'l_name': 'Driver',
      'email': 'driver.A@ssm.test',
      'phone': '+966500000101',
    });
  });

  test('updateProfile sends a new password with its confirmation', () async {
    await dataSource.updateProfile(
      const ProfileUpdate(
        firstName: 'Mobile',
        lastName: 'Driver',
        email: 'driver.A@ssm.test',
        phone: '+966500000101',
        password: 'NewStrong#123',
      ),
    );

    expect(consumer.lastBody?['password'], 'NewStrong#123');
    expect(consumer.lastBody?['password_confirmation'], 'NewStrong#123');
  });
}
