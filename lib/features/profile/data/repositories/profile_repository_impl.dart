import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;

  const ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, DriverProfile>> getProfile() async {
    try {
      return Right<Failure, DriverProfile>(await _remote.getProfile());
    } on AppException catch (e) {
      return Left<Failure, DriverProfile>(e.toFailure());
    } catch (_) {
      return Left<Failure, DriverProfile>(
        ServerFailure(message: Strings.somethingWentWrong),
      );
    }
  }
}
