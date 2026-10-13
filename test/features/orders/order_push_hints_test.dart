import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/services/push/push_hint.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/current_work_cubit.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/offer_polling_cubit.dart';

import '../../helpers/fake_push_service.dart';
import 'orders_test_fakes.dart';

void main() {
  late FakeOrdersRepository repository;
  late FakePushService push;

  setUp(() {
    repository = FakeOrdersRepository();
    push = FakePushService();
  });

  group('OfferPollingCubit', () {
    late OfferPollingCubit cubit;

    setUp(() {
      // A long interval: only start() and pushes trigger checks.
      cubit = OfferPollingCubit(
        repository,
        interval: const Duration(hours: 1),
        pushHints: push.hints,
      );
    });

    tearDown(() => cubit.close());

    test('an offer push checks right away while online', () async {
      cubit.start();
      await pumpEventQueue();

      push.emit(const PushHint(PushTarget.offer));
      await pumpEventQueue();

      expect(repository.activeOfferCalls, 2);
    });

    test('an offer push does nothing while offline', () async {
      push.emit(const PushHint(PushTarget.offer));
      await pumpEventQueue();

      expect(repository.activeOfferCalls, 0);
    });

    test('a parcel push does not check for offers', () async {
      cubit.start();
      await pumpEventQueue();

      push.emit(const PushHint(PushTarget.parcel));
      await pumpEventQueue();

      expect(repository.activeOfferCalls, 1);
    });

    test('an unknown push checks for offers', () async {
      cubit.start();
      await pumpEventQueue();

      push.emit(const PushHint(PushTarget.unknown));
      await pumpEventQueue();

      expect(repository.activeOfferCalls, 2);
    });
  });

  group('CurrentWorkCubit', () {
    late CurrentWorkCubit cubit;

    setUp(() {
      cubit = CurrentWorkCubit(repository, pushHints: push.hints);
    });

    tearDown(() => cubit.close());

    test('an order push re-reads a loaded order', () async {
      await cubit.loadCurrentWork();

      push.emit(const PushHint(PushTarget.order, id: 9001));
      await pumpEventQueue();

      expect(repository.currentWorkCalls, 2);
    });

    test('an order push is ignored before the first load', () async {
      push.emit(const PushHint(PushTarget.order));
      await pumpEventQueue();

      expect(repository.currentWorkCalls, 0);
    });

    test('an offer push does not re-read the order', () async {
      await cubit.loadCurrentWork();

      push.emit(const PushHint(PushTarget.offer));
      await pumpEventQueue();

      expect(repository.currentWorkCalls, 1);
    });
  });
}
