import 'package:dartz/dartz.dart';

import '../../error/exceptions.dart';
import '../../error/failures.dart';
import '../../utils/values/strings.dart';
import 'push_token_remote_data_source.dart';

/// Ties this device's FCM token to the signed-in Driver. There is no Driver
/// endpoint to remove it; signing out deletes the token on the device.
abstract class PushTokenRepository {
  Future<Either<Failure, Unit>> updateFcmToken(String token);
}

class PushTokenRepositoryImpl implements PushTokenRepository {
  final PushTokenRemoteDataSource _remote;

  const PushTokenRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, Unit>> updateFcmToken(String token) async {
    // The API answers an empty token with 422; don't send one.
    if (token.isEmpty) {
      return Left<Failure, Unit>(
        ServerFailure(message: Strings.somethingWentWrong),
      );
    }
    try {
      await _remote.updateFcmToken(token);
      return const Right<Failure, Unit>(unit);
    } on AppException catch (e) {
      return Left<Failure, Unit>(e.toFailure());
    } catch (_) {
      return Left<Failure, Unit>(
        ServerFailure(message: Strings.somethingWentWrong),
      );
    }
  }
}
