import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ssm_driver/core/api/dio_consumer.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/auth/domain/entities/identity_type.dart';
import 'package:ssm_driver/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ssm_driver/features/profile/data/models/driver_profile_model.dart';
import 'package:ssm_driver/features/profile/domain/entities/driver_profile.dart';
import 'package:ssm_driver/features/profile/domain/entities/profile_update.dart';
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

const ProfileUpdate sampleUpdate = ProfileUpdate(
  firstName: 'Mobile',
  lastName: 'Driver',
  email: 'driver.A@ssm.test',
  phone: '+966500000101',
);

/// Throws [error] when set, otherwise returns [sampleProfile].
class FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  Object? error;
  ProfileUpdate? lastUpdate;

  @override
  Future<DriverProfileModel> getProfile() async {
    if (error != null) throw error!;
    return sampleProfile;
  }

  @override
  Future<void> updateProfile(ProfileUpdate update) async {
    lastUpdate = update;
    if (error != null) throw error!;
  }
}

class FakeProfileRepository implements ProfileRepository {
  Either<Failure, DriverProfile> result = const Right<Failure, DriverProfile>(
    sampleProfile,
  );
  Either<Failure, Unit> updateResult = const Right<Failure, Unit>(unit);
  int updateCalls = 0;

  @override
  Future<Either<Failure, DriverProfile>> getProfile() async => result;

  @override
  Future<Either<Failure, Unit>> updateProfile(ProfileUpdate update) async {
    updateCalls++;
    return updateResult;
  }
}

/// Records the last PATCH; every other verb is unused by the profile feature.
class FakeProfileDioConsumer implements DioConsumer {
  String? lastPath;
  Map<String, dynamic>? lastBody;

  @override
  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
    lastBody = body;
    return sampleProfileJson;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

const Map<String, dynamic> sampleProfileJson = <String, dynamic>{
  'id': 1,
  'f_name': 'Mobile',
  'l_name': 'Driver',
};
