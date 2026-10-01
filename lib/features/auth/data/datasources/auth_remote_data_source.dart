import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/string_extension.dart';
import '../../domain/entities/registration_data.dart';
import '../models/login_response_model.dart';
import '../models/onboarding_status_model.dart';
import '../models/vehicle_type_model.dart';
import '../models/zone_model.dart';

/// Raw Driver auth API calls. Throws [AppException]s (mapped by
/// [DioConsumer]); the repository turns them into failures.
class AuthRemoteDataSource {
  final DioConsumer _consumer;

  const AuthRemoteDataSource(this._consumer);

  Future<LoginResponseModel> login({
    required String phone,
    required String password,
  }) async {
    final dynamic data = await _consumer.post(
      ApiEndpoints.login,
      body: <String, dynamic>{
        'phone': phone.toInternationalPhone(),
        'password': password,
      },
    );
    return LoginResponseModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> register(RegistrationData data) async {
    await _consumer.post(
      ApiEndpoints.register,
      body: <String, dynamic>{
        'f_name': data.firstName,
        'l_name': data.lastName,
        'identity_type': data.identityType.apiValue,
        'identity_number': data.identityNumber,
        'email': data.email,
        'phone': data.phone.toInternationalPhone(),
        'password': data.password,
        'zone_id': data.zoneId,
        'vehicle_id': data.vehicleId,
        // Required by the registration contract; always 1.
        'earning': 1,
      },
    );
  }

  /// Public — no token needed, so it works before the Driver has one.
  Future<List<ZoneModel>> getZones() async =>
      ZoneModel.listFromJson(await _consumer.get(ApiEndpoints.zoneList));

  /// Public — no token needed, so it works before the Driver has one.
  Future<List<VehicleTypeModel>> getVehicleTypes() async =>
      VehicleTypeModel.listFromJson(
        await _consumer.get(ApiEndpoints.vehicleList),
      );

  Future<void> validateSession() async {
    final dynamic data = await _consumer.get(ApiEndpoints.validateSession);
    if (data is! Map || data['authenticated'] != true) {
      throw const UnauthorizedException();
    }
  }

  Future<OnboardingStatusModel> getOnboardingStatus() async {
    final dynamic data = await _consumer.get(ApiEndpoints.onboardingStatus);
    return OnboardingStatusModel.fromJson(data as Map<String, dynamic>);
  }
}
