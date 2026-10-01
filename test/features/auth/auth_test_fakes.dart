import 'package:dartz/dartz.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/local_storage/app_secure_storage.dart';
import 'package:ssm_driver/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ssm_driver/features/auth/data/models/login_response_model.dart';
import 'package:ssm_driver/features/auth/data/models/onboarding_status_model.dart';
import 'package:ssm_driver/features/auth/data/models/zone_model.dart';
import 'package:ssm_driver/features/auth/domain/entities/approval_status.dart';
import 'package:ssm_driver/features/auth/domain/entities/onboarding_status.dart';
import 'package:ssm_driver/features/auth/domain/entities/registration_data.dart';
import 'package:ssm_driver/features/auth/domain/entities/zone.dart';
import 'package:ssm_driver/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FakeSecureStorage extends AppSecureStorage {
  String? token;

  FakeSecureStorage({this.token})
    : super(instance: const FlutterSecureStorage());

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<void> saveAccessToken(String? value) async => token = value;

  @override
  Future<void> removeAccessToken() async => token = null;

  @override
  Future<String?> getDeviceToken() async => null;

  @override
  Future<void> saveDeviceToken(String value) async {}

  @override
  Future<void> removeDeviceToken() async {}

  @override
  Future<void> clearAll() async => token = null;
}

/// Each call throws [error] when set, otherwise returns the canned response.
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  Object? error;
  LoginResponseModel loginResponse = const LoginResponseModel(
    token: 'opaque-token',
    approvalStatus: ApprovalStatus.pending,
  );
  List<ZoneModel> zones = const <ZoneModel>[ZoneModel(id: 1, name: 'Riyadh')];

  @override
  Future<LoginResponseModel> login({
    required String phone,
    required String password,
  }) async {
    if (error != null) throw error!;
    return loginResponse;
  }

  @override
  Future<void> register(RegistrationData data) async {
    if (error != null) throw error!;
  }

  @override
  Future<List<ZoneModel>> getZones() async {
    if (error != null) throw error!;
    return zones;
  }

  @override
  Future<void> validateSession() async {
    if (error != null) throw error!;
  }

  @override
  Future<OnboardingStatusModel> getOnboardingStatus() async {
    if (error != null) throw error!;
    return const OnboardingStatusModel(
      name: 'Driver',
      approvalStatus: ApprovalStatus.pending,
      canOperate: false,
    );
  }
}

class FakeAuthRepository implements AuthRepository {
  bool hasSession = true;
  Either<Failure, Unit> validateResult = const Right<Failure, Unit>(unit);
  Either<Failure, OnboardingStatus> statusResult =
      const Right<Failure, OnboardingStatus>(pendingStatus);
  bool loggedOut = false;
  Either<Failure, List<Zone>> zonesResult = const Right<Failure, List<Zone>>(
    <Zone>[Zone(id: 1, name: 'Riyadh')],
  );
  int zonesCalls = 0;

  @override
  Future<Either<Failure, List<Zone>>> getZones() async {
    zonesCalls++;
    return zonesResult;
  }

  static const OnboardingStatus pendingStatus = OnboardingStatus(
    name: 'Driver',
    approvalStatus: ApprovalStatus.pending,
    canOperate: false,
  );

  @override
  Future<bool> hasStoredSession() async => hasSession;

  @override
  Future<Either<Failure, Unit>> validateSession() async => validateResult;

  @override
  Future<Either<Failure, OnboardingStatus>> getOnboardingStatus() async =>
      statusResult;

  @override
  Future<void> logout() async => loggedOut = true;

  @override
  Future<Either<Failure, ApprovalStatus>> login({
    required String phone,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> register(RegistrationData data) =>
      throw UnimplementedError();
}
