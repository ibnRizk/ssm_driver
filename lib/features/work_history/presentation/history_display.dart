import '../../../core/utils/extension.dart';
import '../../../core/utils/values/strings.dart';
import '../domain/entities/work_history.dart';

/// Localized display text for the history screen.
extension HistoryStatusLabel on HistoryStatus? {
  String get label => switch (this) {
    HistoryStatus.assigned => Strings.c2cStatusAssigned,
    HistoryStatus.accepted => Strings.workHistoryStatusAccepted,
    HistoryStatus.atPickup => Strings.c2cStatusAtPickup,
    HistoryStatus.pickedUp => Strings.workHistoryStatusPickedUp,
    HistoryStatus.outForDelivery => Strings.workHistoryStatusOutForDelivery,
    HistoryStatus.delivered => Strings.workHistoryStatusDelivered,
    HistoryStatus.cancelled => Strings.workHistoryStatusCancelled,
    HistoryStatus.failedDelivery => Strings.c2cStatusFailed,
    HistoryStatus.returning => Strings.c2cStatusReturning,
    HistoryStatus.returned => Strings.c2cStatusReturned,
    null => '-',
  };

  /// Finished jobs read as settled, not in progress.
  bool get isFinal => switch (this) {
    HistoryStatus.delivered ||
    HistoryStatus.cancelled ||
    HistoryStatus.failedDelivery ||
    HistoryStatus.returned => true,
    _ => false,
  };
}

extension HistoryOrderDisplay on HistoryOrder {
  String get title => Strings.workHistoryOrderLabel(orderId);

  /// "Store → address", or whichever half the server sent.
  String get route => <String>[
    storeName,
    deliveryAddress,
  ].where((String s) => s.isNotEmpty).join(' → ');

  String get paymentLabel => isCashOnDelivery
      ? Strings.orderAmount(amount)
      : Strings.orderPaymentPrepaid;

  String? get dateLabel => date?.toLocal().displayDate;
}

extension HistoryParcelDisplay on HistoryParcel {
  String get label => reference.isEmpty ? '#$id' : reference;

  /// "Sender → Recipient", or whichever half is known.
  String get route => <String>[
    senderName,
    recipientName,
  ].where((String s) => s.isNotEmpty).join(' → ');

  String? get dateLabel => date?.toLocal().displayDate;
}
