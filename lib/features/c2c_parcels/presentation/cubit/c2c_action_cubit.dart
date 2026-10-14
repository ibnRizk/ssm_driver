import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/uuid.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/repositories/c2c_parcels_repository.dart';
import 'c2c_action_state.dart';

/// Sends the C2C lifecycle commands: accept, arrive at pickup, pickup, out
/// for delivery, complete.
///
/// Every command carries an `Idempotency-Key` (contract §2): generated once
/// per Driver action, reused only while retrying that same action after a
/// network failure, and discarded once the server answers definitively.
class C2cActionCubit extends Cubit<C2cActionState> {
  final C2cParcelsRepository _repository;
  final String Function() _newIdempotencyKey;

  /// The last command whose outcome is unknown, with its key.
  ({String fingerprint, String key})? _pending;

  static final RegExp _otpPattern = RegExp(r'^\d{6}$');

  C2cActionCubit(
    this._repository, {
    String Function() newIdempotencyKey = generateUuidV4,
  }) : _newIdempotencyKey = newIdempotencyKey,
       super(const C2cActionIdle());

  /// Runs [action] on [parcel]. A completion of a parcel that
  /// [C2cParcel.requiresOtpToComplete] needs the recipient's six-digit
  /// [otp]; without it nothing is sent.
  Future<void> run(C2cParcel parcel, C2cAction action, {String? otp}) async {
    if (state is C2cActionInProgress) return;
    final bool needsOtp =
        action == C2cAction.complete && parcel.requiresOtpToComplete;
    if (needsOtp && !_otpPattern.hasMatch(otp ?? '')) {
      emit(
        C2cActionFailure(
          action,
          Strings.orderOtpIncomplete,
          shouldRefresh: false,
        ),
      );
      return;
    }
    final String? sentOtp = needsOtp ? otp : null;

    // A corrected OTP is a different command, so it gets a fresh key.
    final String fingerprint = '${parcel.id}:${action.name}:${sentOtp ?? ''}';
    final ({String fingerprint, String key})? pending = _pending;
    final String key = pending != null && pending.fingerprint == fingerprint
        ? pending.key
        : _newIdempotencyKey();
    _pending = (fingerprint: fingerprint, key: key);

    emit(C2cActionInProgress(action, parcel.id));
    final Either<Failure, C2cParcel?> result = await _repository.runAction(
      parcel.id,
      action,
      idempotencyKey: key,
      otp: sentOtp,
    );
    if (isClosed) return;

    result.fold(
      (Failure f) {
        final bool outcomeUnknown = f is NetworkFailure;
        if (!outcomeUnknown) _pending = null;
        emit(
          C2cActionFailure(
            action,
            f.message ?? Strings.somethingWentWrong,
            shouldRefresh: !outcomeUnknown,
          ),
        );
      },
      (C2cParcel? updated) {
        _pending = null;
        emit(C2cActionSuccess(action, parcel.id, updated));
      },
    );
  }
}
