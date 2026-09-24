import 'package:equatable/equatable.dart';

import 'current_work.dart';

/// The server's answer to a lifecycle command (pickup, out-for-delivery,
/// complete) — the order's new authoritative status and version.
class WorkTransition extends Equatable {
  final int orderId;

  /// `null` for an unrecognised status value.
  final WorkStatus? status;
  final int statusVersion;

  /// True when the server replayed an already-committed command (a retry
  /// with the same Idempotency-Key).
  final bool isReplay;

  const WorkTransition({
    required this.orderId,
    required this.status,
    required this.statusVersion,
    this.isReplay = false,
  });

  @override
  List<Object?> get props => [orderId, status, statusVersion, isReplay];
}
