import 'package:equatable/equatable.dart';

import '../../domain/entities/parcel.dart';

enum ParcelAction { startDelivery, complete }

sealed class ParcelActionState extends Equatable {
  const ParcelActionState();

  @override
  List<Object?> get props => [];
}

class ParcelActionIdle extends ParcelActionState {
  const ParcelActionIdle();
}

class ParcelActionInProgress extends ParcelActionState {
  final ParcelAction action;

  const ParcelActionInProgress(this.action);

  @override
  List<Object?> get props => [action];
}

/// [parcel] is the server's updated copy.
class ParcelActionSuccess extends ParcelActionState {
  final ParcelAction action;
  final Parcel parcel;

  const ParcelActionSuccess(this.action, this.parcel);

  @override
  List<Object?> get props => [action, parcel];
}

/// [shouldRefresh] is true when the server gave a definitive answer (e.g.
/// 422 already delivered) — re-read the parcel before the next action. False
/// for a network failure or a proof problem caught on the device.
class ParcelActionFailure extends ParcelActionState {
  final ParcelAction action;
  final String message;
  final bool shouldRefresh;

  const ParcelActionFailure(
    this.action,
    this.message, {
    required this.shouldRefresh,
  });

  @override
  List<Object?> get props => [action, message, shouldRefresh];
}
