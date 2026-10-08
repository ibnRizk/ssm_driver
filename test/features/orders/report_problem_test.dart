import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:ssm_driver/features/orders/data/models/problem_report_model.dart';
import 'package:ssm_driver/features/orders/domain/entities/current_work.dart';
import 'package:ssm_driver/features/orders/domain/entities/problem_report.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/report_problem_cubit.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/report_problem_state.dart';

import 'orders_test_fakes.dart';

void main() {
  group('models', () {
    test('parse the reasons array, skipping unusable entries', () {
      final reasons = ProblemReasonModel.listFromJson(<dynamic>[
        <String, dynamic>{'code': 'store_closed', 'label': 'المتجر مغلق'},
        <String, dynamic>{'code': 'other'},
        'junk',
      ]);

      expect(reasons, const <ProblemReasonModel>[
        ProblemReasonModel(code: 'store_closed', label: 'المتجر مغلق'),
      ]);
    });

    test('a non-list reasons body is a server error', () {
      expect(
        () => ProblemReasonModel.listFromJson(<String, dynamic>{}),
        throwsA(isA<ServerException>()),
      );
    });

    test('parse the documented report response', () {
      final report = ProblemReportModel.fromJson(<String, dynamic>{
        'report_id': 12,
        'next_action': 'continue_order',
        'idempotent_replay': true,
      });

      expect(
        report,
        const ProblemReportModel(
          reportId: 12,
          nextAction: 'continue_order',
          isReplay: true,
        ),
      );
    });
  });

  group('data source', () {
    test('report sends the reason, note and Idempotency-Key', () async {
      final consumer = FakeDioConsumer(<String, dynamic>{
        'report_id': 12,
        'next_action': 'continue_order',
        'idempotent_replay': false,
      });
      final source = OrdersRemoteDataSource(consumer);

      await source.reportProblem(
        orderId: 14,
        reasonCode: 'store_closed',
        note: 'closed',
        idempotencyKey: 'key-r',
      );

      expect(consumer.lastPath, '/delivery-man/orders/14/report-problem');
      expect(consumer.lastHeaders, <String, dynamic>{
        'Idempotency-Key': 'key-r',
      });
      expect(consumer.lastBody, <String, dynamic>{
        'reason_code': 'store_closed',
        'note': 'closed',
      });
    });

    test('an empty note is left out of the body', () async {
      final consumer = FakeDioConsumer(<String, dynamic>{'report_id': 1});
      final source = OrdersRemoteDataSource(consumer);

      await source.reportProblem(
        orderId: 14,
        reasonCode: 'other',
        note: '',
        idempotencyKey: 'k',
      );

      expect(consumer.lastBody, <String, dynamic>{'reason_code': 'other'});
    });
  });

  group('giving an order up', () {
    test('before pickup releases it with the reason and key', () async {
      final consumer = FakeDioConsumer(<String, dynamic>{});
      final source = OrdersRemoteDataSource(consumer);

      await source.giveUpOrder(
        orderId: 14,
        pickedUp: false,
        reasonCode: 'store_closed',
        note: 'shutters down',
        expectedVersion: 6,
        idempotencyKey: 'key-g',
      );

      expect(consumer.lastPath, '/delivery-man/orders/14/release');
      expect(consumer.lastHeaders, <String, dynamic>{
        'Idempotency-Key': 'key-g',
      });
      expect(consumer.lastBody, <String, dynamic>{
        'reason_code': 'store_closed',
        'note': 'shutters down',
        'expected_version': 6,
      });
    });

    test('after pickup fails the delivery', () async {
      final consumer = FakeDioConsumer(<String, dynamic>{});

      await OrdersRemoteDataSource(consumer).giveUpOrder(
        orderId: 14,
        pickedUp: true,
        reasonCode: 'customer_unreachable',
        idempotencyKey: 'k',
      );

      expect(consumer.lastPath, '/delivery-man/orders/14/fail-delivery');
      expect(consumer.lastBody, <String, dynamic>{
        'reason_code': 'customer_unreachable',
      });
    });
  });

  group('cubit', () {
    late FakeOrdersRepository repository;
    late ReportProblemCubit cubit;

    setUp(() {
      repository = FakeOrdersRepository();
      cubit = ReportProblemCubit(
        repository,
        newIdempotencyKey: sequentialKeys(),
      );
    });

    tearDown(() => cubit.close());

    const String validNote = 'customer not answering';

    Future<void> readyWithReason() async {
      await cubit.loadReasons();
      cubit.select(storeClosed);
    }

    test('loads the reasons', () async {
      await cubit.loadReasons();

      expect(
        cubit.state,
        const ReportProblemReady(reasons: <ProblemReason>[storeClosed]),
      );
    });

    test('no reasons is its own state', () async {
      repository.reasonsResult = const Right<Failure, List<ProblemReason>>(
        <ProblemReason>[],
      );

      await cubit.loadReasons();

      expect(cubit.state, const ReportProblemNoReasons());
    });

    test('submits without a reason do nothing', () async {
      await cubit.loadReasons();

      await cubit.submit(orderId: 14);

      expect(repository.usedKeys, isEmpty);
    });

    test('a successful submit emits the report', () async {
      await readyWithReason();

      await cubit.submit(orderId: 14, note: 'note');

      expect(cubit.state, const ReportProblemSent(sampleReport));
      expect(repository.lastReasonCode, 'store_closed');
      expect(repository.lastNote, 'note');
    });

    test('retrying after a network failure reuses the key', () async {
      await readyWithReason();
      repository.reportResult = const Left<Failure, ProblemReport>(
        NetworkFailure(message: 'offline'),
      );
      await cubit.submit(orderId: 14, note: 'note');

      repository.reportResult = const Right<Failure, ProblemReport>(
        sampleReport,
      );
      await cubit.submit(orderId: 14, note: 'note');

      expect(repository.usedKeys, <String>['key-1', 'key-1']);
    });

    test('a definitive failure makes the next submit a new report', () async {
      await readyWithReason();
      repository.reportResult = const Left<Failure, ProblemReport>(
        ServerFailure(message: 'order not active'),
      );
      await cubit.submit(orderId: 14, note: 'note');
      await cubit.submit(orderId: 14, note: 'note');

      expect(repository.usedKeys, <String>['key-1', 'key-2']);
      expect(
        (cubit.state as ReportProblemReady).submitError,
        'order not active',
      );
    });

    test('a different reason after a network failure gets a new key', () async {
      await readyWithReason();
      repository.reportResult = const Left<Failure, ProblemReport>(
        NetworkFailure(message: 'offline'),
      );
      await cubit.submit(orderId: 14, note: 'note');

      cubit.select(const ProblemReason(code: 'other', label: 'Other'));
      await cubit.submit(orderId: 14, note: 'note');

      expect(repository.usedKeys, <String>['key-1', 'key-2']);
    });

    test('the note is trimmed, and a blank one is left out', () async {
      await readyWithReason();

      await cubit.submit(orderId: 14, note: '   ');

      expect(repository.lastNote, isNull);
    });

    test('giving up before pickup releases the order', () async {
      await readyWithReason();

      await cubit.giveUp(work: sampleWork, note: ' store is closed ');

      expect(cubit.state, const ReportProblemGaveUp(pickedUp: false));
      expect(repository.lastGiveUpPickedUp, isFalse);
      expect(repository.lastReasonCode, 'store_closed');
      expect(repository.lastNote, 'store is closed');
      expect(repository.lastExpectedVersion, 6);
    });

    test('giving up after pickup fails the delivery', () async {
      await readyWithReason();

      await cubit.giveUp(
        work: sampleWork.withStatus(WorkStatus.outForDelivery, 8),
        note: validNote,
      );

      expect(cubit.state, const ReportProblemGaveUp(pickedUp: true));
      expect(repository.lastGiveUpPickedUp, isTrue);
    });

    test('giving up without a note is refused unsent', () async {
      await readyWithReason();

      await cubit.giveUp(work: sampleWork);

      expect(repository.usedKeys, isEmpty);
      expect((cubit.state as ReportProblemReady).noteTooShort, isTrue);
    });

    test('a note shorter than the minimum is refused unsent', () async {
      await readyWithReason();

      await cubit.giveUp(
        work: sampleWork,
        note: 'a' * (giveUpNoteMinLength - 1),
      );

      expect(repository.usedKeys, isEmpty);
    });

    test('padding does not count towards the minimum note length', () async {
      await readyWithReason();

      await cubit.giveUp(work: sampleWork, note: '   too short    ');

      expect(repository.usedKeys, isEmpty);
    });

    test('a note of exactly the minimum length is sent', () async {
      await readyWithReason();

      await cubit.giveUp(work: sampleWork, note: 'a' * giveUpNoteMinLength);

      expect(cubit.state, const ReportProblemGaveUp(pickedUp: false));
    });

    test('a report needs no note', () async {
      await readyWithReason();

      await cubit.submit(orderId: 14);

      expect(cubit.state, const ReportProblemSent(sampleReport));
    });

    test('giving up without a reason does nothing', () async {
      await cubit.loadReasons();

      await cubit.giveUp(work: sampleWork, note: validNote);

      expect(repository.usedKeys, isEmpty);
    });

    test('a refused give-up keeps the form with the error', () async {
      await readyWithReason();
      repository.giveUpResult = const Left<Failure, Unit>(
        ServerFailure(message: 'order already picked up'),
      );

      await cubit.giveUp(work: sampleWork, note: validNote);

      expect(
        (cubit.state as ReportProblemReady).submitError,
        'order already picked up',
      );
    });

    test('a refused give-up asks for current-work to be re-read', () async {
      await readyWithReason();
      repository.giveUpResult = const Left<Failure, Unit>(
        ServerFailure(message: 'order-conflict'),
      );

      await cubit.giveUp(work: sampleWork, note: validNote);

      expect((cubit.state as ReportProblemReady).workStale, isTrue);
    });

    test(
      'a give-up lost to the network does not mark the order stale',
      () async {
        await readyWithReason();
        repository.giveUpResult = const Left<Failure, Unit>(
          NetworkFailure(message: 'offline'),
        );

        await cubit.giveUp(work: sampleWork, note: validNote);

        expect((cubit.state as ReportProblemReady).workStale, isFalse);
      },
    );

    test('a refused report does not mark the order stale', () async {
      await readyWithReason();
      repository.reportResult = const Left<Failure, ProblemReport>(
        ServerFailure(message: 'rejected'),
      );

      await cubit.submit(orderId: sampleWork.orderId);

      expect((cubit.state as ReportProblemReady).workStale, isFalse);
    });

    test(
      'a give-up retried on the re-read order sends its new version',
      () async {
        await readyWithReason();
        repository.giveUpResult = const Left<Failure, Unit>(
          ServerFailure(message: 'order-conflict'),
        );
        await cubit.giveUp(work: sampleWork, note: validNote);

        repository.giveUpResult = const Right<Failure, Unit>(unit);
        await cubit.giveUp(
          work: sampleWork.withStatus(sampleWork.status, 7),
          note: validNote,
        );

        expect(repository.lastExpectedVersion, 7);
        expect(repository.usedKeys, <String>['key-1', 'key-2']);
      },
    );

    test('a give-up retried after a network failure reuses the key', () async {
      await readyWithReason();
      repository.giveUpResult = const Left<Failure, Unit>(
        NetworkFailure(message: 'offline'),
      );
      await cubit.giveUp(work: sampleWork, note: validNote);

      repository.giveUpResult = const Right<Failure, Unit>(unit);
      await cubit.giveUp(work: sampleWork, note: validNote);

      expect(repository.usedKeys, <String>['key-1', 'key-1']);
    });

    test('a report and a give-up never share a key', () async {
      await readyWithReason();
      repository.reportResult = const Left<Failure, ProblemReport>(
        NetworkFailure(message: 'offline'),
      );
      await cubit.submit(orderId: sampleWork.orderId);

      await cubit.giveUp(work: sampleWork, note: validNote);

      expect(repository.usedKeys, <String>['key-1', 'key-2']);
    });
  });
}
