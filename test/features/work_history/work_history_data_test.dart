import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/work_history/data/datasources/work_history_remote_data_source.dart';
import 'package:ssm_driver/features/work_history/data/models/work_history_models.dart';
import 'package:ssm_driver/features/work_history/data/repositories/work_history_repository_impl.dart';
import 'package:ssm_driver/features/work_history/domain/entities/work_history.dart';

import '../../helpers/key_localizations.dart';
import '../parcels/parcels_test_fakes.dart' show FakeDioConsumer;
import '../../helpers/c2c_fixtures.dart';
import 'work_history_test_fakes.dart';

void main() {
  useKeyLocalizations();

  group('models', () {
    test('parses an order item', () {
      final HistoryOrder order = HistoryOrderModel.fromJson(historyOrderJson());

      expect(
        order,
        HistoryOrderModel(
          orderId: 100001,
          status: HistoryStatus.delivered,
          storeName: 'Fixture Store',
          deliveryAddress: 'Olaya, Riyadh',
          isCashOnDelivery: true,
          amount: '31.00',
          date: DateTime.utc(2026, 10, 1, 12, 30),
        ),
      );
    });

    test('parses a C2C parcel item', () {
      final HistoryParcel parcel = HistoryParcelModel.fromJson(c2cItemJson());

      expect(
        parcel,
        HistoryParcelModel(
          id: 1,
          reference: 'C2C-0001',
          status: HistoryStatus.outForDelivery,
          isTerminal: false,
          title: 'Document',
          senderName: 'Sender name',
          recipientName: 'Recipient name',
          date: DateTime.utc(2026, 10, 2, 8),
        ),
      );
      expect(parcel.isActiveWork, isTrue);
    });

    test('an unaccepted C2C item exposes no names', () {
      final HistoryParcel parcel = HistoryParcelModel.fromJson(
        c2cItemJson(status: 'driver_assigned'),
      );

      expect(parcel.senderName, isEmpty);
      expect(parcel.recipientName, isEmpty);
      expect(parcel.isActiveWork, isFalse);
    });

    test('a terminal C2C item is not active work', () {
      final HistoryParcel parcel = HistoryParcelModel.fromJson(
        c2cItemJson(status: 'delivered', isTerminal: true),
      );

      expect(parcel.isActiveWork, isFalse);
    });

    test('reads the C2C lifecycle statuses', () {
      expect(HistoryStatus.fromApi('driver_at_pickup'), HistoryStatus.atPickup);
      expect(HistoryStatus.fromApi('OUT_FOR_DELIVERY'), HistoryStatus.outForDelivery);
      expect(HistoryStatus.fromApi('return_started'), HistoryStatus.returning);
      expect(HistoryStatus.fromApi('ARRIVED_AT_WAREHOUSE'), isNull);
    });

    test('a nested delivery address object is read for its address', () {
      final HistoryOrder order = HistoryOrderModel.fromJson(<String, dynamic>{
        ...historyOrderJson(),
        'delivery_address': <String, dynamic>{'address': 'Malqa, Riyadh'},
      });

      expect(order.deliveryAddress, 'Malqa, Riyadh');
    });

    test('splits the feed and reads its totals', () {
      final WorkHistoryPage page = workHistoryPageFromJson(<String, dynamic>{
        'scope': 'previous',
        'orders': <dynamic>[historyOrderJson()],
        'c2c_parcels': <dynamic>[c2cItemJson(id: 2)],
        'totals': <String, dynamic>{'orders': 12, 'c2c_parcels': '4'},
      });

      expect(page.orders.single.orderId, 100001);
      expect(page.parcels.single.id, 2);
      expect(page.ordersTotal, 12);
      expect(page.parcelsTotal, 4);
    });

    test('missing arrays and totals fall back to empty and page length', () {
      final WorkHistoryPage page = workHistoryPageFromJson(<String, dynamic>{
        'scope': 'current',
        'orders': <dynamic>[historyOrderJson(), 'junk'],
      });

      expect(page.orders, hasLength(1));
      expect(page.parcels, isEmpty);
      expect(page.ordersTotal, 1);
      expect(page.parcelsTotal, 0);
    });
  });

  group('data source', () {
    test('asks for the scope with the page number as offset', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{});

      await WorkHistoryRemoteDataSource(
        consumer,
      ).getWorkHistory(scope: HistoryScope.previous, page: 2, limit: 20);

      expect(consumer.lastPath, '/delivery-man/work-history');
      expect(consumer.lastQuery, <String, dynamic>{
        'scope': 'previous',
        'limit': 20,
        'offset': 2,
      });
    });

    test('a non-object body is a server error', () {
      expect(
        WorkHistoryRemoteDataSource(
          FakeDioConsumer(<dynamic>[]),
        ).getWorkHistory(scope: HistoryScope.current, page: 1, limit: 20),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('repository', () {
    test('returns the page', () async {
      final FakeWorkHistoryRemoteDataSource remote =
          FakeWorkHistoryRemoteDataSource()
            ..page = historyPage(orders: [historyOrder(1)]);

      final result = await WorkHistoryRepositoryImpl(
        remote,
      ).getWorkHistory(scope: HistoryScope.current, page: 1, limit: 20);

      expect(result, Right<Failure, WorkHistoryPage>(remote.page));
    });

    test('maps an app exception to a failure', () async {
      final FakeWorkHistoryRemoteDataSource remote =
          FakeWorkHistoryRemoteDataSource()..error = const ServerException();

      final result = await WorkHistoryRepositoryImpl(
        remote,
      ).getWorkHistory(scope: HistoryScope.current, page: 1, limit: 20);

      expect(result.isLeft(), isTrue);
    });

    test('maps an unexpected error to a server failure', () async {
      final FakeWorkHistoryRemoteDataSource remote =
          FakeWorkHistoryRemoteDataSource()..error = StateError('boom');

      final result = await WorkHistoryRepositoryImpl(
        remote,
      ).getWorkHistory(scope: HistoryScope.current, page: 1, limit: 20);

      expect(result.fold((Failure f) => f, (_) => null), isA<ServerFailure>());
    });
  });
}
