import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:ssm_driver/features/orders/data/models/problem_report_model.dart';
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
  });
}
