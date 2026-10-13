import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/config/routes/app_routes.dart';
import 'package:ssm_driver/config/routes/push_tap_router.dart';
import 'package:ssm_driver/core/services/push/push_hint.dart';

void main() {
  test('an offer opens Home, where the offer sheet appears', () {
    expect(
      pushDestinationOf(const PushHint(PushTarget.offer, id: 501)),
      (tabName: AppRoutes.homeName, parcelId: null),
    );
  });

  test('an order opens the Orders tab', () {
    expect(
      pushDestinationOf(const PushHint(PushTarget.order, id: 9001)),
      (tabName: AppRoutes.ordersName, parcelId: null),
    );
  });

  test('a parcel with an id opens that parcel over the Parcels tab', () {
    expect(
      pushDestinationOf(const PushHint(PushTarget.parcel, id: 7)),
      (tabName: AppRoutes.parcelsName, parcelId: 7),
    );
  });

  test('a parcel without an id opens the Parcels tab', () {
    expect(
      pushDestinationOf(const PushHint(PushTarget.parcel)),
      (tabName: AppRoutes.parcelsName, parcelId: null),
    );
  });

  test('an unknown push stays where the Driver is', () {
    expect(pushDestinationOf(const PushHint(PushTarget.unknown)), isNull);
  });
}
