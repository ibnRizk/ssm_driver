import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/work_history/domain/entities/work_history.dart';
import 'package:ssm_driver/features/work_history/presentation/cubit/work_history_cubit.dart';
import 'package:ssm_driver/features/work_history/presentation/cubit/work_history_state.dart';

import '../../helpers/key_localizations.dart';
import 'work_history_test_fakes.dart';

void main() {
  useKeyLocalizations();

  late FakeWorkHistoryRepository repository;
  late WorkHistoryCubit cubit;

  setUp(() {
    repository = FakeWorkHistoryRepository();
    cubit = WorkHistoryCubit(repository);
  });

  tearDown(() => cubit.close());

  test('loads the current scope by default', () async {
    final WorkHistoryPage page = historyPage(orders: [historyOrder(1)]);
    repository.result = Right<Failure, WorkHistoryPage>(page);

    await cubit.load();

    expect(repository.requests.single, (scope: HistoryScope.current, page: 1));
    expect(
      cubit.state,
      WorkHistoryLoaded(HistoryScope.current, page, hasMore: false),
    );
  });

  test('switching scope shows loading for the new scope', () async {
    await cubit.load();
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<Matcher>[
        isA<WorkHistoryLoading>().having(
          (WorkHistoryLoading s) => s.scope,
          'scope',
          HistoryScope.previous,
        ),
        isA<WorkHistoryLoaded>(),
      ]),
    );

    await cubit.load(scope: HistoryScope.previous);
    await expectation;
  });

  test('a refresh keeps the loaded list on screen', () async {
    await cubit.load();
    final List<WorkHistoryState> seen = <WorkHistoryState>[];
    final StreamSubscription<WorkHistoryState> sub = cubit.stream.listen(
      seen.add,
    );

    await cubit.load();

    expect(seen.whereType<WorkHistoryLoading>(), isEmpty);
    await sub.cancel();
  });

  test('a failure shows the message for that scope', () async {
    repository.result = const Left<Failure, WorkHistoryPage>(
      NetworkFailure(message: 'offline'),
    );

    await cubit.load(scope: HistoryScope.previous);

    expect(cubit.state, const WorkHistoryError(HistoryScope.previous, 'offline'));
  });

  test('a late answer for an abandoned scope is dropped', () async {
    final Completer<void> gate = Completer<void>();
    repository.scopeGates[HistoryScope.current] = gate;
    final Future<void> stale = cubit.load();
    final WorkHistoryPage previous = historyPage(parcels: [historyParcel(9)]);
    repository.result = Right<Failure, WorkHistoryPage>(previous);

    repository.scopeGates.remove(HistoryScope.current);
    await cubit.load(scope: HistoryScope.previous);
    repository.result = Right<Failure, WorkHistoryPage>(
      historyPage(orders: [historyOrder(1)]),
    );
    gate.complete();
    await stale;

    expect(
      cubit.state,
      WorkHistoryLoaded(HistoryScope.previous, previous, hasMore: false),
    );
  });

  test('load more appends the next page of both feeds', () async {
    repository.pageResults[1] = Right<Failure, WorkHistoryPage>(
      historyPage(
        orders: [historyOrder(1)],
        parcels: [historyParcel(1)],
        ordersTotal: 2,
        parcelsTotal: 1,
      ),
    );
    repository.pageResults[2] = Right<Failure, WorkHistoryPage>(
      historyPage(orders: [historyOrder(2)], ordersTotal: 2, parcelsTotal: 1),
    );
    await cubit.load();

    await cubit.loadMore();

    final WorkHistoryLoaded state = cubit.state as WorkHistoryLoaded;
    expect(state.page.orders.map((HistoryOrder o) => o.orderId), <int>[1, 2]);
    expect(state.page.parcels, hasLength(1));
    expect(state.hasMore, isFalse);
    expect(repository.requests.last, (scope: HistoryScope.current, page: 2));
  });

  test('load more is a no-op when everything is loaded', () async {
    await cubit.load();

    await cubit.loadMore();

    expect(repository.requests, hasLength(1));
  });

  test('an empty next page ends the list despite stale totals', () async {
    repository.pageResults[1] = Right<Failure, WorkHistoryPage>(
      historyPage(orders: [historyOrder(1)], ordersTotal: 50),
    );
    repository.pageResults[2] = Right<Failure, WorkHistoryPage>(
      historyPage(ordersTotal: 50),
    );
    await cubit.load();

    await cubit.loadMore();

    expect((cubit.state as WorkHistoryLoaded).hasMore, isFalse);
  });

  test('a failed next page keeps the list and stops auto-loading', () async {
    repository.pageResults[1] = Right<Failure, WorkHistoryPage>(
      historyPage(orders: [historyOrder(1)], ordersTotal: 5),
    );
    repository.pageResults[2] = const Left<Failure, WorkHistoryPage>(
      NetworkFailure(message: 'offline'),
    );
    await cubit.load();
    await cubit.loadMore();

    await cubit.loadMore();

    final WorkHistoryLoaded state = cubit.state as WorkHistoryLoaded;
    expect(state.loadMoreError, 'offline');
    expect(state.page.orders, hasLength(1));
    expect(repository.requests, hasLength(2));
  });
}
