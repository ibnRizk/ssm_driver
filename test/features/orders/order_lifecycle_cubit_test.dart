import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/location/device_location.dart';
import 'package:ssm_driver/core/services/location/location_failure.dart';
import 'package:ssm_driver/features/orders/domain/entities/current_work.dart';
import 'package:ssm_driver/features/orders/domain/entities/work_transition.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/order_lifecycle_cubit.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/order_lifecycle_state.dart';

import '../../helpers/fake_location_service.dart';
import '../../helpers/key_localizations.dart';
import 'orders_test_fakes.dart';

void main() {
  useKeyLocalizations();

  late FakeOrdersRepository repository;
  late FakeLocationService location;
  late OrderLifecycleCubit cubit;

  setUp(() {
    repository = FakeOrdersRepository();
    location = FakeLocationService();
    cubit = OrderLifecycleCubit(
      repository,
      location,
      newIdempotencyKey: sequentialKeys(),
    );
  });

  tearDown(() => cubit.close());

  void failNextWith(Failure failure) =>
      repository.transitionResult = Left<Failure, WorkTransition>(failure);

  void succeedNext() => repository.transitionResult =
      const Right<Failure, WorkTransition>(pickedUpTransition);

  test('pickup shows progress, then the confirmed transition', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<OrderLifecycleState>[
        const LifecycleInProgress(LifecycleAction.pickup),
        const LifecycleSuccess(LifecycleAction.pickup, pickedUpTransition),
      ]),
    );

    await cubit.confirmPickup(sampleWork);
    await expectation;
  });

  test('sends the order status version as the optimistic lock', () async {
    await cubit.confirmPickup(sampleWork);

    expect(repository.lastExpectedVersion, 6);
  });

  test('omits the optimistic lock when the version is unknown', () async {
    await cubit.startDelivery(sampleWork.withStatus(WorkStatus.pickedUp, 0));

    expect(repository.lastExpectedVersion, isNull);
  });

  test('a retry after a network failure reuses the idempotency key', () async {
    failNextWith(const NetworkFailure(message: 'timeout'));
    await cubit.confirmPickup(sampleWork);
    succeedNext();

    await cubit.confirmPickup(sampleWork);

    expect(repository.usedKeys, <String>['key-1', 'key-1']);
  });

  test('a network failure does not ask to refresh current work', () async {
    failNextWith(const NetworkFailure(message: 'timeout'));

    await cubit.confirmPickup(sampleWork);

    expect(
      cubit.state,
      const LifecycleFailure(
        LifecycleAction.pickup,
        'timeout',
        shouldRefreshWork: false,
      ),
    );
  });

  test('a 409 conflict asks to refresh and drops the key', () async {
    failNextWith(const ServerFailure(message: 'Assignment conflict.'));
    await cubit.confirmPickup(sampleWork);

    expect(
      cubit.state,
      const LifecycleFailure(
        LifecycleAction.pickup,
        'Assignment conflict.',
        shouldRefreshWork: true,
      ),
    );

    succeedNext();
    await cubit.confirmPickup(sampleWork);
    expect(repository.usedKeys, <String>['key-1', 'key-2']);
  });

  test('each lifecycle action gets its own key', () async {
    await cubit.confirmPickup(sampleWork);
    await cubit.startDelivery(sampleWork);
    await cubit.completeWithOtp(sampleWork, '123456');

    expect(repository.usedKeys, <String>['key-1', 'key-2', 'key-3']);
  });

  test('completes with the OTP and records COD cash as collected', () async {
    await cubit.completeWithOtp(sampleWork, '123456');

    expect(repository.lastOtp, '123456');
    expect(repository.lastCodCollected, isTrue);
  });

  test('a prepaid order completes without collecting cash', () async {
    const CurrentWork prepaid = CurrentWork(
      assignmentId: 3,
      orderId: 100001,
      status: WorkStatus.outForDelivery,
      statusVersion: 8,
      storeName: '',
      storeAddress: '',
      storeLatitude: null,
      storeLongitude: null,
      customerName: '',
      customerPhone: '',
      deliveryAddress: '',
      deliveryLatitude: null,
      deliveryLongitude: null,
      orderNote: null,
      isCashOnDelivery: false,
      codAmount: '0.00',
    );

    await cubit.completeWithOtp(prepaid, '123456');

    expect(repository.lastCodCollected, isFalse);
  });

  test('an incomplete OTP is rejected without calling the API', () async {
    await cubit.completeWithOtp(sampleWork, '1234');

    expect(repository.usedKeys, isEmpty);
    expect(cubit.state, isA<LifecycleFailure>());
  });

  test('a corrected OTP after a timeout is sent with a new key', () async {
    failNextWith(const NetworkFailure(message: 'timeout'));
    await cubit.completeWithOtp(sampleWork, '111111');
    succeedNext();

    await cubit.completeWithOtp(sampleWork, '222222');

    expect(repository.usedKeys, <String>['key-1', 'key-2']);
  });

  test('a second tap while a command is in flight is ignored', () async {
    final Future<void> first = cubit.confirmPickup(sampleWork);
    await cubit.confirmPickup(sampleWork);
    await first;

    expect(repository.usedKeys, hasLength(1));
  });

  group('complete with location proof', () {
    test('sends a fresh device fix, asking for permission', () async {
      await cubit.completeWithLocation(sampleWork);

      expect(repository.sentLocations, <DeviceLocation>[sampleLocation]);
      expect(location.permissionRequests, <bool>[true]);
      expect(repository.lastCodCollected, isTrue);
      expect(
        cubit.state,
        const LifecycleSuccess(LifecycleAction.complete, pickedUpTransition),
      );
    });

    test('no location fails without calling the API', () async {
      location.result = const Left<LocationFailure, DeviceLocation>(
        LocationFailure(LocationIssue.serviceDisabled),
      );

      await cubit.completeWithLocation(sampleWork);

      expect(repository.usedKeys, isEmpty);
      expect(
        cubit.state,
        isA<LifecycleFailure>().having(
          (LifecycleFailure f) => f.shouldRefreshWork,
          'shouldRefreshWork',
          isFalse,
        ),
      );
    });

    test('a retry after a timeout resends the same proof and key', () async {
      failNextWith(const NetworkFailure(message: 'timeout'));
      await cubit.completeWithLocation(sampleWork);
      final DeviceLocation moved = DeviceLocation(
        latitude: 25,
        longitude: 47,
        recordedAt: DateTime.utc(2026, 9, 23, 10),
      );
      location.result = Right<LocationFailure, DeviceLocation>(moved);
      succeedNext();

      await cubit.completeWithLocation(sampleWork);

      expect(repository.usedKeys, <String>['key-1', 'key-1']);
      expect(repository.sentLocations, <DeviceLocation>[
        sampleLocation,
        sampleLocation,
      ]);
      expect(location.calls, 1);
    });

    test('switching from OTP to location proof uses a new key', () async {
      failNextWith(const NetworkFailure(message: 'timeout'));
      await cubit.completeWithOtp(sampleWork, '123456');
      succeedNext();

      await cubit.completeWithLocation(sampleWork);

      expect(repository.usedKeys, <String>['key-1', 'key-2']);
    });
  });
}
