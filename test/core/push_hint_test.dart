import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/services/push/push_hint.dart';

void main() {
  group('target from the type', () {
    test('an offer event is an offer', () {
      expect(
        PushHint.fromData(<String, dynamic>{'type': 'ssm.driver.offer_created'}),
        const PushHint(PushTarget.offer),
      );
    });

    test('an assignment event is an order', () {
      expect(
        PushHint.fromData(<String, dynamic>{'event': 'ssm.driver.assigned'})
            .target,
        PushTarget.order,
      );
    });

    test('a parcel type wins over the order wording in it', () {
      expect(
        PushHint.fromData(<String, dynamic>{
          'type': 'parcel_order_updated',
        }).target,
        PushTarget.parcel,
      );
    });

    test('a C2C type is a C2C push, not a warehouse parcel', () {
      expect(
        PushHint.fromData(<String, dynamic>{
          'type': 'ssm.c2c_parcel.offer_created',
          'parcel_id': '31',
        }),
        const PushHint(PushTarget.c2cParcel, id: 31),
      );
    });

    test('a C2C parcel id without a type is a C2C push', () {
      expect(
        PushHint.fromData(<String, dynamic>{'c2c_parcel_id': 4}),
        const PushHint(PushTarget.c2cParcel, id: 4),
      );
    });

    test('the type is matched case-insensitively', () {
      expect(
        PushHint.fromData(<String, dynamic>{'type': 'NEW_OFFER'}).target,
        PushTarget.offer,
      );
    });
  });

  group('target from the id when there is no known type', () {
    test('a parcel id means a parcel push', () {
      expect(
        PushHint.fromData(<String, dynamic>{'parcel_id': '7'}),
        const PushHint(PushTarget.parcel, id: 7),
      );
    });

    test('an assignment id means an offer push', () {
      expect(
        PushHint.fromData(<String, dynamic>{'assignment_id': '501'}),
        const PushHint(PushTarget.offer, id: 501),
      );
    });

    test('an order id means an order push', () {
      expect(
        PushHint.fromData(<String, dynamic>{'order_id': 9001}),
        const PushHint(PushTarget.order, id: 9001),
      );
    });
  });

  test('a typed parcel push falls back to the generic id', () {
    expect(
      PushHint.fromData(<String, dynamic>{'type': 'parcel', 'id': '12'}),
      const PushHint(PushTarget.parcel, id: 12),
    );
  });

  test('a non-numeric id is dropped, not thrown on', () {
    expect(
      PushHint.fromData(<String, dynamic>{'type': 'parcel', 'id': 'abc'}).id,
      isNull,
    );
  });

  test('an unrecognised payload is unknown', () {
    expect(
      PushHint.fromData(<String, dynamic>{'title': 'Hello'}),
      const PushHint(PushTarget.unknown),
    );
  });

  group('concerns', () {
    test('a push concerns its own resource only', () {
      const PushHint hint = PushHint(PushTarget.parcel);

      expect(hint.concerns(PushTarget.parcel), isTrue);
      expect(hint.concerns(PushTarget.order), isFalse);
    });

    test('an unknown push concerns every resource', () {
      const PushHint hint = PushHint(PushTarget.unknown);

      expect(hint.concerns(PushTarget.offer), isTrue);
      expect(hint.concerns(PushTarget.order), isTrue);
      expect(hint.concerns(PushTarget.parcel), isTrue);
    });
  });
}
