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

  static const String _navEarnings = 'nav_earnings';
  static String get navEarnings => _navEarnings.tr;

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

  // --- Delivery to customer ---
  static const String _orderDeliveryToCustomerTitle =
      'order_delivery_to_customer_title';
  static String get orderDeliveryToCustomerTitle =>
      _orderDeliveryToCustomerTitle.tr;

  static const String _orderDeliveryStatusTop = 'order_delivery_status_top';
  static String get orderDeliveryStatusTop => _orderDeliveryStatusTop.tr;

  static const String _orderDeliveryStatusMain = 'order_delivery_status_main';
  static String get orderDeliveryStatusMain => _orderDeliveryStatusMain.tr;

  static const String _orderDeliveryStatusSubtitle =
      'order_delivery_status_subtitle';
  static String get orderDeliveryStatusSubtitle =>
      _orderDeliveryStatusSubtitle.tr;

  static const String _orderCustomerDetailsTitle =
      'order_customer_details_title';
  static String get orderCustomerDetailsTitle =>
      _orderCustomerDetailsTitle.tr;

  static const String _orderRouteToCustomerLabel =
      'order_route_to_customer_label';
  static String get orderRouteToCustomerLabel =>
      _orderRouteToCustomerLabel.tr;

  static const String _orderCallCustomerButton = 'order_call_customer_button';
  static String get orderCallCustomerButton => _orderCallCustomerButton.tr;

  static const String _orderCodCashLabel = 'order_cod_cash_label';
  static String get orderCodCashLabel => _orderCodCashLabel.tr;

  static const String _orderDeliveryFooterNote = 'order_delivery_footer_note';
  static String get orderDeliveryFooterNote => _orderDeliveryFooterNote.tr;

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

  static const String _profileMockName = 'profileMockName';
  static String get profileMockName => _profileMockName.tr;

  static const String _profileMockPhone = 'profileMockPhone';
  static String get profileMockPhone => _profileMockPhone.tr;

  static const String _profileMockLocation = 'profileMockLocation';
  static String get profileMockLocation => _profileMockLocation.tr;

  static const String _profileMockVehicle = 'profileMockVehicle';
  static String get profileMockVehicle => _profileMockVehicle.tr;

  static const String _profileMockVehicleSubtitle = 'profileMockVehicleSubtitle';
  static String get profileMockVehicleSubtitle => _profileMockVehicleSubtitle.tr;

  static const String _profileVehicleSection = 'profileVehicleSection';
  static String get profileVehicleSection => _profileVehicleSection.tr;

  static const String _profileVehicleSubtitle = 'profileVehicleSubtitle';
  static String get profileVehicleSubtitle => _profileVehicleSubtitle.tr;

  static const String _profilePersonalData = 'profilePersonalData';
  static String get profilePersonalData => _profilePersonalData.tr;

  static const String _profilePersonalDataSubtitle = 'profilePersonalDataSubtitle';
  static String get profilePersonalDataSubtitle => _profilePersonalDataSubtitle.tr;

  static const String _profileWorkingHours = 'profileWorkingHours';
  static String get profileWorkingHours => _profileWorkingHours.tr;

  static const String _profileWorkingHoursSubtitle = 'profileWorkingHoursSubtitle';
  static String get profileWorkingHoursSubtitle => _profileWorkingHoursSubtitle.tr;

  static const String _profileNotifications = 'profileNotifications';
  static String get profileNotifications => _profileNotifications.tr;

  static const String _profileNotificationsSubtitle = 'profileNotificationsSubtitle';
  static String get profileNotificationsSubtitle => _profileNotificationsSubtitle.tr;

  static const String _profileThemeMode = 'profileThemeMode';
  static String get profileThemeMode => _profileThemeMode.tr;

  static const String _profileThemeModeSubtitle = 'profileThemeModeSubtitle';
  static String get profileThemeModeSubtitle => _profileThemeModeSubtitle.tr;

  static const String _profileSupport = 'profileSupport';
  static String get profileSupport => _profileSupport.tr;

  static const String _profileSupportSubtitle = 'profileSupportSubtitle';
  static String get profileSupportSubtitle => _profileSupportSubtitle.tr;

  static const String _profileLogout = 'profileLogout';
  static String get profileLogout => _profileLogout.tr;

  static const String _profileRatingLabel = 'profileRatingLabel';
  static String profileRatingLabel(String rating) =>
      _profileRatingLabel.tr.replaceFirst('{rating}', rating);

  static const String _profileEdit = 'profileEdit';
  static String get profileEdit => _profileEdit.tr;

  static const String _profileDriverAccount = 'profileDriverAccount';
  static String get profileDriverAccount => _profileDriverAccount.tr;

  static const String _profileVerified = 'profileVerified';
  static String get profileVerified => _profileVerified.tr;

  static const String _earningsSummary = 'earningsSummary';
  static String get earningsSummary => _earningsSummary.tr;

  static const String _earningsThisWeek = 'earningsThisWeek';
  static String get earningsThisWeek => _earningsThisWeek.tr;

  static const String _earningsCurrency = 'earningsCurrency';
  static String get earningsCurrency => _earningsCurrency.tr;

  static const String _earningsToday = 'earningsToday';
  static String get earningsToday => _earningsToday.tr;

  static const String _earningsTrips = 'earningsTrips';
  static String get earningsTrips => _earningsTrips.tr;

  static const String _earningsAcceptanceRate = 'earningsAcceptanceRate';
  static String get earningsAcceptanceRate => _earningsAcceptanceRate.tr;

  static const String _earningsPerformanceExcellent = 'earningsPerformanceExcellent';
  static String get earningsPerformanceExcellent => _earningsPerformanceExcellent.tr;

  static const String _earningsSilverTier = 'earningsSilverTier';
  static String get earningsSilverTier => _earningsSilverTier.tr;

  static const String _earningsGoldTierProgress = 'earningsGoldTierProgress';
  static String get earningsGoldTierProgress => _earningsGoldTierProgress.tr;

  static const String _earningsLastUpdated = 'earningsLastUpdated';
  static String get earningsLastUpdated => _earningsLastUpdated.tr;

  static const String _subscriptionsTitle = 'subscriptionsTitle';
  static String get subscriptionsTitle => _subscriptionsTitle.tr;

  static const String _subscriptionsActive = 'subscriptionsActive';
  static String get subscriptionsActive => _subscriptionsActive.tr;

  static const String _subscriptionsScheduled = 'subscriptionsScheduled';
  static String get subscriptionsScheduled => _subscriptionsScheduled.tr;

  static const String _subscriptionsExpired = 'subscriptionsExpired';
  static String get subscriptionsExpired => _subscriptionsExpired.tr;

  static const String _subscriptionsMinimumGuarantee = 'subscriptionsMinimumGuarantee';
  static String get subscriptionsMinimumGuarantee => _subscriptionsMinimumGuarantee.tr;

  static const String _subscriptionsWorkingHours = 'subscriptionsWorkingHours';
  static String get subscriptionsWorkingHours => _subscriptionsWorkingHours.tr;

  static const String _subscriptionsConfirmAttendance = 'subscriptionsConfirmAttendance';
  static String get subscriptionsConfirmAttendance => _subscriptionsConfirmAttendance.tr;

  static const String _subscriptionsMockTitle = 'subscriptionsMockTitle';
  static String get subscriptionsMockTitle => _subscriptionsMockTitle.tr;

  static const String _parcelStatusInDelivery = 'parcelStatusInDelivery';
  static String get parcelStatusInDelivery => _parcelStatusInDelivery.tr;

  static const String _parcelStatusLabel = 'parcelStatusLabel';
  static String get parcelStatusLabel => _parcelStatusLabel.tr;

  static const String _parcelStatusDescription = 'parcelStatusDescription';
  static String get parcelStatusDescription => _parcelStatusDescription.tr;

  static const String _parcelSourceTitle = 'parcelSourceTitle';
  static String get parcelSourceTitle => _parcelSourceTitle.tr;

  static const String _parcelSourceWarehouse = 'parcelSourceWarehouse';
  static String get parcelSourceWarehouse => _parcelSourceWarehouse.tr;

  static const String _parcelSourceDescription = 'parcelSourceDescription';
  static String get parcelSourceDescription => _parcelSourceDescription.tr;

  static const String _parcelReceived = 'parcelReceived';
  static String get parcelReceived => _parcelReceived.tr;

  static const String _parcelDetailsTitle = 'parcelDetailsTitle';
  static String get parcelDetailsTitle => _parcelDetailsTitle.tr;

  static const String _parcelVerifyIdentityBanner = 'parcelVerifyIdentityBanner';
  static String get parcelVerifyIdentityBanner => _parcelVerifyIdentityBanner.tr;

  static const String _parcelCustomerData = 'parcelCustomerData';
  static String get parcelCustomerData => _parcelCustomerData.tr;

  static const String _parcelCustomerInitials = 'parcelCustomerInitials';
  static String get parcelCustomerInitials => _parcelCustomerInitials.tr;

  static const String _parcelCustomerName = 'parcelCustomerName';
  static String get parcelCustomerName => _parcelCustomerName.tr;

  static const String _parcelCustomerAddress = 'parcelCustomerAddress';
  static String get parcelCustomerAddress => _parcelCustomerAddress.tr;

  static const String _parcelTourTitle = 'parcelTourTitle';
  static String get parcelTourTitle => _parcelTourTitle.tr;

  static const String _parcelTourStatus = 'parcelTourStatus';
  static String get parcelTourStatus => _parcelTourStatus.tr;

  static const String _parcelsTodayTitle = 'parcelsTodayTitle';
  static String get parcelsTodayTitle => _parcelsTodayTitle.tr;

  static const String _parcelsDeliveryList = 'parcelsDeliveryList';
  static String get parcelsDeliveryList => _parcelsDeliveryList.tr;

  static const String _parcelsNearestFirst = 'parcelsNearestFirst';
  static String get parcelsNearestFirst => _parcelsNearestFirst.tr;

  static const String _parcelsMockCount = 'parcelsMockCount';
  static String get parcelsMockCount => _parcelsMockCount.tr;

  static const String _orderProofOfDelivery = 'orderProofOfDelivery';
  static String get orderProofOfDelivery => _orderProofOfDelivery.tr;

  static const String _orderMockStore = 'orderMockStore';
  static String get orderMockStore => _orderMockStore.tr;

  static const String _orderStatusDelivered = 'orderStatusDelivered';
  static String get orderStatusDelivered => _orderStatusDelivered.tr;

  static const String _orderStatusCancelled = 'orderStatusCancelled';
  static String get orderStatusCancelled => _orderStatusCancelled.tr;

  static const String _subMockPeriod = 'subMockPeriod';
  static String get subMockPeriod => _subMockPeriod.tr;

  static const String _subMockGuarantee = 'subMockGuarantee';
  static String get subMockGuarantee => _subMockGuarantee.tr;

  static const String _subMockHours = 'subMockHours';
  static String get subMockHours => _subMockHours.tr;

  static const String _parcelActionMaps = 'parcelActionMaps';
  static String get parcelActionMaps => _parcelActionMaps.tr;

  static const String _parcelActionCall = 'parcelActionCall';
  static String get parcelActionCall => _parcelActionCall.tr;

  static const String _parcelMockCustomer1 = 'parcelMockCustomer1';
  static String get parcelMockCustomer1 => _parcelMockCustomer1.tr;

  static const String _parcelMockStation1 = 'parcelMockStation1';
  static String get parcelMockStation1 => _parcelMockStation1.tr;

  static const String _parcelMockCustomer2 = 'parcelMockCustomer2';
  static String get parcelMockCustomer2 => _parcelMockCustomer2.tr;

  static const String _parcelMockStation2 = 'parcelMockStation2';
  static String get parcelMockStation2 => _parcelMockStation2.tr;

  static const String _parcelStatusPending = 'parcelStatusPending';
  static String get parcelStatusPending => _parcelStatusPending.tr;

  static const String _parcelMockCustomer3 = 'parcelMockCustomer3';
  static String get parcelMockCustomer3 => _parcelMockCustomer3.tr;

  static const String _parcelMockStation3 = 'parcelMockStation3';
  static String get parcelMockStation3 => _parcelMockStation3.tr;

  static const String _parcelActionStartTour = 'parcelActionStartTour';
  static String get parcelActionStartTour => _parcelActionStartTour.tr;

  static const String _orderReadyForDelivery = 'orderReadyForDelivery';
  static String get orderReadyForDelivery => _orderReadyForDelivery.tr;

  static const String _orderMockCODValue = 'orderMockCODValue';
  static String get orderMockCODValue => _orderMockCODValue.tr;

  static const String _orderIdTitle = 'orderIdTitle';
  static String orderIdTitle(String orderId) =>
      _orderIdTitle.tr.replaceFirst('{orderId}', orderId);

  static const String _orderAltConfirmTitle = 'orderAltConfirmTitle';
  static String get orderAltConfirmTitle => _orderAltConfirmTitle.tr;

  static const String _orderAltConfirmSubtitle = 'orderAltConfirmSubtitle';
  static String get orderAltConfirmSubtitle => _orderAltConfirmSubtitle.tr;

  static const String _orderAltConfirmButton = 'orderAltConfirmButton';
  static String get orderAltConfirmButton => _orderAltConfirmButton.tr;

  static const String _orderMockCustomer = 'orderMockCustomer';
  static String get orderMockCustomer => _orderMockCustomer.tr;

  static const String _orderMockAddressShort = 'orderMockAddressShort';
  static String get orderMockAddressShort => _orderMockAddressShort.tr;

  static const String _orderMockCODAmount = 'orderMockCODAmount';
  static String get orderMockCODAmount => _orderMockCODAmount.tr;

  static const String _orderMockItem1 = 'orderMockItem1';
  static String get orderMockItem1 => _orderMockItem1.tr;

  static const String _orderMockItem2 = 'orderMockItem2';
  static String get orderMockItem2 => _orderMockItem2.tr;

  static const String _orderMockDeliveryFee = 'orderMockDeliveryFee';
  static String get orderMockDeliveryFee => _orderMockDeliveryFee.tr;

  static const String _orderPODEnterCode = 'orderPODEnterCode';
  static String get orderPODEnterCode => _orderPODEnterCode.tr;

  static const String _orderPODCodeHint = 'orderPODCodeHint';
  static String get orderPODCodeHint => _orderPODCodeHint.tr;

  static const String _orderPODConfirm = 'orderPODConfirm';
  static String get orderPODConfirm => _orderPODConfirm.tr;

  static const String _orderPODWarning = 'orderPODWarning';
  static String get orderPODWarning => _orderPODWarning.tr;

  static const String _orderMockAddressLong = 'orderMockAddressLong';
  static String get orderMockAddressLong => _orderMockAddressLong.tr;

  static const String _orderMockDistrict = 'orderMockDistrict';
  static String get orderMockDistrict => _orderMockDistrict.tr;

  static const String _orderMockPackageDesc = 'orderMockPackageDesc';
  static String get orderMockPackageDesc => _orderMockPackageDesc.tr;

  static const String _orderMockDate = 'orderMockDate';
  static String get orderMockDate => _orderMockDate.tr;

  static const String _orderMockEarnings = 'orderMockEarnings';
  static String get orderMockEarnings => _orderMockEarnings.tr;

  static const String _orderMockDistance1 = 'orderMockDistance1';
  static String get orderMockDistance1 => _orderMockDistance1.tr;

  static const String _orderMockETA = 'orderMockETA';
  static String get orderMockETA => _orderMockETA.tr;

  static const String _orderMockDistance2 = 'orderMockDistance2';
  static String get orderMockDistance2 => _orderMockDistance2.tr;

  static const String _orderMockRestaurantDistrict = 'orderMockRestaurantDistrict';
  static String get orderMockRestaurantDistrict => _orderMockRestaurantDistrict.tr;

  static const String _orderMockDestination = 'orderMockDestination';
  static String get orderMockDestination => _orderMockDestination.tr;

  static const String _orderMockCustomerInitial = 'orderMockCustomerInitial';
  static String get orderMockCustomerInitial => _orderMockCustomerInitial.tr;

  static const String _orderMockFullAddress = 'orderMockFullAddress';
  static String get orderMockFullAddress => _orderMockFullAddress.tr;

  static const String _earningsFeePrefix = 'earningsFeePrefix';
  static String get earningsFeePrefix => _earningsFeePrefix.tr;

  static const String _earningsFeeSuffix = 'earningsFeeSuffix';
  static String get earningsFeeSuffix => _earningsFeeSuffix.tr;

  static const String _earningsCompletedTripsToday = 'earningsCompletedTripsToday';
  static String get earningsCompletedTripsToday => _earningsCompletedTripsToday.tr;

  static const String _earningsTripsLabel = 'earningsTripsLabel';
  static String get earningsTripsLabel => _earningsTripsLabel.tr;

  static const String _homeMockDriverName = 'homeMockDriverName';
  static String get homeMockDriverName => _homeMockDriverName.tr;

  static const String _homeMockIncentives = 'homeMockIncentives';
  static String get homeMockIncentives => _homeMockIncentives.tr;

  static const String _homeMockCashTotal = 'homeMockCashTotal';
  static String get homeMockCashTotal => _homeMockCashTotal.tr;

  static const String _earningsMockDate = 'earningsMockDate';
  static String get earningsMockDate => _earningsMockDate.tr;

  static const String _earningsMockProgress = 'earningsMockProgress';
  static String get earningsMockProgress => _earningsMockProgress.tr;

  static const String _earningsMockCollected = 'earningsMockCollected';
  static String get earningsMockCollected => _earningsMockCollected.tr;

  static const String _earningsMockDueToAdmin = 'earningsMockDueToAdmin';
  static String get earningsMockDueToAdmin => _earningsMockDueToAdmin.tr;

  static const String _earningsMockIncentiveRate = 'earningsMockIncentiveRate';
  static String get earningsMockIncentiveRate => _earningsMockIncentiveRate.tr;

  static const String _earningsMockRemainingDeliveries = 'earningsMockRemainingDeliveries';
  static String get earningsMockRemainingDeliveries => _earningsMockRemainingDeliveries.tr;

  static const String _earningsIncentiveDesc = 'earningsIncentiveDesc';
  static String get earningsIncentiveDesc => _earningsIncentiveDesc.tr;

  static const String _earningsCollectedCashLabel = 'earningsCollectedCashLabel';
  static String get earningsCollectedCashLabel => _earningsCollectedCashLabel.tr;

  static const String _earningsEarnedIncentivesLabel = 'earningsEarnedIncentivesLabel';
  static String get earningsEarnedIncentivesLabel => _earningsEarnedIncentivesLabel.tr;

  static const String _earningsDueToAdminLabel = 'earningsDueToAdminLabel';
  static String get earningsDueToAdminLabel => _earningsDueToAdminLabel.tr;

  static const String _earningsIncentiveRateLabel = 'earningsIncentiveRateLabel';
  static String get earningsIncentiveRateLabel => _earningsIncentiveRateLabel.tr;

  static const String _earningsProgressLabel = 'earningsProgressLabel';
  static String get earningsProgressLabel => _earningsProgressLabel.tr;

  static const String _earningsActionSubmit = 'earningsActionSubmit';
  static String get earningsActionSubmit => _earningsActionSubmit.tr;

  static const String _authAppLogoName = 'authAppLogoName';
  static String get authAppLogoName => _authAppLogoName.tr;
  static const String _orderMockPrice1 = 'orderMockPrice1';
  static String get orderMockPrice1 => _orderMockPrice1.tr;
  static const String _orderMockPrice2 = 'orderMockPrice2';
  static String get orderMockPrice2 => _orderMockPrice2.tr;
  static const String _orderMockPrice3 = 'orderMockPrice3';
  static String get orderMockPrice3 => _orderMockPrice3.tr;

}
