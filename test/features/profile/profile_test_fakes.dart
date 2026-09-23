import 'package:dartz/dartz.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/auth/domain/entities/identity_type.dart';
import 'package:ssm_driver/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ssm_driver/features/profile/data/models/driver_profile_model.dart';
import 'package:ssm_driver/features/profile/domain/entities/driver_profile.dart';
import 'package:ssm_driver/features/profile/domain/repositories/profile_repository.dart';

const DriverProfileModel sampleProfile = DriverProfileModel(
  id: 1,
  firstName: 'DriverA',
  lastName: 'Fixture',
  phone: '+966500000101',
  email: 'driver.A@ssm.test',
  identityType: IdentityType.nid,
  identityNumber: '1000000A',
);

/// Throws [error] when set, otherwise returns [sampleProfile].
class FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  Object? error;

  @override
  Future<DriverProfileModel> getProfile() async {
    if (error != null) throw error!;
    return sampleProfile;
  }
}

class FakeProfileRepository implements ProfileRepository {
  Either<Failure, DriverProfile> result = const Right<Failure, DriverProfile>(
    sampleProfile,
  );

  @override
  Future<Either<Failure, DriverProfile>> getProfile() async => result;
}
