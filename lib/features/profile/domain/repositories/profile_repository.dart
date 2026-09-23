import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/driver_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, DriverProfile>> getProfile();
}
