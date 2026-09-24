import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/config/locale/app_localizations.dart';
import 'package:ssm_driver/features/orders/domain/entities/current_work.dart';
import 'package:ssm_driver/features/orders/presentation/work_status_label.dart';
import 'package:ssm_driver/injection_container.dart';

import 'orders_test_fakes.dart';

/// The real English template for the amount, every other key echoed back.
class _AmountLocalizations extends AppLocalizations {
  _AmountLocalizations() : super(null);

  @override
  String text(String key) => key == 'order_amount' ? '{amount} SAR' : key;
}

void main() {
  setUpAll(() => ServiceLocator.injectAppLocalizations(_AmountLocalizations()));
  tearDownAll(() => ServiceLocator.instance.unregister<AppLocalizations>());

  test('the COD amount is shown exactly as the API sent it', () {
    final CurrentWork withCents = CurrentWork(
      assignmentId: sampleWork.assignmentId,
      orderId: sampleWork.orderId,
      status: sampleWork.status,
      statusVersion: sampleWork.statusVersion,
      storeName: sampleWork.storeName,
      storeAddress: sampleWork.storeAddress,
      storeLatitude: sampleWork.storeLatitude,
      storeLongitude: sampleWork.storeLongitude,
      customerName: sampleWork.customerName,
      customerPhone: sampleWork.customerPhone,
      deliveryAddress: sampleWork.deliveryAddress,
      deliveryLatitude: sampleWork.deliveryLatitude,
      deliveryLongitude: sampleWork.deliveryLongitude,
      orderNote: sampleWork.orderNote,
      isCashOnDelivery: true,
      codAmount: '125.50',
    );

    expect(withCents.paymentLabel, '125.50 SAR');
  });
}
