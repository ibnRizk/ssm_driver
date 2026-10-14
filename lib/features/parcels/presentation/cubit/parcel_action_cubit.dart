import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/location/device_location.dart';
import '../../../../core/services/location/location_failure.dart';
import '../../../../core/services/location/location_service.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/entities/parcel_proof.dart';
import '../../domain/repositories/parcels_repository.dart';
import 'parcel_action_state.dart';

/// Sends the parcel commands: start delivery, and complete with an OTP or
/// location/time proof. Unlike order commands the parcel API needs no
/// Idempotency-Key — a repeated completion just returns the delivered state.
class ParcelActionCubit extends Cubit<ParcelActionState> {
  final ParcelsRepository _repository;
  final LocationService _location;

  static final RegExp _otpPattern = RegExp(r'^\d{6}$');

  ParcelActionCubit(this._repository, this._location)
    : super(const ParcelActionIdle());

  Future<void> startDelivery(Parcel parcel) => _run(
    ParcelAction.startDelivery,
    () => _repository.startDelivery(parcel.id),
  );

  /// The OTP is the six-digit code the recipient shows. A cash parcel needs
  /// [cashCollected] — the Driver's explicit confirmation that they took the
  /// cash — and is refused without it; a prepaid parcel ignores it.
  Future<void> completeWithOtp(
    Parcel parcel,
    String otp, {
    bool cashCollected = false,
  }) async {
    if (state is ParcelActionInProgress) return;
    if (_cashUnconfirmed(parcel, cashCollected)) return;
    if (!_otpPattern.hasMatch(otp)) {
      emit(
        ParcelActionFailure(
          ParcelAction.complete,
          Strings.orderOtpIncomplete,
          shouldRefresh: false,
        ),
      );
      return;
    }
    await _complete(parcel, ParcelOtpProof(otp), cashCollected);
  }

  /// Completes with the device's current position as proof — the
  /// alternative when the recipient can't give the OTP. Same [cashCollected]
  /// rule as [completeWithOtp].
  Future<void> completeWithLocation(
    Parcel parcel, {
    bool cashCollected = false,
  }) async {
    if (state is ParcelActionInProgress) return;
    if (_cashUnconfirmed(parcel, cashCollected)) return;
    emit(const ParcelActionInProgress(ParcelAction.complete));

    final Either<LocationFailure, DeviceLocation> fix = await _location
        .currentLocation(requestPermission: true);
    if (isClosed) return;
    await fix.fold(
      (LocationFailure f) async => emit(
        ParcelActionFailure(
          ParcelAction.complete,
          f.message,
          shouldRefresh: false,
        ),
      ),
      (DeviceLocation location) =>
          _complete(parcel, ParcelLocationProof(location), cashCollected),
    );
  }

  /// Refuses a cash parcel whose cash the Driver hasn't confirmed, before
  /// anything is sent — the server would otherwise record no collection.
  bool _cashUnconfirmed(Parcel parcel, bool cashCollected) {
    if (!parcel.isCashOnDelivery || cashCollected) return false;
    emit(
      ParcelActionFailure(
        ParcelAction.complete,
        Strings.parcelCodConfirmRequired,
        shouldRefresh: false,
      ),
    );
    return true;
  }

  Future<void> _complete(
    Parcel parcel,
    ParcelProof proof,
    bool cashCollected,
  ) => _run(
    ParcelAction.complete,
    () => _repository.completeParcel(
      parcel.id,
      proof: proof,
      codCollected: parcel.isCashOnDelivery && cashCollected,
    ),
    // completeWithLocation already shows progress while taking the fix.
    alreadyInProgress: proof is ParcelLocationProof,
  );

  Future<void> _run(
    ParcelAction action,
    Future<Either<Failure, Parcel>> Function() send, {
    bool alreadyInProgress = false,
  }) async {
    if (!alreadyInProgress) {
      if (state is ParcelActionInProgress) return;
      emit(ParcelActionInProgress(action));
    }

    final Either<Failure, Parcel> result = await send();
    if (isClosed) return;
    result.fold(
      (Failure f) => emit(
        ParcelActionFailure(
          action,
          f.message ?? Strings.somethingWentWrong,
          shouldRefresh: f is! NetworkFailure,
        ),
      ),
      (Parcel parcel) => emit(ParcelActionSuccess(action, parcel)),
    );
  }
}
