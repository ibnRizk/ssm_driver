import '../../../config/locale/app_localizations.dart';

/// Translation-key wrappers. Every getter must have a matching key in
/// `lang/en.json` **and** `lang/ar.json`, or it renders `"<key> not found"`.
///
/// Keep this file and the JSON files in lockstep — that is the whole contract.
abstract class Strings {
  // --- App ---
  static const String _appName = 'app_name';
  static String get appName => _appName.tr;

  // --- Common actions ---
  static const String _ok = 'ok';
  static String get ok => _ok.tr;

  static const String _cancel = 'cancel';
  static String get cancel => _cancel.tr;

  static const String _confirm = 'confirm';
  static String get confirm => _confirm.tr;

  static const String _retry = 'retry';
  static String get retry => _retry.tr;

  static const String _save = 'save';
  static String get save => _save.tr;

  static const String _delete = 'delete';
  static String get delete => _delete.tr;

  static const String _search = 'search';
  static String get search => _search.tr;

  static const String _loading = 'loading';
  static String get loading => _loading.tr;

  // --- Errors / empty states ---
  static const String _noInternetConnection = 'no_internet_connection';
  static String get noInternetConnection => _noInternetConnection.tr;

  static const String _somethingWentWrong = 'something_went_wrong';
  static String get somethingWentWrong => _somethingWentWrong.tr;

  static const String _requestCancelled = 'request_cancelled';
  static String get requestCancelled => _requestCancelled.tr;

  static const String _noDataFound = 'no_data_found';
  static String get noDataFound => _noDataFound.tr;

  static const String _noResults = 'no_results';
  static String get noResults => _noResults.tr;

  // --- Settings ---
  static const String _language = 'language';
  static String get language => _language.tr;

  static const String _english = 'english';
  static String get english => _english.tr;

  static const String _arabic = 'arabic';
  static String get arabic => _arabic.tr;

  static const String _settings = 'settings';
  static String get settings => _settings.tr;

  static const String _theme = 'theme';
  static String get theme => _theme.tr;

  // --- Bottom navigation ---
  static const String _navHome = 'nav_home';
  static String get navHome => _navHome.tr;

  static const String _navOrders = 'nav_orders';
  static String get navOrders => _navOrders.tr;

  static const String _navParcels = 'nav_parcels';
  static String get navParcels => _navParcels.tr;

  static const String _navSubscriptions = 'nav_subscriptions';
  static String get navSubscriptions => _navSubscriptions.tr;

  static const String _navProfile = 'nav_profile';
  static String get navProfile => _navProfile.tr;

  // --- Auth ---
  static const String _authDriverGreeting = 'auth_driver_greeting';
  static String get authDriverGreeting => _authDriverGreeting.tr;

  static const String _authWelcomeTitle = 'auth_welcome_title';
  static String get authWelcomeTitle => _authWelcomeTitle.tr;

  static const String _authWelcomeSubtitle = 'auth_welcome_subtitle';
  static String get authWelcomeSubtitle => _authWelcomeSubtitle.tr;

  static const String _authPhoneLabel = 'auth_phone_label';
  static String get authPhoneLabel => _authPhoneLabel.tr;

  static const String _authPhoneHint = 'auth_phone_hint';
  static String get authPhoneHint => _authPhoneHint.tr;

  static const String _authContinue = 'auth_continue';
  static String get authContinue => _authContinue.tr;

  static const String _authFooterSecure = 'auth_footer_secure';
  static String get authFooterSecure => _authFooterSecure.tr;

  static const String _authFooterTagline = 'auth_footer_tagline';
  static String get authFooterTagline => _authFooterTagline.tr;

  static const String _authNoAccount = 'auth_no_account';
  static String get authNoAccount => _authNoAccount.tr;

  static const String _authCreateAccountLink = 'auth_create_account_link';
  static String get authCreateAccountLink => _authCreateAccountLink.tr;

  static const String _authTermsNotice = 'auth_terms_notice';
  static String get authTermsNotice => _authTermsNotice.tr;

  static const String _authRegisterTitle = 'auth_register_title';
  static String get authRegisterTitle => _authRegisterTitle.tr;

  static const String _authRegisterSubtitle = 'auth_register_subtitle';
  static String get authRegisterSubtitle => _authRegisterSubtitle.tr;

  static const String _authFullNameLabel = 'auth_full_name_label';
  static String get authFullNameLabel => _authFullNameLabel.tr;

  static const String _authFullNameHint = 'auth_full_name_hint';
  static String get authFullNameHint => _authFullNameHint.tr;

  static const String _authRegionLabel = 'auth_region_label';
  static String get authRegionLabel => _authRegionLabel.tr;

  static const String _authRegionHint = 'auth_region_hint';
  static String get authRegionHint => _authRegionHint.tr;

  static const String _authRegisterButton = 'auth_register_button';
  static String get authRegisterButton => _authRegisterButton.tr;

  static const String _authHaveAccount = 'auth_have_account';
  static String get authHaveAccount => _authHaveAccount.tr;

  static const String _authLoginLink = 'auth_login_link';
  static String get authLoginLink => _authLoginLink.tr;

  // --- Home / driver dashboard ---
  static const String _homeGreeting = 'home_greeting';

  /// `{name}` in the translation is replaced with the driver's first name.
  static String homeGreeting(String name) =>
      _homeGreeting.tr.replaceFirst('{name}', name);

  static const String _homeDateLocation = 'home_date_location';
  static String get homeDateLocation => _homeDateLocation.tr;

  static const String _homeStatusOnline = 'home_status_online';
  static String get homeStatusOnline => _homeStatusOnline.tr;

  static const String _homeStatOrdersLabel = 'home_stat_orders_label';
  static String get homeStatOrdersLabel => _homeStatOrdersLabel.tr;

  static const String _homeStatIncentivesLabel = 'home_stat_incentives_label';
  static String get homeStatIncentivesLabel => _homeStatIncentivesLabel.tr;

  static const String _homeStatParcelsLabel = 'home_stat_parcels_label';
  static String get homeStatParcelsLabel => _homeStatParcelsLabel.tr;

  static const String _homeStatRatingLabel = 'home_stat_rating_label';
  static String get homeStatRatingLabel => _homeStatRatingLabel.tr;

  static const String _homeStartButton = 'home_start_button';
  static String get homeStartButton => _homeStartButton.tr;

  static const String _homeRecentActivityTitle = 'home_recent_activity_title';
  static String get homeRecentActivityTitle => _homeRecentActivityTitle.tr;

  static const String _homeViewAll = 'home_view_all';
  static String get homeViewAll => _homeViewAll.tr;

  static const String _homeActivityTitle = 'home_activity_title';
  static String get homeActivityTitle => _homeActivityTitle.tr;

  static const String _homeActivitySubtitle = 'home_activity_subtitle';

  /// `{count}` and `{store}` in the translation are replaced with the live
  /// parcel count and store name.
  static String homeActivitySubtitle(int count, String store) =>
      _homeActivitySubtitle.tr
          .replaceFirst('{count}', '$count')
          .replaceFirst('{store}', store);

  static const String _homeCashTotalLabel = 'home_cash_total_label';
  static String get homeCashTotalLabel => _homeCashTotalLabel.tr;

  // --- Incoming order ---
  static const String _orderNewTitle = 'order_new_title';
  static String get orderNewTitle => _orderNewTitle.tr;

  static const String _orderAssignmentTitle = 'order_assignment_title';
  static String get orderAssignmentTitle => _orderAssignmentTitle.tr;

  static const String _orderAssignmentSubtitle = 'order_assignment_subtitle';
  static String get orderAssignmentSubtitle => _orderAssignmentSubtitle.tr;

  static const String _orderEtaLabel = 'order_eta_label';

  /// `{minutes}` in the translation is replaced with the expected pickup
  /// time, in minutes.
  static String orderEtaLabel(int minutes) =>
      _orderEtaLabel.tr.replaceFirst('{minutes}', '$minutes');

  static const String _orderDestinationLabel = 'order_destination_label';
  static String get orderDestinationLabel => _orderDestinationLabel.tr;

  static const String _orderContentsLabel = 'order_contents_label';
  static String get orderContentsLabel => _orderContentsLabel.tr;

  static const String _orderContentsValue = 'order_contents_value';

  /// `{count}` in the translation is replaced with the item count.
  static String orderContentsValue(int count) =>
      _orderContentsValue.tr.replaceFirst('{count}', '$count');

  static const String _orderCodLabel = 'order_cod_label';
  static String get orderCodLabel => _orderCodLabel.tr;

  static const String _orderAcceptButton = 'order_accept_button';
  static String get orderAcceptButton => _orderAcceptButton.tr;

  static const String _orderRejectButton = 'order_reject_button';
  static String get orderRejectButton => _orderRejectButton.tr;

  static const String _orderRejectFooterNote = 'order_reject_footer_note';
  static String get orderRejectFooterNote => _orderRejectFooterNote.tr;

  // --- Order trip details ---
  static const String _orderDetailsTitle = 'order_details_title';
  static String get orderDetailsTitle => _orderDetailsTitle.tr;

  static const String _orderStepLabel = 'order_step_label';

  /// `{step}` in the translation is replaced with the step number.
  static String orderStepLabel(int step) =>
      _orderStepLabel.tr.replaceFirst('{step}', '$step');

  static const String _orderPickupTitle = 'order_pickup_title';
  static String get orderPickupTitle => _orderPickupTitle.tr;

  static const String _orderDeliveryTitle = 'order_delivery_title';
  static String get orderDeliveryTitle => _orderDeliveryTitle.tr;

  static const String _orderMapButton = 'order_map_button';
  static String get orderMapButton => _orderMapButton.tr;

  static const String _orderCallButton = 'order_call_button';
  static String get orderCallButton => _orderCallButton.tr;

  static const String _orderCodCashNote = 'order_cod_cash_note';
  static String get orderCodCashNote => _orderCodCashNote.tr;

  static const String _orderNavigateToStoreButton =
      'order_navigate_to_store_button';
  static String get orderNavigateToStoreButton =>
      _orderNavigateToStoreButton.tr;

  // --- Navigate to store ---
  static const String _orderNavigateTitle = 'order_navigate_title';
  static String get orderNavigateTitle => _orderNavigateTitle.tr;

  static const String _orderPickupPointLabel = 'order_pickup_point_label';
  static String get orderPickupPointLabel => _orderPickupPointLabel.tr;

  static const String _orderDistanceLabel = 'order_distance_label';
  static String get orderDistanceLabel => _orderDistanceLabel.tr;

  static const String _orderEtaTimeLabel = 'order_eta_time_label';
  static String get orderEtaTimeLabel => _orderEtaTimeLabel.tr;

  static const String _orderOpenGoogleMapsButton =
      'order_open_google_maps_button';
  static String get orderOpenGoogleMapsButton =>
      _orderOpenGoogleMapsButton.tr;

  static const String _orderNavigateWarningNote =
      'order_navigate_warning_note';
  static String get orderNavigateWarningNote => _orderNavigateWarningNote.tr;

  // --- Pickup confirmation ---
  static const String _orderPickupConfirmTitle = 'order_pickup_confirm_title';
  static String get orderPickupConfirmTitle => _orderPickupConfirmTitle.tr;

  static const String _orderStepOfLabel = 'order_step_of_label';

  /// `{step}` and `{total}` in the translation are replaced with the
  /// current step and the total step count.
  static String orderStepOfLabel(int step, int total) => _orderStepOfLabel.tr
      .replaceFirst('{step}', '$step')
      .replaceFirst('{total}', '$total');

  static const String _orderPackageReadyTitle = 'order_package_ready_title';
  static String get orderPackageReadyTitle => _orderPackageReadyTitle.tr;

  static const String _orderVerificationTitle = 'order_verification_title';
  static String get orderVerificationTitle => _orderVerificationTitle.tr;

  static const String _orderVerifyBagCount = 'order_verify_bag_count';
  static String get orderVerifyBagCount => _orderVerifyBagCount.tr;

  static const String _orderVerifySealedCondition =
      'order_verify_sealed_condition';
  static String get orderVerifySealedCondition =>
      _orderVerifySealedCondition.tr;

  static const String _orderVerifyNumberMatches =
      'order_verify_number_matches';
  static String get orderVerifyNumberMatches => _orderVerifyNumberMatches.tr;

  static const String _orderConfirmInfoBanner = 'order_confirm_info_banner';
  static String get orderConfirmInfoBanner => _orderConfirmInfoBanner.tr;

  static const String _orderPickupConfirmButton =
      'order_pickup_confirm_button';
  static String get orderPickupConfirmButton => _orderPickupConfirmButton.tr;

  static const String _orderReportProblemButton =
      'order_report_problem_button';
  static String get orderReportProblemButton => _orderReportProblemButton.tr;

  // --- Validation ---
  static const String _fieldRequired = 'field_required';
  static String get fieldRequired => _fieldRequired.tr;

  static const String _invalidEmail = 'invalid_email';
  static String get invalidEmail => _invalidEmail.tr;

  static const String _invalidPhone = 'invalid_phone';
  static String get invalidPhone => _invalidPhone.tr;

  static const String _invalidName = 'invalid_name';
  static String get invalidName => _invalidName.tr;

  static const String _invalidNumbers = 'invalid_numbers';
  static String get invalidNumbers => _invalidNumbers.tr;

  static const String _passwordTooShort = 'password_too_short';
  static String get passwordTooShort => _passwordTooShort.tr;

  static const String _passwordsDoNotMatch = 'passwords_do_not_match';
  static String get passwordsDoNotMatch => _passwordsDoNotMatch.tr;
}
