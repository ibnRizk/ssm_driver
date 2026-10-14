import 'package:equatable/equatable.dart';

/// Which jobs `GET /delivery-man/work-history` returns.
enum HistoryScope {
  /// Accepted and still active.
  current('current'),

  /// Delivered or cancelled.
  previous('previous');

  final String apiValue;
  const HistoryScope(this.apiValue);
}

/// One status vocabulary for both feeds: store orders send `ssm_status`,
/// C2C parcels `status` (C2C contract §2).
enum HistoryStatus {
  assigned,
  accepted,
  atPickup,
  pickedUp,
  outForDelivery,
  delivered,
  cancelled,
  failedDelivery,
  returning,
  returned;

  /// `null` for a missing or unrecognised value.
  static HistoryStatus? fromApi(String? value) =>
      switch (value?.toLowerCase()) {
        'driver_assigned' => assigned,
        'driver_accepted' => accepted,
        'driver_at_pickup' => atPickup,
        'picked_up' => pickedUp,
        'out_for_delivery' => outForDelivery,
        'delivered' => delivered,
        'cancelled' || 'canceled' => cancelled,
        'failed_delivery' => failedDelivery,
        'returning' || 'return_started' || 'returning_to_sender' => returning,
        'returned' => returned,
        _ => null,
      };
}

/// A store order in the Driver's history. Only what the list shows — no
/// customer contact details are read for history.
class HistoryOrder extends Equatable {
  final int orderId;

  /// `null` for an unrecognised status.
  final HistoryStatus? status;

  /// Empty when the server sent none.
  final String storeName;
  final String deliveryAddress;

  final bool isCashOnDelivery;

  /// Decimal string exactly as sent — display only (API docs §12).
  final String amount;

  /// When the job last changed; `null` if absent or unreadable.
  final DateTime? date;

  const HistoryOrder({
    required this.orderId,
    required this.status,
    required this.storeName,
    required this.deliveryAddress,
    required this.isCashOnDelivery,
    required this.amount,
    required this.date,
  });

  @override
  List<Object?> get props => [
    orderId,
    status,
    storeName,
    deliveryAddress,
    isCashOnDelivery,
    amount,
    date,
  ];
}

/// A C2C (house-to-house) parcel in the Driver's history (C2C contract §3).
/// Sender and recipient names only — never phones.
class HistoryParcel extends Equatable {
  final int id;

  /// "C2C-…"; empty if not sent.
  final String reference;

  /// `null` for an unrecognised status.
  final HistoryStatus? status;

  /// The server marks the parcel finished.
  final bool isTerminal;

  /// What's being sent ("Document"); empty if not sent.
  final String title;
  final String senderName;
  final String recipientName;

  final DateTime? date;

  const HistoryParcel({
    required this.id,
    required this.reference,
    required this.status,
    required this.isTerminal,
    required this.title,
    required this.senderName,
    required this.recipientName,
    required this.date,
  });

  /// Accepted and unfinished — there's still a C2C step to perform.
  bool get isActiveWork =>
      !isTerminal &&
      switch (status) {
        HistoryStatus.accepted ||
        HistoryStatus.atPickup ||
        HistoryStatus.pickedUp ||
        HistoryStatus.outForDelivery => true,
        _ => false,
      };

  @override
  List<Object?> get props => [
    id,
    reference,
    status,
    isTerminal,
    title,
    senderName,
    recipientName,
    date,
  ];
}

/// One or more pages of the unified feed. Orders and parcels page together
/// (one `limit`/`offset` per request), each with its own server total.
class WorkHistoryPage extends Equatable {
  final List<HistoryOrder> orders;
  final List<HistoryParcel> parcels;
  final int ordersTotal;
  final int parcelsTotal;

  const WorkHistoryPage({
    required this.orders,
    required this.parcels,
    required this.ordersTotal,
    required this.parcelsTotal,
  });

  /// This page followed by [next]'s items, skipping any already here — the
  /// current feed can shift between requests. Takes [next]'s totals.
  WorkHistoryPage appending(WorkHistoryPage next) {
    final Set<int> knownOrders = <int>{for (final o in orders) o.orderId};
    final Set<int> knownParcels = <int>{for (final p in parcels) p.id};
    return WorkHistoryPage(
      orders: <HistoryOrder>[
        ...orders,
        for (final HistoryOrder o in next.orders)
          if (!knownOrders.contains(o.orderId)) o,
      ],
      parcels: <HistoryParcel>[
        ...parcels,
        for (final HistoryParcel p in next.parcels)
          if (!knownParcels.contains(p.id)) p,
      ],
      ordersTotal: next.ordersTotal,
      parcelsTotal: next.parcelsTotal,
    );
  }

  bool get isEmpty => orders.isEmpty && parcels.isEmpty;

  /// Either feed still has items on the server beyond what's loaded.
  bool get hasMore =>
      orders.length < ordersTotal || parcels.length < parcelsTotal;

  @override
  List<Object?> get props => [orders, parcels, ordersTotal, parcelsTotal];
}
