import 'package:equatable/equatable.dart';

/// Parcel lifecycle (API docs §13). `start-delivery` is optional — a parcel
/// can be completed straight from the warehouse.
enum ParcelStatus {
  arrivedAtWarehouse('ARRIVED_AT_WAREHOUSE'),
  outForDelivery('OUT_FOR_DELIVERY'),
  delivered('DELIVERED');

  final String apiValue;
  const ParcelStatus(this.apiValue);

  /// `null` for a missing or unrecognised value.
  static ParcelStatus? fromApi(String? value) {
    for (final ParcelStatus status in values) {
      if (status.apiValue == value) return status;
    }
    return null;
  }
}

/// Which parcels `GET /delivery-man/parcels` returns.
enum ParcelListFilter {
  active('active'),
  delivered('delivered');

  final String apiValue;
  const ParcelListFilter(this.apiValue);
}

/// A warehouse/shipping job assigned to the Driver by an admin — separate
/// from normal store orders.
class Parcel extends Equatable {
  final int id;
  final String trackingNumber;

  /// `null` for an unrecognised status value.
  final ParcelStatus? status;

  final String recipientName;
  final String recipientPhone;
  final String deliveryAddress;
  final double? latitude;
  final double? longitude;

  /// Empty when the server sent no company.
  final String shippingCompanyName;

  /// `metadata.customer_notes`, e.g. "Call on arrival".
  final String? customerNotes;

  final bool isCashOnDelivery;

  /// Decimal string exactly as the API sent it ("75.50") — display only,
  /// never parse to a float, recompute or send back (API docs §12).
  final String codAmount;

  const Parcel({
    required this.id,
    required this.trackingNumber,
    required this.status,
    required this.recipientName,
    required this.recipientPhone,
    required this.deliveryAddress,
    required this.latitude,
    required this.longitude,
    required this.shippingCompanyName,
    required this.customerNotes,
    required this.isCashOnDelivery,
    required this.codAmount,
  });

  /// Still at the warehouse — delivery hasn't been started.
  bool get awaitingStart => status == ParcelStatus.arrivedAtWarehouse;

  bool get isOutForDelivery => status == ParcelStatus.outForDelivery;

  bool get isDelivered => status == ParcelStatus.delivered;

  @override
  List<Object?> get props => [
    id,
    trackingNumber,
    status,
    recipientName,
    recipientPhone,
    deliveryAddress,
    latitude,
    longitude,
    shippingCompanyName,
    customerNotes,
    isCashOnDelivery,
    codAmount,
  ];
}

/// One page of `GET /delivery-man/parcels`. [totalSize] is the server's
/// count across all pages, which may exceed [parcels.length].
class ParcelsPage extends Equatable {
  final List<Parcel> parcels;
  final int totalSize;

  const ParcelsPage({required this.parcels, required this.totalSize});

  /// This list followed by [next]'s parcels, skipping any already here — the
  /// active list can shift between page requests as parcels are delivered.
  /// Takes [next]'s total, the newer count.
  ParcelsPage appending(ParcelsPage next) {
    final Set<int> known = <int>{for (final Parcel p in parcels) p.id};
    return ParcelsPage(
      parcels: <Parcel>[
        ...parcels,
        for (final Parcel p in next.parcels)
          if (!known.contains(p.id)) p,
      ],
      totalSize: next.totalSize,
    );
  }

  /// This page with [parcel] swapped in for the entry with the same id.
  ParcelsPage replacing(Parcel parcel) => ParcelsPage(
    parcels: <Parcel>[
      for (final Parcel p in parcels) p.id == parcel.id ? parcel : p,
    ],
    totalSize: totalSize,
  );

  @override
  List<Object?> get props => [parcels, totalSize];
}
