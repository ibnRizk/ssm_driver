import 'package:equatable/equatable.dart';

/// C2C parcel lifecycle (C2C contract §2), plus the exits the realtime
/// events name (§4). Not the warehouse `ARRIVED_AT_WAREHOUSE` flow.
enum C2cStatus {
  /// The offer is being dispatched to available drivers — shown before
  /// acceptance in the new offer payload (API update 2026-10-20).
  dispatching('dispatching'),
  driverAssigned('driver_assigned'),
  driverAccepted('driver_accepted'),
  driverAtPickup('driver_at_pickup'),
  pickedUp('picked_up'),
  outForDelivery('out_for_delivery'),
  delivered('delivered'),
  cancelled('cancelled'),
  failedDelivery('failed_delivery'),
  returning('returning'),
  returned('returned');

  final String apiValue;
  const C2cStatus(this.apiValue);

  /// `null` for a missing or unrecognised value.
  static C2cStatus? fromApi(String? value) {
    final String? v = value?.toLowerCase();
    if (v == 'return_started' || v == 'returning_to_sender') return returning;
    for (final C2cStatus status in values) {
      if (status.apiValue == v) return status;
    }
    return null;
  }

  /// The six steps of the happy path, in order.
  static const List<C2cStatus> lifecycle = <C2cStatus>[
    driverAssigned,
    driverAccepted,
    driverAtPickup,
    pickedUp,
    outForDelivery,
    delivered,
  ];
}

/// A Driver command on a C2C parcel. Each maps to one
/// `POST /delivery-man/c2c-parcels/{id}/…` endpoint.
enum C2cAction {
  accept('accept'),
  arrivePickup('arrive_pickup'),
  pickup('pickup'),
  outForDelivery('out_for_delivery'),
  complete('complete');

  final String apiValue;
  const C2cAction(this.apiValue);

  /// Accepts the `next_actions` spellings with `-` or `_`; `null` for an
  /// action this app can't perform.
  static C2cAction? fromApi(String? value) {
    final String? v = value?.toLowerCase().replaceAll('-', '_');
    for (final C2cAction action in values) {
      if (action.apiValue == v) return action;
    }
    return null;
  }
}

/// The sender's pickup point or the recipient's drop-off point.
///
/// Before acceptance only [area] is filled — names, phones, addresses and
/// coordinates stay empty (contract §7), whatever the server sent.
class C2cStop extends Equatable {
  final String name;
  final String phone;

  /// The street address; empty when not sent or before acceptance.
  final String address;

  /// The coarse area ("Al Malaz, Riyadh"); may be empty after acceptance.
  final String area;

  final double? latitude;
  final double? longitude;

  const C2cStop({
    required this.name,
    required this.phone,
    required this.address,
    required this.area,
    required this.latitude,
    required this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  @override
  List<Object?> get props => [name, phone, address, area, latitude, longitude];
}

/// A named destination area returned in the offer payload (API §2).
///
/// Only [displayName] is shown to the driver in the offer sheet.
/// The exact street address is withheld until acceptance.
class C2cArea extends Equatable {
  final int id;
  final String name;

  /// Localised name — use this in the UI (e.g. "رمسيس").
  final String displayName;

  const C2cArea({
    required this.id,
    required this.name,
    required this.displayName,
  });

  /// A safe label: prefers [displayName], falls back to [name], then empty.
  String get label => displayName.isNotEmpty ? displayName : name;

  @override
  List<Object?> get props => [id, name, displayName];
}

/// A customer-to-customer parcel the Driver is offered or working on.
class C2cParcel extends Equatable {
  final int id;

  /// The offer's own ID used for offer-scoped actions such as reject
  /// (`POST /delivery-man/c2c-parcels/offers/{offer_id}/reject`).
  /// `null` for active jobs where only [id] (parcel_id) matters.
  final int? offerId;

  /// "C2C-…" — what the sender and recipient see; empty if not sent.
  final String reference;

  /// `null` for an unrecognised status.
  final C2cStatus? status;
  final int statusVersion;

  /// The server says the parcel is finished (delivered, cancelled, …).
  final bool isTerminal;

  final String title;
  final String description;
  final String category;

  /// Decimal string as sent ("1.5"); empty if not sent.
  final String weightKg;
  final bool isFragile;
  final String pickupInstructions;
  final String deliveryInstructions;

  final C2cStop pickup;
  final C2cStop dropoff;

  /// The named destination area from the offer payload — safe to show before
  /// acceptance. `null` for active jobs (full address is in [dropoff] then).
  final C2cArea? destinationArea;

  /// Driver's earnings for this parcel, as a decimal string (e.g. "25.00");
  /// empty when not sent.
  final String totalFee;

  /// Currency code / symbol as sent by the server (e.g. "SAR").
  final String currency;

  /// What the server allows next. May be empty; see [primaryAction].
  final List<C2cAction> nextActions;

  /// `complete` must carry the recipient's hand-over code (contract §5).
  final bool requiresOtpToComplete;

  /// When an offer lapses; `null` if not sent.
  final DateTime? expiresAt;

  const C2cParcel({
    required this.id,
    this.offerId,
    required this.reference,
    required this.status,
    required this.statusVersion,
    required this.isTerminal,
    required this.title,
    required this.description,
    required this.category,
    required this.weightKg,
    required this.isFragile,
    required this.pickupInstructions,
    required this.deliveryInstructions,
    required this.pickup,
    required this.dropoff,
    this.destinationArea,
    this.totalFee = '',
    this.currency = '',
    required this.nextActions,
    required this.requiresOtpToComplete,
    required this.expiresAt,
  });

  /// Still an offer: contact details and exact locations aren't released.
  /// Covers both `dispatching` (new offer payload) and `driver_assigned`.
  bool get isOffer =>
      status == null ||
      status == C2cStatus.dispatching ||
      status == C2cStatus.driverAssigned;

  /// Accepted and not finished — the Driver must report their location
  /// (contract §4).
  bool get isActiveWork =>
      !isTerminal &&
      switch (status) {
        C2cStatus.driverAccepted ||
        C2cStatus.driverAtPickup ||
        C2cStatus.pickedUp ||
        C2cStatus.outForDelivery => true,
        _ => false,
      };

  /// Before pickup the Driver heads to the sender, afterwards to the
  /// recipient.
  bool get isHeadingToPickup =>
      status == C2cStatus.driverAccepted || status == C2cStatus.driverAtPickup;

  /// The one command the job screen offers. The server's [nextActions] win;
  /// without them the lifecycle decides.
  C2cAction? get primaryAction {
    for (final C2cAction action in C2cAction.values) {
      if (nextActions.contains(action)) return action;
    }
    if (isTerminal) return null;
    return switch (status) {
      C2cStatus.driverAssigned => C2cAction.accept,
      C2cStatus.driverAccepted => C2cAction.arrivePickup,
      C2cStatus.driverAtPickup => C2cAction.pickup,
      C2cStatus.pickedUp => C2cAction.outForDelivery,
      C2cStatus.outForDelivery => C2cAction.complete,
      _ => null,
    };
  }

  @override
  List<Object?> get props => [
    id,
    offerId,
    reference,
    status,
    statusVersion,
    isTerminal,
    title,
    description,
    category,
    weightKg,
    isFragile,
    pickupInstructions,
    deliveryInstructions,
    pickup,
    dropoff,
    destinationArea,
    totalFee,
    currency,
    nextActions,
    requiresOtpToComplete,
    expiresAt,
  ];
}
