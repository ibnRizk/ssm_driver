import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/approval_status.dart';
import '../entities/onboarding_status.dart';
import '../entities/registration_data.dart';
import '../entities/zone.dart';

abstract class AuthRepository {
  /// Stores the returned Bearer token on success.
  Future<Either<Failure, ApprovalStatus>> login({
    required String phone,
    required String password,
  });

  Future<Either<Failure, Unit>> register(RegistrationData data);

  /// The zones a Driver can register in, in the backend's order.
  Future<Either<Failure, List<Zone>>> getZones();

  /// [UnauthorizedFailure] means the stored token is dead (replaced/revoked).
  Future<Either<Failure, Unit>> validateSession();

  Future<Either<Failure, OnboardingStatus>> getOnboardingStatus();

  Future<bool> hasStoredSession();

  /// Client-side only — the API has no Driver logout endpoint.
  Future<void> logout();
}
