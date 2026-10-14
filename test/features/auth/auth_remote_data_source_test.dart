import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ssm_driver/features/auth/domain/entities/registration_data.dart';

import '../parcels/parcels_test_fakes.dart' show FakeDioConsumer;

void main() {
  test('registration sends no identity type or number', () async {
    final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{});

    await AuthRemoteDataSource(consumer).register(
      const RegistrationData(
        firstName: 'Ahmed',
        lastName: 'Ali',
        phone: '0500000000',
        email: 'driver@example.com',
        password: 'Strong#Pass2026',
        zoneId: 1,
        vehicleId: 2,
      ),
    );

    expect(consumer.lastPath, '/auth/delivery-man/store');
    expect(consumer.lastBody, <String, dynamic>{
      'f_name': 'Ahmed',
      'l_name': 'Ali',
      'email': 'driver@example.com',
      'phone': '+966500000000',
      'password': 'Strong#Pass2026',
      'zone_id': 1,
      'vehicle_id': 2,
      'earning': 1,
    });
  });
}
