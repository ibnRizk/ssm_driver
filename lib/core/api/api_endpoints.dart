/// Central endpoint registry — paths only.
///
/// The host comes from `AppEnv.baseUrl` (see `.env`) and is applied once as
/// `Dio.options.baseUrl`, so never put a full URL here. `BASE_URL` already
/// ends with `/api/v1`.
abstract class ApiEndpoints {
  // --- Auth (public) ---
  static const String login = '/auth/delivery-man/login';
  static const String register = '/auth/delivery-man/store';
  static const String zoneList = '/zone/list';
  static const String vehicleList = '/vehicle/list';

  // --- Session / onboarding (Bearer) ---
  static const String validateSession = '/delivery-man/session/validate';
  static const String onboardingStatus = '/delivery-man/onboarding-status';

  // --- Profile (Bearer) ---
  static const String profile = '/delivery-man/profile';
  static const String supportInfo = '/delivery-man/support-info';

  // --- Push (Bearer) ---
  static const String updateFcmToken = '/delivery-man/update-fcm-token';

  // --- Availability & dashboard (Bearer + approved) ---
  static const String goOnline = '/delivery-man/online';
  static const String goOffline = '/delivery-man/offline';
  static const String heartbeat = '/delivery-man/heartbeat';
  static const String location = '/delivery-man/location';
  static const String codSummary = '/delivery-man/cod-summary';
  static const String incentiveSummary = '/delivery-man/incentive-summary';

  // --- Offers (Bearer + approved) ---
  static const String activeOffer = '/delivery-man/active-offer';
  static String acceptOffer(int assignmentId) =>
      '/delivery-man/offers/$assignmentId/accept';
  static String rejectOffer(int assignmentId) =>
      '/delivery-man/offers/$assignmentId/reject';

  // --- Orders (Bearer + approved; lifecycle commands need Idempotency-Key) ---
  static const String currentWork = '/delivery-man/current-work';
  static String pickupOrder(int orderId) =>
      '/delivery-man/orders/$orderId/pickup';
  static String outForDelivery(int orderId) =>
      '/delivery-man/orders/$orderId/out-for-delivery';
  static String completeOrder(int orderId) =>
      '/delivery-man/orders/$orderId/complete';

  // --- Problem reports (Bearer + approved; POST needs Idempotency-Key) ---
  static const String problemReasons = '/delivery-man/problem-reasons';
  static String reportProblem(int orderId) =>
      '/delivery-man/orders/$orderId/report-problem';

  // --- Giving an order up (Bearer + approved; need Idempotency-Key) ---
  /// Before pickup: hands the order back to dispatch for another Driver.
  static String releaseOrder(int orderId) =>
      '/delivery-man/orders/$orderId/release';

  /// After pickup: the delivery can't be made (customer unreachable,
  /// refused, wrong address…); the order goes to support for a decision.
  static String failDelivery(int orderId) =>
      '/delivery-man/orders/$orderId/fail-delivery';

  // --- Parcels (Bearer + approved) ---
  static const String parcels = '/delivery-man/parcels';
  static String parcelDetails(int parcelId) =>
      '/delivery-man/parcels/$parcelId';
  static String startParcelDelivery(int parcelId) =>
      '/delivery-man/parcels/$parcelId/start-delivery';
  static String completeParcel(int parcelId) =>
      '/delivery-man/parcels/$parcelId/complete';

  // --- C2C parcels (Bearer + approved; POSTs need Idempotency-Key) ---
  /// Customer-to-customer parcels — a separate API from the warehouse
  /// parcels above (C2C contract §2).
  static const String c2cOffers = '/delivery-man/c2c-parcels/offers';

  /// `accept`, `arrive-pickup`, `pickup`, `out-for-delivery`, `complete`.
  static String c2cAction(int parcelId, String action) =>
      '/delivery-man/c2c-parcels/$parcelId/$action';
  static String c2cLocation(int parcelId) =>
      '/delivery-man/c2c-parcels/$parcelId/location';

  // --- Work history (Bearer + approved) ---
  /// Store orders and C2C parcels in separate arrays; `scope` is
  /// `current` or `previous`.
  static const String workHistory = '/delivery-man/work-history';
}
