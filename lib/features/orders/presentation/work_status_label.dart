import '../../../core/utils/values/strings.dart';
import '../domain/entities/current_work.dart';

/// Localized display text — shared by the Orders tab and the trip screen.
extension WorkStatusLabel on WorkStatus {
  String get label => switch (this) {
    WorkStatus.driverAccepted => Strings.orderStatusDriverAccepted,
    WorkStatus.pickedUp => Strings.orderStatusPickedUp,
    WorkStatus.outForDelivery => Strings.orderStatusOutForDelivery,
  };
}

extension CurrentWorkDisplay on CurrentWork {
  String get orderLabel => '#$orderId';

  /// "31 SAR" for cash on delivery, "Prepaid" otherwise.
  String get paymentLabel => isCashOnDelivery
      ? Strings.orderAmount(codAmount)
      : Strings.orderPaymentPrepaid;
}
