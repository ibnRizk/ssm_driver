import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/local_storage/app_secure_storage.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/approval_status.dart';
import '../../domain/entities/onboarding_status.dart';
import '../../domain/entities/registration_data.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AppSecureStorage _storage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AppSecureStorage storage,
  }) : _remote = remote,
       _storage = storage;

  @override
  Future<Either<Failure, ApprovalStatus>> login({
    required String phone,
    required String password,
  }) => _guard(() async {
    final response = await _remote.login(phone: phone, password: password);
    await _storage.saveAccessToken(response.token);
    return response.approvalStatus;
  });

  @override
  Future<Either<Failure, Unit>> register(RegistrationData data) =>
      _guard(() async {
        await _remote.register(data);
        return unit;
      });

  @override
  Future<Either<Failure, List<Zone>>> getZones() =>
      _guard<List<Zone>>(_remote.getZones);

  @override
  Future<Either<Failure, Unit>> validateSession() => _guard(() async {
    await _remote.validateSession();
    return unit;
  });

  @override
  Future<Either<Failure, OnboardingStatus>> getOnboardingStatus() =>
      _guard(_remote.getOnboardingStatus);

  @override
  Future<bool> hasStoredSession() async {
    final String? token = await _storage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() => _storage.removeAccessToken();

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
