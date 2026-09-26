import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:ssm_driver/features/orders/data/models/active_offer_model.dart';

import '../../helpers/fake_location_service.dart' show sampleLocation;
import 'orders_test_fakes.dart';

void main() {
  test('{"work": null} means no active order', () async {
    final source = OrdersRemoteDataSource(
      FakeDioConsumer(<String, dynamic>{'work': null}),
    );

    expect(await source.getCurrentWork(), isNull);
  });

  test('a bare work object is parsed', () async {
    final source = OrdersRemoteDataSource(FakeDioConsumer(currentWorkJson()));

    expect(await source.getCurrentWork(), sampleWork);
  });

  test('a work object inside the envelope is parsed', () async {
    final source = OrdersRemoteDataSource(
      FakeDioConsumer(<String, dynamic>{'work': currentWorkJson()}),
    );

    expect(await source.getCurrentWork(), sampleWork);
  });

  test('a non-object body is a server error', () async {
    final source = OrdersRemoteDataSource(FakeDioConsumer('<html>'));

    expect(source.getCurrentWork(), throwsA(isA<ServerException>()));
  });

  group('active offer', () {
    test('{"offer": null} means no offer waiting', () async {
      final source = OrdersRemoteDataSource(
        FakeDioConsumer(<String, dynamic>{'offer': null}),
      );

      expect(await source.getActiveOffer(), isNull);
    });

    test('the offer inside the envelope is parsed', () async {
      final source = OrdersRemoteDataSource(
        FakeDioConsumer(<String, dynamic>{'offer': activeOfferJson()}),
      );

      expect(await source.getActiveOffer(), sampleOffer);
    });

    test('a bare offer object is parsed', () async {
      final source = OrdersRemoteDataSource(
        FakeDioConsumer(activeOfferJson()),
      );

      expect(await source.getActiveOffer(), sampleOffer);
    });

    test('the live server payload is parsed', () async {
      // Captured from Telescope: bare object, delivery_address as an
      // object with string coordinates, no cod_amount.
      final source = OrdersRemoteDataSource(
        FakeDioConsumer(<String, dynamic>{
          'assignment_id': 14,
          'order_id': 14,
          'attempt_number': 1,
          'offered_at': '2026-09-26T06:29:58.000000Z',
          'expires_at': '2026-09-26T06:30:28.000000Z',
          'server_now': '2026-09-26T06:30:04.500879Z',
          'remaining_seconds': 23,
          'distance_meters_snapshot': 148,
          'pickup': <String, dynamic>{
            'name': 'Postman Test Store',
            'address': 'Tahlia St, Riyadh',
            'latitude': 31.02868023627,
            'longitude': 31.385976735242,
          },
          'delivery_address': <String, dynamic>{
            'contact_person_name': 'Rigoberto Mertz',
            'contact_person_number': '(679) 242-5335',
            'address': 'SSM merchant application test address',
            'latitude': '31.02868023627',
            'longitude': '31.385976735242',
          },
          'payment_method': 'cash_on_delivery',
          'order_type': 'delivery',
        }),
      );

      expect(
        await source.getActiveOffer(),
        const ActiveOfferModel(
          assignmentId: 14,
          orderId: 14,
          remainingSeconds: 23,
          distanceMeters: 148,
          pickupName: 'Postman Test Store',
          pickupAddress: 'Tahlia St, Riyadh',
          deliveryAddress: 'SSM merchant application test address',
          isCashOnDelivery: true,
          codAmount: '0.00',
        ),
      );
    });

    test('an empty body means no offer waiting', () async {
      final source = OrdersRemoteDataSource(FakeDioConsumer(null));

      expect(await source.getActiveOffer(), isNull);
    });

    test('an empty-string body means no offer waiting', () async {
      final source = OrdersRemoteDataSource(FakeDioConsumer(''));

      expect(await source.getActiveOffer(), isNull);
    });

    test('an object without offer ids means no offer waiting', () async {
      final source = OrdersRemoteDataSource(
        FakeDioConsumer(<String, dynamic>{'message': 'No active offers'}),
      );

      expect(await source.getActiveOffer(), isNull);
    });

    test('an enveloped object without offer ids means no offer', () async {
      final source = OrdersRemoteDataSource(
        FakeDioConsumer(<String, dynamic>{'offer': <String, dynamic>{}}),
      );

      expect(await source.getActiveOffer(), isNull);
    });
  });

  group('commands send the Idempotency-Key header', () {
    late FakeDioConsumer consumer;
    late OrdersRemoteDataSource source;

    setUp(() {
      consumer = FakeDioConsumer(<String, dynamic>{
        'message': 'ok',
        'order_id': 100001,
        'ssm_status': 'picked_up',
        'ssm_status_version': 7,
        'idempotent_replay': false,
      });
      source = OrdersRemoteDataSource(consumer);
    });

    test('accept posts to the assignment and carries the key', () async {
      await source.acceptOffer(501, idempotencyKey: 'key-a');

      expect(consumer.lastPath, '/delivery-man/offers/501/accept');
      expect(consumer.lastHeaders, <String, dynamic>{
        'Idempotency-Key': 'key-a',
      });
    });

    test('reject posts to the assignment and carries the key', () async {
      await source.rejectOffer(501, idempotencyKey: 'key-r');

      expect(consumer.lastPath, '/delivery-man/offers/501/reject');
      expect(consumer.lastHeaders, <String, dynamic>{
        'Idempotency-Key': 'key-r',
      });
    });

    test('pickup sends the key and the optimistic-lock version', () async {
      final transition = await source.confirmPickup(
        orderId: 100001,
        idempotencyKey: 'key-p',
        expectedVersion: 6,
      );

      expect(consumer.lastPath, '/delivery-man/orders/100001/pickup');
      expect(consumer.lastHeaders, <String, dynamic>{
        'Idempotency-Key': 'key-p',
      });
      expect(consumer.lastBody, <String, dynamic>{'expected_version': 6});
      expect(transition, pickedUpTransition);
    });

    test('out-for-delivery omits the version when unknown', () async {
      await source.startDelivery(orderId: 100001, idempotencyKey: 'key-o');

      expect(consumer.lastPath, '/delivery-man/orders/100001/out-for-delivery');
      expect(consumer.lastBody, isEmpty);
    });

    test('complete sends the OTP proof and cash collection', () async {
      await source.completeWithOtp(
        orderId: 100001,
        otp: '123456',
        codCollected: true,
        idempotencyKey: 'key-c',
      );

      expect(consumer.lastPath, '/delivery-man/orders/100001/complete');
      expect(consumer.lastHeaders, <String, dynamic>{
        'Idempotency-Key': 'key-c',
      });
      expect(consumer.lastBody, <String, dynamic>{
        'proof_method': 'otp',
        'otp': '123456',
        'cod_collected': true,
      });
    });

    test('a non-object lifecycle answer is a server error', () async {
      consumer.response = '<html>';

      expect(
        source.confirmPickup(orderId: 1, idempotencyKey: 'k'),
        throwsA(isA<ServerException>()),
      );
    });

    test('complete sends the location/time proof', () async {
      await source.completeWithLocation(
        orderId: 100001,
        location: sampleLocation,
        codCollected: false,
        idempotencyKey: 'key-l',
        expectedVersion: 8,
      );

      expect(consumer.lastPath, '/delivery-man/orders/100001/complete');
      expect(consumer.lastHeaders, <String, dynamic>{
        'Idempotency-Key': 'key-l',
      });
      expect(consumer.lastBody, <String, dynamic>{
        'proof_method': 'location_time',
        'latitude': 24.7136,
        'longitude': 46.6753,
        'accuracy': 8.5,
        'device_timestamp': '2026-09-23T09:00:00.000Z',
        'cod_collected': false,
        'expected_version': 8,
      });
    });
  });
}
