import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/location/device_location.dart';
import 'package:ssm_driver/core/services/location/location_failure.dart';
import 'package:ssm_driver/core/services/push/push_hint.dart';
import 'package:ssm_driver/features/c2c_parcels/domain/entities/c2c_parcel.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_action_cubit.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_action_state.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_board_cubit.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_board_state.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_job_cubit.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_job_state.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_location_cubit.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_offer_watch_cubit.dart';

import '../../helpers/fake_location_service.dart';
import '../../helpers/fake_push_service.dart';
import '../../helpers/key_localizations.dart';
import 'c2c_test_fakes.dart';

void main() {
  useKeyLocalizations();

  late FakeC2cRepository repository;
  late FakePushService push;

  setUp(() {
    repository = FakeC2cRepository();
    push = FakePushService();
  });

  group('entity', () {
    test('primary action follows next_actions first', () {
      expect(
        c2cJob(status: 'driver_accepted', nextActions: <String>['pickup'])
            .primaryAction,
        C2cAction.pickup,
      );
    });

    test('without next_actions the lifecycle decides each step', () {
      C2cAction? next(String status) =>
          c2cJob(status: status, nextActions: <String>[]).primaryAction;

      expect(next('driver_assigned'), C2cAction.accept);
      expect(next('driver_accepted'), C2cAction.arrivePickup);
      expect(next('driver_at_pickup'), C2cAction.pickup);
      expect(next('picked_up'), C2cAction.outForDelivery);
      expect(next('out_for_delivery'), C2cAction.complete);
      expect(next('delivered'), isNull);
    });

    test('a terminal parcel offers no action', () {
      expect(
        c2cJob(status: 'cancelled', nextActions: <String>[], isTerminal: true)
            .primaryAction,
        isNull,
      );
    });

    test('only accepted, unfinished jobs need location pings', () {
      expect(c2cJob(status: 'driver_assigned').isActiveWork, isFalse);
      expect(c2cJob(status: 'driver_accepted').isActiveWork, isTrue);
      expect(c2cJob(status: 'out_for_delivery').isActiveWork, isTrue);
      expect(c2cJob(status: 'delivered', isTerminal: true).isActiveWork, isFalse);
    });
  });

  group('C2cActionCubit', () {
    late C2cActionCubit cubit;
    int keys = 0;

    setUp(() {
      keys = 0;
      cubit = C2cActionCubit(repository, newIdempotencyKey: () => 'key-${++keys}');
    });

    tearDown(() => cubit.close());

    test('a step is sent with a fresh key and reports the answer', () async {
      final C2cParcel updated = c2cJob(status: 'picked_up');
      repository.actionResult = Right<Failure, C2cParcel?>(updated);

      await cubit.run(c2cJob(status: 'driver_at_pickup'), C2cAction.pickup);

      expect(repository.actions.single.action, C2cAction.pickup);
      expect(repository.actions.single.key, 'key-1');
      expect(cubit.state, C2cActionSuccess(C2cAction.pickup, 1, updated));
    });

    test('completion without the required OTP sends nothing', () async {
      await cubit.run(c2cJob(), C2cAction.complete, otp: '12');

      expect(repository.actions, isEmpty);
      expect(cubit.state, isA<C2cActionFailure>());
    });

    test('completion sends the recipient OTP', () async {
      await cubit.run(c2cJob(), C2cAction.complete, otp: '123456');

      expect(repository.actions.single.otp, '123456');
    });

    test('completion without an OTP requirement sends none', () async {
      await cubit.run(c2cJob(requiresOtp: false), C2cAction.complete, otp: '999999');

      expect(repository.actions.single.otp, isNull);
    });

    test('a retry after a network failure replays the same key', () async {
      repository.actionResult = const Left<Failure, C2cParcel?>(
        NetworkFailure(message: 'timeout'),
      );
      await cubit.run(c2cJob(status: 'picked_up'), C2cAction.outForDelivery);
      repository.actionResult = const Right<Failure, C2cParcel?>(null);

      await cubit.run(c2cJob(status: 'picked_up'), C2cAction.outForDelivery);

      expect(repository.actions.map((a) => a.key), <String>['key-1', 'key-1']);
    });

    test('after a definitive rejection the next attempt gets a new key', () async {
      repository.actionResult = const Left<Failure, C2cParcel?>(
        ServerFailure(message: 'Offer expired.'),
      );
      await cubit.run(c2cOffer(5), C2cAction.accept);

      expect(
        cubit.state,
        const C2cActionFailure(
          C2cAction.accept,
          'Offer expired.',
          shouldRefresh: true,
        ),
      );
      await cubit.run(c2cOffer(5), C2cAction.accept);
      expect(repository.actions.map((a) => a.key), <String>['key-1', 'key-2']);
    });

    test('a corrected OTP is a new command with a new key', () async {
      repository.actionResult = const Left<Failure, C2cParcel?>(
        NetworkFailure(message: 'timeout'),
      );
      await cubit.run(c2cJob(), C2cAction.complete, otp: '000000');

      await cubit.run(c2cJob(), C2cAction.complete, otp: '123456');

      expect(repository.actions.map((a) => a.key), <String>['key-1', 'key-2']);
    });
  });

  group('C2cBoardCubit', () {
    late C2cBoardCubit cubit;

    setUp(() => cubit = C2cBoardCubit(repository, pushHints: push.hints));

    tearDown(() => cubit.close());

    test('loads offers and jobs, dropping offers already accepted', () async {
      repository.offersResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[
        c2cOffer(1),
        c2cOffer(2),
      ]);
      repository.jobsResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[
        c2cJob(id: 2, status: 'driver_accepted'),
      ]);

      await cubit.load();

      final C2cBoardLoaded state = cubit.state as C2cBoardLoaded;
      expect(state.offers.map((C2cParcel o) => o.id), <int>[1]);
      expect(state.jobs.single.id, 2);
    });

    test('either read failing shows the error', () async {
      repository.jobsResult = const Left<Failure, List<C2cParcel>>(
        NetworkFailure(message: 'offline'),
      );

      await cubit.load();

      expect(cubit.state, const C2cBoardError('offline'));
    });

    test('a C2C push re-reads the board; a warehouse push does not', () async {
      await cubit.load();

      push.emit(const PushHint(PushTarget.parcel));
      await pumpEventQueue();
      expect(repository.offerReads, 1);

      push.emit(const PushHint(PushTarget.c2cParcel));
      await pumpEventQueue();
      expect(repository.offerReads, 2);
    });
  });

  group('C2cJobCubit', () {
    late C2cJobCubit cubit;

    setUp(() => cubit = C2cJobCubit(repository, pushHints: push.hints));

    tearDown(() => cubit.close());

    test('finds the job among the active jobs', () async {
      final C2cParcel job = c2cJob(id: 4, status: 'picked_up');
      repository.jobsResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[job]);

      await cubit.load(4);

      expect(cubit.state, C2cJobLoaded(job));
    });

    test('a job no longer active has ended', () async {
      final C2cParcel job = c2cJob(id: 4);
      await cubit.load(4, initial: job);

      expect(cubit.state, C2cJobEnded(job));
    });

    test('a delivered answer ends the job', () {
      final C2cParcel delivered = c2cJob(status: 'delivered', isTerminal: true);

      cubit.applyParcel(delivered);

      expect(cubit.state, C2cJobEnded(delivered));
    });

    test('a push about another C2C parcel is ignored', () async {
      repository.jobsResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[
        c2cJob(id: 4),
      ]);
      await cubit.load(4);

      push.emit(const PushHint(PushTarget.c2cParcel, id: 9));
      await pumpEventQueue();

      expect(repository.jobReads, 1);
    });
  });

  group('C2cLocationCubit', () {
    late FakeLocationService location;
    late C2cLocationCubit cubit;

    setUp(() {
      location = FakeLocationService();
      cubit = C2cLocationCubit(repository, location, pushHints: push.hints);
    });

    tearDown(() => cubit.close());

    test('pings every active job with the current fix', () async {
      repository.jobsResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[
        c2cJob(id: 1, status: 'driver_accepted'),
        c2cJob(id: 2, status: 'out_for_delivery'),
      ]);

      await cubit.reportNow();

      expect(repository.pings.map((p) => p.id), <int>[1, 2]);
      expect(repository.pings.first.location, sampleLocation);
      expect(cubit.state, 2);
    });

    test('never asks for the location permission', () async {
      repository.jobsResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[
        c2cJob(status: 'picked_up'),
      ]);

      await cubit.reportNow();

      expect(location.permissionRequests, <bool>[false]);
    });

    test('without active jobs nothing is located or sent', () async {
      await cubit.reportNow();

      expect(location.permissionRequests, isEmpty);
      expect(repository.pings, isEmpty);
    });

    test('without a fix the round is skipped', () async {
      repository.jobsResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[
        c2cJob(status: 'picked_up'),
      ]);
      location.result = const Left<LocationFailure, DeviceLocation>(
        LocationFailure(LocationIssue.unavailable),
      );

      await cubit.reportNow();

      expect(repository.pings, isEmpty);
    });

    test('jobs are re-read on a C2C push', () async {
      await cubit.reportNow();
      repository.jobsResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[
        c2cJob(id: 8, status: 'driver_accepted'),
      ]);

      push.emit(const PushHint(PushTarget.c2cParcel));
      await pumpEventQueue();

      expect(repository.pings.single.id, 8);
    });
  });

  group('C2cOfferWatchCubit', () {
    late C2cOfferWatchCubit cubit;

    setUp(() => cubit = C2cOfferWatchCubit(repository, arrivals: push.received));

    tearDown(() => cubit.close());

    test('offers waiting at start are not announced', () async {
      repository.offersResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[
        c2cOffer(1),
      ]);
      await cubit.start();

      push.receive(const PushHint(PushTarget.c2cParcel));
      await pumpEventQueue();

      expect(cubit.state, const C2cOfferWatchIdle());
    });

    test('a new offer after a C2C push is announced once', () async {
      await cubit.start();
      final C2cParcel offer = c2cOffer(3);
      repository.offersResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[offer]);

      push.receive(const PushHint(PushTarget.c2cParcel, id: 3));
      await pumpEventQueue();
      expect(cubit.state, C2cOfferWatchFound(<C2cParcel>[offer]));

      final List<C2cOfferWatchState> later = <C2cOfferWatchState>[];
      final sub = cubit.stream.listen(later.add);
      await cubit.check();
      expect(later, isEmpty);
      await sub.cancel();
    });

    test('a warehouse parcel push does not read C2C offers', () async {
      await cubit.start();

      push.receive(const PushHint(PushTarget.parcel));
      await pumpEventQueue();

      expect(repository.offerReads, 1);
    });
  });
}
