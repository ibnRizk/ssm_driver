import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/features/c2c_parcels/data/models/c2c_parcel_model.dart';
import 'package:ssm_driver/features/c2c_parcels/domain/entities/c2c_parcel.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_offer_alert_cubit.dart';

import '../../helpers/c2c_fixtures.dart';
import '../../helpers/fake_ringtone_service.dart';

final DateTime _start = DateTime.utc(2026, 10, 20, 9);

C2cParcel _offer({DateTime? expiresAt}) => C2cParcelModel.fromJson(
  <String, dynamic>{
    ...c2cItemJson(status: 'driver_assigned'),
    if (expiresAt != null) 'expires_at': expiresAt.toIso8601String(),
  },
  coarse: true,
);

void main() {
  late FakeRingtoneService ringtone;

  setUp(() => ringtone = FakeRingtoneService());

  /// A cubit whose clock follows [async]'s fake time.
  C2cOfferAlertCubit cubitIn(FakeAsync async) =>
      C2cOfferAlertCubit(ringtone, now: () => _start.add(async.elapsed));

  test('starting rings', () {
    fakeAsync((FakeAsync async) {
      final C2cOfferAlertCubit cubit = cubitIn(async)..start(_offer());
      async.flushMicrotasks();

      expect(ringtone.isRinging, isTrue);
      expect(cubit.state, C2cOfferAlertState.ringing);
      cubit.close();
    });
  });

  test('silencing stops the ringtone', () {
    fakeAsync((FakeAsync async) {
      final C2cOfferAlertCubit cubit = cubitIn(async)..start(_offer());

      cubit.silence();
      async.flushMicrotasks();

      expect(ringtone.isRinging, isFalse);
      expect(cubit.state, C2cOfferAlertState.silenced);
      cubit.close();
    });
  });

  test('the offer expiring stops the ringtone and ends the alert', () {
    fakeAsync((FakeAsync async) {
      final C2cOfferAlertCubit cubit = cubitIn(async)
        ..start(_offer(expiresAt: _start.add(const Duration(seconds: 30))));

      async.elapse(const Duration(seconds: 30));

      expect(ringtone.isRinging, isFalse);
      expect(cubit.state, C2cOfferAlertState.expired);
      cubit.close();
    });
  });

  test('an offer already past its expiry never rings', () {
    fakeAsync((FakeAsync async) {
      final C2cOfferAlertCubit cubit = cubitIn(async)
        ..start(_offer(expiresAt: _start.subtract(const Duration(seconds: 1))));
      async.flushMicrotasks();

      expect(ringtone.playCalls, 0);
      expect(cubit.state, C2cOfferAlertState.expired);
      cubit.close();
    });
  });

  test('a silenced offer is not expired later', () {
    fakeAsync((FakeAsync async) {
      final C2cOfferAlertCubit cubit = cubitIn(async)
        ..start(_offer(expiresAt: _start.add(const Duration(seconds: 30))))
        ..silence();

      async.elapse(const Duration(seconds: 31));

      expect(cubit.state, C2cOfferAlertState.silenced);
      cubit.close();
    });
  });

  test('closing stops the ringtone', () {
    fakeAsync((FakeAsync async) {
      final C2cOfferAlertCubit cubit = cubitIn(async)..start(_offer());

      cubit.close();
      async.flushMicrotasks();

      expect(ringtone.isRinging, isFalse);
    });
  });
}
