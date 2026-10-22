import 'dart:math' as math;

import '../../../core/utils/extension.dart';
import '../../../core/utils/values/strings.dart';
import '../domain/entities/c2c_parcel.dart';

/// Localized display text, shared by the C2C screens.
extension C2cStatusLabel on C2cStatus? {
  String get label => switch (this) {
    C2cStatus.dispatching => Strings.c2cStatusAssigned,
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

  /// Safe destination area text: prefers `destination_area.display_name`,
  /// falls back to `destination_area.name`, then `dropoff.areaLabel`.
  String get destinationAreaLabel {
    final C2cArea? dest = destinationArea;
    if (dest != null) {
      if (dest.displayName.isNotEmpty) return dest.displayName;
      if (dest.name.isNotEmpty) return dest.name;
    }
    return dropoff.areaLabel;
  }

  /// "Al Malaz → Ramses" safe for offers.
  String get areaRoute {
    final String dest = destinationAreaLabel;
    final String origin = pickup.areaLabel;
    if (origin.isNotEmpty && dest.isNotEmpty) return '$origin → $dest';
    if (dest.isNotEmpty) return dest;
    return origin;
  }

  /// Calculates straight-line distance in meters between pickup and dropoff
  /// coordinates using the haversine formula; `null` when coordinates are missing.
  double? get estimatedDistanceMeters {
    final double? pLat = pickup.latitude;
    final double? pLon = pickup.longitude;
    final double? dLat = dropoff.latitude;
    final double? dLon = dropoff.longitude;
    if (pLat == null || pLon == null || dLat == null || dLon == null) {
      return null;
    }
    const double earthRadius = 6371000; // meters
    final double dLatRad = (dLat - pLat) * (math.pi / 180.0);
    final double dLonRad = (dLon - pLon) * (math.pi / 180.0);
    final double a =
        math.sin(dLatRad / 2) * math.sin(dLatRad / 2) +
        math.cos(pLat * (math.pi / 180.0)) *
            math.cos(dLat * (math.pi / 180.0)) *
            math.sin(dLonRad / 2) *
            math.sin(dLonRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// "840 m" / "1.4 km"; empty when no coordinates were provided.
  String get estimatedDistanceLabel {
    final double? meters = estimatedDistanceMeters;
    if (meters == null) return '';
    final int m = meters.round();
    if (m < 1000) return Strings.orderDistanceMeters(m);
    return Strings.orderDistanceKm((m / 1000).toStringAsFixed(1));
  }

  /// "25.00 SAR"; empty when totalFee is not sent.
  String get feeLabel {
    if (totalFee.isEmpty) return '';
    if (currency.isNotEmpty) return '$totalFee $currency';
    return totalFee;
  }

  /// "Expires at 20/10/2026 14:05"; `null` when the server sent no expiry.
  String? get expiryLabel {
    final DateTime? at = expiresAt;
    if (at == null) return null;
    final DateTime local = at.toLocal();
    return Strings.c2cOfferExpires(
      '${local.displayDate} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}',
    );
  }
}
