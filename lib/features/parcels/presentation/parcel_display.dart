import '../../../core/utils/values/strings.dart';
import '../domain/entities/parcel.dart';

/// Localized display text, shared by the parcel screens.
extension ParcelStatusLabel on ParcelStatus {
  String get label => switch (this) {
    ParcelStatus.arrivedAtWarehouse => Strings.parcelStatusPending,
    ParcelStatus.outForDelivery => Strings.parcelStatusInDelivery,
    ParcelStatus.delivered => Strings.parcelStatusDelivered,
  };
}

extension ParcelDisplay on Parcel {
  /// The tracking number the Driver sees on the box; the id if it's missing.
  String get label => trackingNumber.isEmpty ? '#$id' : trackingNumber;

  String get statusLabel => status?.label ?? '-';

  String get recipientLabel => recipientName.isEmpty ? '-' : recipientName;

  /// "75.50 SAR" for cash on delivery, "Prepaid" otherwise.
  String get paymentLabel => isCashOnDelivery
      ? Strings.orderAmount(codAmount)
      : Strings.orderPaymentPrepaid;
}
