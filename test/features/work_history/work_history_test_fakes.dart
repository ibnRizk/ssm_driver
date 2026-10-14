import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/work_history/data/datasources/work_history_remote_data_source.dart';
import 'package:ssm_driver/features/work_history/domain/entities/work_history.dart';
import 'package:ssm_driver/features/work_history/domain/repositories/work_history_repository.dart';

/// An order item in the shape the current-work endpoint uses.
Map<String, dynamic> historyOrderJson({
  int orderId = 100001,
  String status = 'delivered',
}) => <String, dynamic>{
  'assignment_id': 7,
  'order_id': orderId,
  'ssm_status': status,
  'pickup': <String, dynamic>{'name': 'Fixture Store'},
  'customer': <String, dynamic>{'name': 'Sara', 'phone': '+966500000000'},
  'delivery_address': 'Olaya, Riyadh',
  'payment_method': 'cash_on_delivery',
  'cod_amount': '31.00',
  'delivered_at': '2026-10-01T12:30:00Z',
};


HistoryOrder historyOrder(int id) => HistoryOrder(
  orderId: id,
  status: HistoryStatus.delivered,
  storeName: 'Fixture Store',
  deliveryAddress: 'Olaya, Riyadh',
  isCashOnDelivery: false,
  amount: '0.00',
  date: null,
);

HistoryParcel historyParcel(int id) => HistoryParcel(
  id: id,
  reference: 'C2C-$id',
  status: HistoryStatus.delivered,
  isTerminal: true,
  title: 'Document',
  senderName: 'Sender',
  recipientName: 'Recipient',
  date: null,
);

WorkHistoryPage historyPage({
  List<HistoryOrder> orders = const <HistoryOrder>[],
  List<HistoryParcel> parcels = const <HistoryParcel>[],
  int? ordersTotal,
  int? parcelsTotal,
}) => WorkHistoryPage(
  orders: orders,
  parcels: parcels,
  ordersTotal: ordersTotal ?? orders.length,
  parcelsTotal: parcelsTotal ?? parcels.length,
);

class FakeWorkHistoryRemoteDataSource implements WorkHistoryRemoteDataSource {
  Object? error;
  WorkHistoryPage page = historyPage();

  @override
  Future<WorkHistoryPage> getWorkHistory({
    required HistoryScope scope,
    required int page,
    required int limit,
  }) async {
    if (error != null) throw error!;
    return this.page;
  }
}

/// Records each request; answers per page, else with [result].
class FakeWorkHistoryRepository implements WorkHistoryRepository {
  Either<Failure, WorkHistoryPage> result = Right<Failure, WorkHistoryPage>(
    historyPage(),
  );
  final Map<int, Either<Failure, WorkHistoryPage>> pageResults =
      <int, Either<Failure, WorkHistoryPage>>{};

  /// Holds a scope's answer until the test completes its gate.
  final Map<HistoryScope, Completer<void>> scopeGates =
      <HistoryScope, Completer<void>>{};
  final List<({HistoryScope scope, int page})> requests =
      <({HistoryScope scope, int page})>[];

  @override
  Future<Either<Failure, WorkHistoryPage>> getWorkHistory({
    required HistoryScope scope,
    required int page,
    required int limit,
  }) async {
    requests.add((scope: scope, page: page));
    await scopeGates[scope]?.future;
    return pageResults[page] ?? result;
  }
}
