import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/orders/domain/entities/active_offer.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/incoming_order_cubit.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/incoming_order_state.dart';

import 'orders_test_fakes.dart';

void main() {
  late FakeOrdersRepository repository;
  late IncomingOrderCubit cubit;

  setUp(() {
    repository = FakeOrdersRepository();
    cubit = IncomingOrderCubit(repository, newIdempotencyKey: sequentialKeys());
  });

  tearDown(() => cubit.close());

  test('an offer handed over by polling shows without a fetch', () async {
    await cubit.start(sampleOffer);

    expect(cubit.state, const IncomingOrderReady(sampleOffer));
    expect(repository.activeOfferCalls, 0);
  });

  test('opened without an offer, it reads the active offer', () async {
    await cubit.start();

    expect(cubit.state, const IncomingOrderReady(sampleOffer));
  });

  test('no offer waiting emits unavailable', () async {
    repository.offerResult = const Right<Failure, ActiveOffer?>(null);

    await cubit.start();

    expect(cubit.state, const IncomingOrderUnavailable());
  });

  test('accepting shows progress, then accepted', () async {
    await cubit.start(sampleOffer);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<IncomingOrderState>[
        const IncomingOrderReady(sampleOffer, inFlight: OfferAction.accept),
        const IncomingOrderAccepted(),
      ]),
    );

    await cubit.accept();
    await expectation;
  });

  test('rejecting ends in rejected', () async {
    await cubit.start(sampleOffer);

    await cubit.reject();

    expect(cubit.state, const IncomingOrderRejected());
  });

  test('a retry after a network failure reuses the idempotency key', () async {
    await cubit.start(sampleOffer);
    repository.offerCommandResult = const Left<Failure, Unit>(
      NetworkFailure(message: 'timeout'),
    );
    await cubit.accept();
    repository.offerCommandResult = const Right<Failure, Unit>(unit);

    await cubit.accept();

    expect(repository.usedKeys, <String>['key-1', 'key-1']);
    expect(cubit.state, const IncomingOrderAccepted());
  });

  test('a network failure keeps the offer on screen with the error', () async {
    await cubit.start(sampleOffer);
    repository.offerCommandResult = const Left<Failure, Unit>(
      NetworkFailure(message: 'timeout'),
    );

    await cubit.accept();

    expect(
      cubit.state,
      const IncomingOrderActionFailed(sampleOffer, 'timeout'),
    );
    expect(repository.activeOfferCalls, 0);
  });

  test('a 409 conflict re-reads the offer and closes it when gone', () async {
    await cubit.start(sampleOffer);
    repository.offerCommandResult = const Left<Failure, Unit>(
      ServerFailure(message: 'Assignment conflict.'),
    );
    repository.offerResult = const Right<Failure, ActiveOffer?>(null);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<IncomingOrderState>[
        const IncomingOrderReady(sampleOffer, inFlight: OfferAction.accept),
        const IncomingOrderActionFailed(sampleOffer, 'Assignment conflict.'),
        const IncomingOrderUnavailable(),
      ]),
    );

    await cubit.accept();
    await expectation;
  });

  test('a definitive failure drops the key for the next attempt', () async {
    await cubit.start(sampleOffer);
    repository.offerCommandResult = const Left<Failure, Unit>(
      ServerFailure(message: 'Validation failed.'),
    );
    await cubit.accept();
    repository.offerCommandResult = const Right<Failure, Unit>(unit);

    await cubit.accept();

    expect(repository.usedKeys, <String>['key-1', 'key-2']);
  });

  test('a second tap while a command is in flight is ignored', () async {
    await cubit.start(sampleOffer);

    final Future<void> first = cubit.accept();
    await cubit.reject();
    await first;

    expect(repository.usedKeys, hasLength(1));
  });
}
