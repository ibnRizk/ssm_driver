import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/features/orders/data/models/current_work_model.dart';

import 'orders_test_fakes.dart';

void main() {
  test('parses the documented current-work response', () {
    expect(CurrentWorkModel.fromJson(currentWorkJson()), sampleWork);
  });

  test('falls back to delivery_address for customer and coordinates', () {
    final Map<String, dynamic> json = currentWorkJson()
      ..remove('customer')
      ..remove('delivery_coordinates');

    final CurrentWorkModel work = CurrentWorkModel.fromJson(json);

    expect(work.customerName, 'Sara Customer');
    expect(work.customerPhone, '+966574577391');
    expect(work.deliveryLatitude, 24.71);
    expect(work.deliveryLongitude, 46.68);
  });

  test('keeps the COD amount as the exact decimal string', () {
    final CurrentWorkModel work = CurrentWorkModel.fromJson(
      currentWorkJson()..['cod_amount'] = '125.50',
    );

    expect(work.codAmount, '125.50');
  });

  test('a numeric COD amount is kept as its string form', () {
    final CurrentWorkModel work = CurrentWorkModel.fromJson(
      currentWorkJson()..['cod_amount'] = 31,
    );

    expect(work.codAmount, '31');
  });

  test('a prepaid order is not cash on delivery', () {
    final CurrentWorkModel work = CurrentWorkModel.fromJson(
      currentWorkJson()..['payment_method'] = 'digital_payment',
    );

    expect(work.isCashOnDelivery, isFalse);
  });

  test('an unknown status parses to null instead of throwing', () {
    final CurrentWorkModel work = CurrentWorkModel.fromJson(
      currentWorkJson()..['ssm_status'] = 'something_new',
    );

    expect(work.status, isNull);
  });
}
