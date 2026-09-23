/// Central endpoint registry — paths only.
///
/// The host comes from `AppEnv.baseUrl` (see `.env`) and is applied once as
/// `Dio.options.baseUrl`, so never put a full URL here. `BASE_URL` already
/// ends with `/api/v1`.
abstract class ApiEndpoints {
  // --- Auth (public) ---
  static const String login = '/auth/delivery-man/login';
  static const String register = '/auth/delivery-man/store';

  // --- Session / onboarding (Bearer) ---
  static const String validateSession = '/delivery-man/session/validate';
  static const String onboardingStatus = '/delivery-man/onboarding-status';
}
