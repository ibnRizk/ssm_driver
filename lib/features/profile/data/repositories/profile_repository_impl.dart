import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/entities/profile_update.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;

  const ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, DriverProfile>> getProfile() =>
      _guard(_remote.getProfile);

  @override
  Future<Either<Failure, Unit>> updateProfile(ProfileUpdate update) =>
      _guard(() async {
        await _remote.updateProfile(update);
        return unit;
      });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right<Failure, T>(await call());
    } on AppException catch (e) {
      return Left<Failure, T>(e.toFailure());
    } catch (_) {
      return Left<Failure, T>(
        ServerFailure(message: Strings.somethingWentWrong),
      );
    }
  }
}
