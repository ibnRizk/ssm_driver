import 'package:dartz/dartz.dart';
import 'package:ssm_driver/core/api/dio_consumer.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:ssm_driver/features/orders/data/models/current_work_model.dart';
import 'package:ssm_driver/features/orders/domain/entities/current_work.dart';
import 'package:ssm_driver/features/orders/domain/repositories/orders_repository.dart';

/// The documented `GET /delivery-man/current-work` 200 body.
Map<String, dynamic> currentWorkJson() => <String, dynamic>{
  'assignment_id': 3,
  'order_id': 100001,
  'ssm_status': 'driver_accepted',
  'ssm_status_version': 6,
  'pickup': <String, dynamic>{
    'name': 'SSM Fixture Store',
    'address': 'Olaya St, Riyadh',
    'latitude': 24.7136,
    'longitude': 46.6753,
  },
  'delivery_address': <String, dynamic>{
    'contact_person_name': 'Sara Customer',
    'contact_person_number': '+966574577391',
    'address_type': 'Delivery',
    'address': 'Olaya St 12, Riyadh',
    'longitude': '46.6800',
    'latitude': '24.7100',
  },
  'delivery_coordinates': <String, dynamic>{
    'latitude': 24.71,
    'longitude': 46.68,
  },
  'customer': <String, dynamic>{
    'name': 'Sara Customer',
    'phone': '+966574577391',
  },
  'order_note': null,
  'payment_method': 'cash_on_delivery',
  'cod_amount': 31,
  'order_type': 'delivery',
  'accepted_at': '2026-09-22 01:31:48',
  'picked_up_at': null,
  'delivery_completed_at': null,
};

const CurrentWorkModel sampleWork = CurrentWorkModel(
  assignmentId: 3,
  orderId: 100001,
  status: WorkStatus.driverAccepted,
  statusVersion: 6,
  storeName: 'SSM Fixture Store',
  storeAddress: 'Olaya St, Riyadh',
  storeLatitude: 24.7136,
  storeLongitude: 46.6753,
  customerName: 'Sara Customer',
  customerPhone: '+966574577391',
  deliveryAddress: 'Olaya St 12, Riyadh',
  deliveryLatitude: 24.71,
  deliveryLongitude: 46.68,
  orderNote: null,
  isCashOnDelivery: true,
  codAmount: 31,
);

/// Answers every GET with [response]; the other verbs are unused here.
class FakeDioConsumer implements DioConsumer {
  dynamic response;

  FakeDioConsumer(this.response);

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async => response;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Throws [error] when set, otherwise returns [work].
class FakeOrdersRemoteDataSource implements OrdersRemoteDataSource {
  Object? error;
  CurrentWorkModel? work = sampleWork;

  @override
  Future<CurrentWorkModel?> getCurrentWork() async {
    if (error != null) throw error!;
    return work;
  }
}

class FakeOrdersRepository implements OrdersRepository {
  Either<Failure, CurrentWork?> result = const Right<Failure, CurrentWork?>(
    sampleWork,
  );

  @override
  Future<Either<Failure, CurrentWork?>> getCurrentWork() async => result;
}
