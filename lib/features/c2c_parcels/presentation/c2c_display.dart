import '../../../core/utils/values/strings.dart';
import '../domain/entities/c2c_parcel.dart';

/// Localized display text, shared by the C2C screens.
extension C2cStatusLabel on C2cStatus? {
  String get label => switch (this) {
    C2cStatus.driverAssigned => Strings.c2cStatusAssigned,
    C2cStatus.driverAccepted => Strings.c2cStatusAccepted,
    C2cStatus.driverAtPickup => Strings.c2cStatusAtPickup,
    C2cStatus.pickedUp => Strings.workHistoryStatusPickedUp,
    C2cStatus.outForDelivery => Strings.workHistoryStatusOutForDelivery,
    C2cStatus.delivered => Strings.workHistoryStatusDelivered,
    C2cStatus.cancelled => Strings.workHistoryStatusCancelled,
    C2cStatus.failedDelivery => Strings.c2cStatusFailed,
    C2cStatus.returning => Strings.c2cStatusReturning,
    C2cStatus.returned => Strings.c2cStatusReturned,
    null => '-',
  };
}

extension C2cActionLabel on C2cAction {
  String get label => switch (this) {
    C2cAction.accept => Strings.c2cActionAccept,
    C2cAction.arrivePickup => Strings.c2cActionArrivePickup,
    C2cAction.pickup => Strings.c2cActionPickup,
    C2cAction.outForDelivery => Strings.c2cActionOutForDelivery,
    C2cAction.complete => Strings.c2cActionComplete,
  };
}

extension C2cStopDisplay on C2cStop {
  /// The coarse area — all an offer shows.
  String get areaLabel => area.isEmpty ? Strings.c2cAreaUnknown : area;

  /// The street address when released, else the area.
  String get placeLabel => address.isNotEmpty ? address : areaLabel;
}

extension C2cParcelDisplay on C2cParcel {
  String get label => reference.isEmpty ? '#$id' : reference;

  /// "Document • 1.5 kg • Fragile" — whatever the server described.
  String get summary => <String>[
    if (title.isNotEmpty) title else if (category.isNotEmpty) category,
    if (weightKg.isNotEmpty) Strings.c2cWeight(weightKg),
    if (isFragile) Strings.c2cFragile,
  ].join(' • ');

  /// "Al Malaz → Olaya" from the coarse areas only, safe for offers.
  String get areaRoute => '${pickup.areaLabel} → ${dropoff.areaLabel}';
}
