import 'package:equatable/equatable.dart';

import '../../domain/entities/c2c_parcel.dart';

sealed class C2cActionState extends Equatable {
  const C2cActionState();

  @override
  List<Object?> get props => [];
}

class C2cActionIdle extends C2cActionState {
  const C2cActionIdle();
}

class C2cActionInProgress extends C2cActionState {
  final C2cAction action;
  final int parcelId;

  const C2cActionInProgress(this.action, this.parcelId);

  @override
  List<Object?> get props => [action, parcelId];
}

/// The server accepted [action]. [parcel] is its answer, or `null` when it
/// sent none — re-read parcel [parcelId] then.
class C2cActionSuccess extends C2cActionState {
  final C2cAction action;
  final int parcelId;
  final C2cParcel? parcel;

  const C2cActionSuccess(this.action, this.parcelId, this.parcel);

  @override
  List<Object?> get props => [action, parcelId, parcel];
}

/// [shouldRefresh]: the server answered, so the parcel may have moved on
/// (e.g. someone else took the offer) — re-read it. A network failure
/// leaves the outcome unknown and is retried instead.
class C2cActionFailure extends C2cActionState {
  final C2cAction action;
  final String message;
  final bool shouldRefresh;

  const C2cActionFailure(
    this.action,
    this.message, {
    required this.shouldRefresh,
  });

  @override
  List<Object?> get props => [action, message, shouldRefresh];
}
