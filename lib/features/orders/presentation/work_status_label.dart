import '../../../core/utils/values/strings.dart';
import '../domain/entities/active_offer.dart';
import '../domain/entities/current_work.dart';

/// Localized display text — shared by the Orders tab and the trip screen.
extension WorkStatusLabel on WorkStatus {
  String get label => switch (this) {
    WorkStatus.driverAccepted => Strings.orderStatusDriverAccepted,
    WorkStatus.pickedUp => Strings.orderStatusPickedUp,
    WorkStatus.outForDelivery => Strings.orderStatusOutForDelivery,
    WorkStatus.delivered => Strings.orderStatusDelivered,
  };
}

extension CurrentWorkDisplay on CurrentWork {
  String get orderLabel => '#$orderId';

  /// "31 SAR" for cash on delivery, "Prepaid" otherwise.
  String get paymentLabel => isCashOnDelivery
      ? Strings.orderAmount(codAmount)
      : Strings.orderPaymentPrepaid;
}

extension ActiveOfferDisplay on ActiveOffer {
  String get orderLabel => '#$orderId';

  /// "840 m" / "1.4 km"; empty when the server sent no distance.
  String get distanceLabel {
    final int? meters = distanceMeters;
    if (meters == null) return '';
    if (meters < 1000) return Strings.orderDistanceMeters(meters);
    return Strings.orderDistanceKm((meters / 1000).toStringAsFixed(1));
  }

  String get paymentMethodLabel =>
      isCashOnDelivery ? Strings.orderPaymentCod : Strings.orderPaymentPrepaid;

  /// "125.00 SAR" for cash on delivery, "Prepaid" otherwise.
  String get paymentLabel => isCashOnDelivery
      ? Strings.orderAmount(codAmount)
      : Strings.orderPaymentPrepaid;
}
