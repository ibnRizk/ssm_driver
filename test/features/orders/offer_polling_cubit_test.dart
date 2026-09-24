import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/orders/domain/entities/active_offer.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/offer_polling_cubit.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/offer_polling_state.dart';

import 'orders_test_fakes.dart';

const ActiveOffer _nextOffer = ActiveOffer(
  assignmentId: 502,
  orderId: 9002,
  remainingSeconds: 30,
  distanceMeters: 1200,
  pickupName: 'Other store',
  pickupAddress: '',
  deliveryAddress: '',
  isCashOnDelivery: false,
  codAmount: '0.00',
);

void main() {
  late FakeOrdersRepository repository;
  late OfferPollingCubit cubit;

  setUp(() {
    repository = FakeOrdersRepository();
    // Only the immediate check on start() runs; later ticks are driven by
    // calling checkNow() so the tests never depend on real time.
    cubit = OfferPollingCubit(repository, interval: const Duration(hours: 1));
  });

  tearDown(() => cubit.close());

  test('starting checks for an offer right away', () async {
    cubit.start();
    await pumpEventQueue();

    expect(cubit.state, const OfferPollingFound(sampleOffer));
  });

  test('the same offer is announced only once', () async {
    cubit.start();
    await pumpEventQueue();
    final List<OfferPollingState> later = <OfferPollingState>[];
    cubit.stream.listen(later.add);

    await cubit.checkNow();
    await pumpEventQueue();

    expect(later, isEmpty);
  });

  test('a different offer is announced', () async {
    cubit.start();
    await pumpEventQueue();
    repository.offerResult = const Right<Failure, ActiveOffer?>(_nextOffer);

    await cubit.checkNow();

    expect(cubit.state, const OfferPollingFound(_nextOffer));
  });

  test('no offer returns to idle', () async {
    cubit.start();
    await pumpEventQueue();
    repository.offerResult = const Right<Failure, ActiveOffer?>(null);

    await cubit.checkNow();

    expect(cubit.state, const OfferPollingIdle());
  });

  test('a failed poll keeps the last state', () async {
    cubit.start();
    await pumpEventQueue();
    repository.offerResult = const Left<Failure, ActiveOffer?>(
      NetworkFailure(message: 'offline'),
    );

    await cubit.checkNow();

    expect(cubit.state, const OfferPollingFound(sampleOffer));
  });

  test('nothing is checked while stopped', () async {
    await cubit.checkNow();

    expect(repository.activeOfferCalls, 0);
    expect(cubit.state, const OfferPollingIdle());
  });

  test('an answer arriving after stop is ignored', () async {
    cubit.start();
    cubit.stop();
    await pumpEventQueue();

    expect(cubit.state, const OfferPollingIdle());
  });
}
