import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/ringtone/ringtone_service.dart';
import '../../domain/entities/c2c_parcel.dart';

enum C2cOfferAlertState {
  /// Ringing until the Driver answers, the offer expires, or the sheet goes.
  ringing,

  /// The Driver tapped accept; its answer decides what happens next.
  silenced,

  /// [C2cParcel.expiresAt] passed before the Driver answered.
  expired,
}

/// Rings for one C2C offer sheet and ends it when the offer lapses.
///
/// The ringtone stops on [silence], on expiry, and when the cubit closes —
/// whichever comes first — so dismissing the sheet always silences it.
class C2cOfferAlertCubit extends Cubit<C2cOfferAlertState> {
  final RingtoneService _ringtone;
  final DateTime Function() _now;

  Timer? _expiry;
  bool _ringing = false;

  C2cOfferAlertCubit(this._ringtone, {DateTime Function() now = DateTime.now})
    : _now = now,
      super(C2cOfferAlertState.ringing);

  /// Starts ringing for [offer], and schedules its expiry when it has one.
  void start(C2cParcel offer) {
    final DateTime? expiresAt = offer.expiresAt;
    final Duration? left = expiresAt?.difference(_now());
    if (left != null && left <= Duration.zero) {
      emit(C2cOfferAlertState.expired);
      return;
    }
    if (left != null) _expiry = Timer(left, _expire);
    _ringing = true;
    unawaited(_ringtone.play());
  }

  /// The Driver answered: quiet now, not when the server replies. The expiry
  /// is dropped too — an accept already on its way decides the outcome.
  void silence() {
    if (state != C2cOfferAlertState.ringing) return;
    _stop();
    emit(C2cOfferAlertState.silenced);
  }

  void _expire() {
    if (isClosed || state != C2cOfferAlertState.ringing) return;
    _stop();
    emit(C2cOfferAlertState.expired);
  }

  void _stop() {
    _expiry?.cancel();
    _expiry = null;
    if (!_ringing) return;
    _ringing = false;
    unawaited(_ringtone.stop());
  }

  @override
  Future<void> close() {
    _stop();
    return super.close();
  }
}
