import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/driver_profile.dart';
import '../entities/profile_update.dart';

abstract class ProfileRepository {
  Future<Either<Failure, DriverProfile>> getProfile();

  Future<Either<Failure, Unit>> updateProfile(ProfileUpdate update);
}
