import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/orders/domain/entities/active_offer.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/incoming_order_cubit.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/incoming_order_state.dart';

import '../../helpers/fake_ringtone_service.dart';
import 'orders_test_fakes.dart';

/// [sampleOffer] as shown with [left] of its 25 seconds remaining.
IncomingOrderReady _ready(int left, {OfferAction? inFlight}) =>
    IncomingOrderReady(
      sampleOffer,
      secondsLeft: left,
      totalSeconds: sampleOffer.remainingSeconds,
      inFlight: inFlight,
    );

void main() {
  late FakeOrdersRepository repository;
  late FakeRingtoneService ringtone;

  setUp(() {
    repository = FakeOrdersRepository();
    ringtone = FakeRingtoneService();
  });

  /// Runs [body] on a fake clock: the countdown only moves when the test
  /// calls `async.elapse`, so nothing depends on real time.
  void withCubit(
    void Function(FakeAsync async, IncomingOrderCubit cubit) body,
  ) {
    fakeAsync((FakeAsync async) {
      final DateTime origin = DateTime(2026, 9, 26, 12);
      final IncomingOrderCubit cubit = IncomingOrderCubit(
        repository,
        ringtone,
        newIdempotencyKey: sequentialKeys(),
        now: () => origin.add(async.elapsed),
      );
      body(async, cubit);
      cubit.close();
      async.flushMicrotasks();
    });
  }

  group('countdown and ringtone', () {
    test('starting shows the offer with its full countdown', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);

        expect(cubit.state, _ready(25));
        expect(repository.activeOfferCalls, 0);
      });
    });

    test('starting rings', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);

        expect(ringtone.isRinging, isTrue);
        expect(ringtone.playCalls, 1);
      });
    });

    test('the countdown drops by one each second', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);

        async.elapse(const Duration(seconds: 3));

        expect(cubit.state, _ready(22));
      });
    });

    test('progress runs from 1 towards 0', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);
        async.elapse(const Duration(seconds: 5));

        expect((cubit.state as IncomingOrderOffered).progress, 20 / 25);
      });
    });

    test('reaching zero expires the offer', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);

        async.elapse(const Duration(seconds: 25));

        expect(cubit.state, const IncomingOrderExpired());
      });
    });

    test('reaching zero stops the ringtone', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);

        async.elapse(const Duration(seconds: 25));

        expect(ringtone.isRinging, isFalse);
      });
    });

    test('nothing ticks after the offer expired', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);
        async.elapse(const Duration(seconds: 25));
        final List<IncomingOrderState> later = <IncomingOrderState>[];
        cubit.stream.listen(later.add);

        async.elapse(const Duration(seconds: 5));

        expect(later, isEmpty);
        expect(async.periodicTimerCount, 0);
      });
    });

    test('an offer that arrives already expired ends without ringing', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        const ActiveOffer expired = ActiveOffer(
          assignmentId: 501,
          orderId: 9001,
          remainingSeconds: 0,
          distanceMeters: 840,
          pickupName: 'Store name',
          pickupAddress: 'Store address',
          deliveryAddress: 'Delivery address',
          isCashOnDelivery: true,
          codAmount: '125.00',
        );

        cubit.start(expired);

        expect(cubit.state, const IncomingOrderExpired());
        expect(ringtone.playCalls, 0);
      });
    });

    test('closing stops the ringtone and the countdown', () {
      fakeAsync((FakeAsync async) {
        final IncomingOrderCubit cubit = IncomingOrderCubit(
          repository,
          ringtone,
        )..start(sampleOffer);

        cubit.close();
        async.flushMicrotasks();

        expect(ringtone.isRinging, isFalse);
        expect(async.periodicTimerCount, 0);
      });
    });
  });

  group('answering', () {
    test('tapping accept stops the ringtone before the server answers', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);

        cubit.accept();

        expect(cubit.state, _ready(25, inFlight: OfferAction.accept));
        expect(ringtone.isRinging, isFalse);
      });
    });

    test('tapping reject stops the ringtone before the server answers', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);

        cubit.reject();

        expect(ringtone.isRinging, isFalse);
      });
    });

    test('a successful accept ends in accepted', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);

        cubit.accept();
        async.flushMicrotasks();

        expect(cubit.state, const IncomingOrderAccepted());
        expect(async.periodicTimerCount, 0);
      });
    });

    test('a successful reject ends in rejected', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);

        cubit.reject();
        async.flushMicrotasks();

        expect(cubit.state, const IncomingOrderRejected());
      });
    });

    test('a network failure keeps the offer counting down with the error', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);
        repository.offerCommandResult = const Left<Failure, Unit>(
          NetworkFailure(message: 'timeout'),
        );
        cubit.accept();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 2));

        expect(
          cubit.state,
          const IncomingOrderActionFailed(
            sampleOffer,
            'timeout',
            secondsLeft: 23,
            totalSeconds: 25,
          ),
        );
        expect(repository.activeOfferCalls, 0);
      });
    });

    test('a retry after a network failure reuses the idempotency key', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);
        repository.offerCommandResult = const Left<Failure, Unit>(
          NetworkFailure(message: 'timeout'),
        );
        cubit.accept();
        async.flushMicrotasks();
        repository.offerCommandResult = const Right<Failure, Unit>(unit);

        cubit.accept();
        async.flushMicrotasks();

        expect(repository.usedKeys, <String>['key-1', 'key-1']);
        expect(cubit.state, const IncomingOrderAccepted());
      });
    });

    test('a failed answer does not start the ringtone again', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);
        repository.offerCommandResult = const Left<Failure, Unit>(
          ServerFailure(message: 'Assignment conflict.'),
        );

        // The re-read finds the same offer still waiting.
        cubit.accept();
        async.flushMicrotasks();

        expect(cubit.state, isA<IncomingOrderReady>());
        expect(ringtone.playCalls, 1);
        expect(ringtone.isRinging, isFalse);
      });
    });

    test('a 409 conflict re-reads the offer and closes it when gone', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);
        repository.offerCommandResult = const Left<Failure, Unit>(
          ServerFailure(message: 'Assignment conflict.'),
        );
        repository.offerResult = const Right<Failure, ActiveOffer?>(null);
        final List<IncomingOrderState> states = <IncomingOrderState>[];
        cubit.stream.listen(states.add);

        cubit.accept();
        async.flushMicrotasks();

        expect(states, <IncomingOrderState>[
          _ready(25, inFlight: OfferAction.accept),
          const IncomingOrderActionFailed(
            sampleOffer,
            'Assignment conflict.',
            secondsLeft: 25,
            totalSeconds: 25,
          ),
          const IncomingOrderUnavailable(),
        ]);
      });
    });

    test('a failed re-read ends in a load error', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);
        repository.offerCommandResult = const Left<Failure, Unit>(
          ServerFailure(message: 'Assignment conflict.'),
        );
        repository.offerResult = const Left<Failure, ActiveOffer?>(
          NetworkFailure(message: 'offline'),
        );

        cubit.accept();
        async.flushMicrotasks();

        expect(cubit.state, const IncomingOrderLoadError('offline'));
      });
    });

    test('a definitive failure drops the key for the next attempt', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);
        repository.offerCommandResult = const Left<Failure, Unit>(
          ServerFailure(message: 'Validation failed.'),
        );
        cubit.accept();
        async.flushMicrotasks();
        repository.offerCommandResult = const Right<Failure, Unit>(unit);

        cubit.accept();
        async.flushMicrotasks();

        expect(repository.usedKeys, <String>['key-1', 'key-2']);
      });
    });

    test('a second tap while a command is in flight is ignored', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);

        cubit.accept();
        cubit.reject();
        async.flushMicrotasks();

        expect(repository.usedKeys, hasLength(1));
      });
    });

    test('an answer is ignored once the offer expired', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        cubit.start(sampleOffer);
        async.elapse(const Duration(seconds: 25));

        cubit.accept();
        async.flushMicrotasks();

        expect(repository.usedKeys, isEmpty);
        expect(cubit.state, const IncomingOrderExpired());
      });
    });
  });

  group('answer in flight when time runs out', () {
    test('the countdown waits for the answer instead of expiring', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        repository.commandGate = Completer<void>();
        cubit.start(sampleOffer);
        cubit.accept();

        async.elapse(const Duration(seconds: 25));

        expect(cubit.state, _ready(0, inFlight: OfferAction.accept));
      });
    });

    test('an accept that lands after zero still ends in accepted', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        final Completer<void> gate = Completer<void>();
        repository.commandGate = gate;
        cubit.start(sampleOffer);
        cubit.accept();
        async.elapse(const Duration(seconds: 25));

        gate.complete();
        async.flushMicrotasks();

        expect(cubit.state, const IncomingOrderAccepted());
      });
    });

    test('a network failure after zero ends in expired', () {
      withCubit((FakeAsync async, IncomingOrderCubit cubit) {
        final Completer<void> gate = Completer<void>();
        repository.commandGate = gate;
        repository.offerCommandResult = const Left<Failure, Unit>(
          NetworkFailure(message: 'timeout'),
        );
        cubit.start(sampleOffer);
        cubit.accept();
        async.elapse(const Duration(seconds: 25));

        gate.complete();
        async.flushMicrotasks();

        expect(cubit.state, const IncomingOrderExpired());
      });
    });
  });
}
