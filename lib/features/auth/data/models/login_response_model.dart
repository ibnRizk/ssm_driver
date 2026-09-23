import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/approval_status.dart';

class LoginResponseModel {
  /// Opaque server token — never parse it or assume claims.
  final String token;
  final ApprovalStatus approvalStatus;

  const LoginResponseModel({required this.token, required this.approvalStatus});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic token = json['token'];
    if (token is! String || token.isEmpty) {
      throw ServerException(message: Strings.somethingWentWrong);
    }
    return LoginResponseModel(
      token: token,
      approvalStatus: ApprovalStatus.fromApi(json['approval_status'] as String?),
    );
  }
}
