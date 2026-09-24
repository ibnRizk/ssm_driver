import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/profile_update.dart';
import '../models/driver_profile_model.dart';

/// Raw Driver profile API calls. Throws [AppException]s (mapped by
/// [DioConsumer]); the repository turns them into failures.
class ProfileRemoteDataSource {
  final DioConsumer _consumer;

  const ProfileRemoteDataSource(this._consumer);

  Future<DriverProfileModel> getProfile() async {
    final dynamic data = await _consumer.get(ApiEndpoints.profile);
    if (data is! Map<String, dynamic>) throw const ServerException();
    return DriverProfileModel.fromJson(data);
  }

  /// Validation errors (duplicate phone/email, weak password) come back as a
  /// 422 and surface as a [ServerException] carrying the server's message.
  Future<void> updateProfile(ProfileUpdate update) async {
    final String? password = update.password;
    await _consumer.patch(
      ApiEndpoints.profile,
      body: <String, dynamic>{
        'f_name': update.firstName,
        'l_name': update.lastName,
        'email': update.email,
        'phone': update.phone,
        // The form already checked the two entries match; the API still
        // requires the confirmation field alongside a new password.
        if (password != null) ...<String, dynamic>{
          'password': password,
          'password_confirmation': password,
        },
      },
    );
  }
}
