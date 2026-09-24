import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/location/device_location.dart';
import '../../../../core/services/location/location_failure.dart';
import '../../../../core/services/location/location_service.dart';
import '../../../../core/utils/uuid.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/current_work.dart';
import '../../domain/entities/work_transition.dart';
import '../../domain/repositories/orders_repository.dart';
import 'order_lifecycle_state.dart';

/// Sends the retry-safe delivery commands for one step screen.
///
/// Every command carries an `Idempotency-Key` (API docs §4): generated once
/// per user action, reused while retrying that same action after a network
/// failure, and discarded once the server answers definitively.
class OrderLifecycleCubit extends Cubit<OrderLifecycleState> {
  final OrdersRepository _repository;
  final LocationService _location;
  final String Function() _newIdempotencyKey;
  final Map<LifecycleAction, _PendingCommand> _pending =
      <LifecycleAction, _PendingCommand>{};

  static final RegExp _otpPattern = RegExp(r'^\d{6}$');

  OrderLifecycleCubit(
    this._repository,
    this._location, {
    String Function() newIdempotencyKey = generateUuidV4,
  }) : _newIdempotencyKey = newIdempotencyKey,
       super(const LifecycleIdle());

  Future<void> confirmPickup(CurrentWork work) => _run(
    LifecycleAction.pickup,
    fingerprint: '${work.orderId}',
    send: (String key) => _repository.confirmPickup(
      orderId: work.orderId,
      idempotencyKey: key,
      expectedVersion: _expectedVersion(work),
    ),
  );

  Future<void> startDelivery(CurrentWork work) => _run(
    LifecycleAction.startDelivery,
    fingerprint: '${work.orderId}',
    send: (String key) => _repository.startDelivery(
      orderId: work.orderId,
      idempotencyKey: key,
      expectedVersion: _expectedVersion(work),
    ),
  );

  /// The OTP is the six-digit code the customer shows. Cash is recorded as
  /// collected exactly when the order is cash on delivery.
  Future<void> completeWithOtp(CurrentWork work, String otp) async {
    if (state is LifecycleInProgress) return;
    if (!_otpPattern.hasMatch(otp)) {
      emit(
        LifecycleFailure(
          LifecycleAction.complete,
          Strings.orderOtpIncomplete,
          shouldRefreshWork: false,
        ),
      );
      return;
    }
    await _run(
      LifecycleAction.complete,
      // A corrected OTP is a different command, so it gets a fresh key.
      fingerprint: '${work.orderId}:$otp',
      send: (String key) => _repository.completeWithOtp(
        orderId: work.orderId,
        otp: otp,
        codCollected: work.isCashOnDelivery,
        idempotencyKey: key,
        expectedVersion: _expectedVersion(work),
      ),
    );
  }

  /// Completes with the device's current position and time as proof — the
  /// alternative when the customer can't give the OTP.
  Future<void> completeWithLocation(CurrentWork work) async {
    if (state is LifecycleInProgress) return;
    emit(const LifecycleInProgress(LifecycleAction.complete));

    // A retry after a timeout must resend the exact same proof under the
    // same key; only a fresh attempt takes a new fix.
    final String fingerprint = '${work.orderId}:location';
    final _PendingCommand? pending = _pending[LifecycleAction.complete];
    DeviceLocation? location = pending?.fingerprint == fingerprint
        ? pending?.location
        : null;
    if (location == null) {
      final Either<LocationFailure, DeviceLocation> fix = await _location
          .currentLocation(requestPermission: true);
      if (isClosed) return;
      location = fix.fold((LocationFailure f) {
        emit(
          LifecycleFailure(
            LifecycleAction.complete,
            f.message,
            shouldRefreshWork: false,
          ),
        );
        return null;
      }, (DeviceLocation l) => l);
      if (location == null) return;
    }

    final DeviceLocation proof = location;
    await _send(
      LifecycleAction.complete,
      fingerprint: fingerprint,
      location: proof,
      send: (String key) => _repository.completeWithLocation(
        orderId: work.orderId,
        location: proof,
        codCollected: work.isCashOnDelivery,
        idempotencyKey: key,
        expectedVersion: _expectedVersion(work),
      ),
    );
  }

  Future<void> _run(
    LifecycleAction action, {
    required String fingerprint,
    required Future<Either<Failure, WorkTransition>> Function(String key) send,
  }) async {
    if (state is LifecycleInProgress) return;
    emit(LifecycleInProgress(action));
    await _send(action, fingerprint: fingerprint, send: send);
  }

  /// Picks the idempotency key (reused only for a retry of the identical
  /// command), sends, and emits the outcome.
  Future<void> _send(
    LifecycleAction action, {
    required String fingerprint,
    required Future<Either<Failure, WorkTransition>> Function(String key) send,
    DeviceLocation? location,
  }) async {
    final _PendingCommand? pending = _pending[action];
    final String key = pending != null && pending.fingerprint == fingerprint
        ? pending.key
        : _newIdempotencyKey();
    _pending[action] = _PendingCommand(
      key: key,
      fingerprint: fingerprint,
      location: location,
    );

    final Either<Failure, WorkTransition> result = await send(key);
    if (isClosed) return;

    result.fold(
      (Failure f) {
        // Only a network failure leaves the outcome unknown; keep its key so
        // the retry is a safe replay. Anything else is definitive.
        final bool outcomeUnknown = f is NetworkFailure;
        if (!outcomeUnknown) _pending.remove(action);
        emit(
          LifecycleFailure(
            action,
            f.message ?? Strings.somethingWentWrong,
            shouldRefreshWork: !outcomeUnknown,
          ),
        );
      },
      (WorkTransition transition) {
        _pending.remove(action);
        emit(LifecycleSuccess(action, transition));
      },
    );
  }

  /// `0` means current-work sent no version — skip the optimistic lock
  /// rather than send a value guaranteed to conflict.
  int? _expectedVersion(CurrentWork work) =>
      work.statusVersion > 0 ? work.statusVersion : null;
}

class _PendingCommand {
  final String key;
  final String fingerprint;

  /// The proof sent with a location completion, resent as-is on retry.
  final DeviceLocation? location;

  const _PendingCommand({
    required this.key,
    required this.fingerprint,
    this.location,
  });
}
