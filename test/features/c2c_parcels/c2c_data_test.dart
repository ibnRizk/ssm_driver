import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/c2c_parcels/data/datasources/c2c_parcels_remote_data_source.dart';
import 'package:ssm_driver/features/c2c_parcels/data/models/c2c_parcel_model.dart';
import 'package:ssm_driver/features/c2c_parcels/data/repositories/c2c_parcels_repository_impl.dart';
import 'package:ssm_driver/features/c2c_parcels/domain/entities/c2c_parcel.dart';

import '../../helpers/c2c_fixtures.dart';
import '../../helpers/fake_location_service.dart' show sampleLocation;
import '../../helpers/key_localizations.dart';
import '../parcels/parcels_test_fakes.dart' show FakeDioConsumer;

void main() {
  useKeyLocalizations();

  group('model', () {
    test('parses the contract §3 item', () {
      final C2cParcel parcel = C2cParcelModel.fromJson(c2cItemJson());

      expect(parcel.id, 1);
      expect(parcel.reference, 'C2C-0001');
      expect(parcel.status, C2cStatus.outForDelivery);
      expect(parcel.statusVersion, 4);
      expect(parcel.title, 'Document');
      expect(parcel.weightKg, '1');
      expect(parcel.pickup.name, 'Sender name');
      expect(parcel.dropoff.phone, '+201000000002');
      expect(parcel.dropoff.latitude, 31.045);
      expect(parcel.deliveryInstructions, 'Leave at reception');
      expect(parcel.nextActions, <C2cAction>[C2cAction.complete]);
      expect(parcel.requiresOtpToComplete, isTrue);
    });

    test('an offer keeps only coarse areas, whatever was sent', () {
      final C2cParcel offer = C2cParcelModel.fromJson(<String, dynamic>{
        ...c2cItemJson(status: 'driver_assigned'),
        'pickup': <String, dynamic>{
          'name': 'Sender name',
          'phone': '+201000000001',
          'address': '12 Exact St',
          'latitude': 31.0409,
          'longitude': 31.3785,
          'area': 'Talkha',
        },
      }, coarse: true);

      expect(offer.pickup.area, 'Talkha');
      expect(offer.pickup.name, isEmpty);
      expect(offer.pickup.phone, isEmpty);
      expect(offer.pickup.address, isEmpty);
      expect(offer.pickup.hasCoordinates, isFalse);
      expect(offer.pickupInstructions, isEmpty);
    });

    group('coarse area', () {
      C2cParcel offerWith(Map<String, dynamic> fields) =>
          C2cParcelModel.fromJson(<String, dynamic>{
            ...c2cItemJson(status: 'driver_assigned'),
            'pickup': const <String, dynamic>{},
            'dropoff': const <String, dynamic>{},
            ...fields,
          }, coarse: true);

      test('joins a separate district and city', () {
        final C2cParcel offer = offerWith(<String, dynamic>{
          'pickup': <String, dynamic>{'district': 'Al Malaz', 'city': 'Riyadh'},
        });

        expect(offer.pickup.area, 'Al Malaz, Riyadh');
      });

      test('reads a name out of an object value', () {
        final C2cParcel offer = offerWith(<String, dynamic>{
          'pickup': <String, dynamic>{
            'zone': <String, dynamic>{'id': 3, 'name': 'Talkha'},
          },
        });

        expect(offer.pickup.area, 'Talkha');
      });

      test('reads the area inside an address object, not its street', () {
        final C2cParcel offer = offerWith(<String, dynamic>{
          'dropoff': <String, dynamic>{
            'address': <String, dynamic>{
              'address': '12 Exact St',
              'city': 'Mansoura',
            },
          },
        });

        expect(offer.dropoff.area, 'Mansoura');
        expect(offer.dropoff.address, isEmpty);
      });

      test('falls back to the item\'s flat pickup_/dropoff_ fields', () {
        final C2cParcel offer = offerWith(<String, dynamic>{
          'pickup_area': 'Talkha',
          'recipient_city': 'Mansoura',
        });

        expect(offer.pickup.area, 'Talkha');
        expect(offer.dropoff.area, 'Mansoura');
      });

      test('reads sender/recipient objects in place of pickup/dropoff', () {
        final C2cParcel offer = C2cParcelModel.fromJson(<String, dynamic>{
          ...c2cItemJson(status: 'driver_assigned'),
          'pickup': null,
          'sender': <String, dynamic>{'area': 'Talkha', 'phone': '+2010'},
        }, coarse: true);

        expect(offer.pickup.area, 'Talkha');
        expect(offer.pickup.phone, isEmpty);
      });

      test('stays empty when no coarse field is sent', () {
        final C2cParcel offer = offerWith(<String, dynamic>{
          'pickup': <String, dynamic>{'name': 'Sender', 'address': '12 St'},
        });

        expect(offer.pickup.area, isEmpty);
      });
    });

    test('an accepted item reads the street out of an address object', () {
      final C2cParcel parcel = C2cParcelModel.fromJson(<String, dynamic>{
        ...c2cItemJson(),
        'dropoff': <String, dynamic>{
          'address': <String, dynamic>{
            'address': '12 Exact St',
            'city': 'Mansoura',
          },
        },
      });

      expect(parcel.dropoff.address, '12 Exact St');
      expect(parcel.dropoff.area, 'Mansoura');
    });

    test('a driver_assigned item is coarse even outside the offers feed', () {
      final C2cParcel parcel = C2cParcelModel.fromJson(
        c2cItemJson(status: 'driver_assigned'),
      );

      expect(parcel.dropoff.name, isEmpty);
      expect(parcel.dropoff.hasCoordinates, isFalse);
    });

    test('only an explicit false skips the completion OTP', () {
      expect(
        C2cParcelModel.fromJson(c2cItemJson(requiresOtp: false))
            .requiresOtpToComplete,
        isFalse,
      );
      expect(
        C2cParcelModel.fromJson(c2cItemJson(requiresOtp: null))
            .requiresOtpToComplete,
        isTrue,
      );
    });

    test('reads next_actions with dashes or underscores, dropping unknown', () {
      final C2cParcel parcel = C2cParcelModel.fromJson(
        c2cItemJson(nextActions: <String>['arrive-pickup', 'report', 'pickup']),
      );

      expect(parcel.nextActions, <C2cAction>[
        C2cAction.arrivePickup,
        C2cAction.pickup,
      ]);
    });
  });

  group('data source', () {
    test('offers: a bare list is parsed coarse', () async {
      final List<C2cParcel> offers = await C2cParcelsRemoteDataSource(
        FakeDioConsumer(<dynamic>[c2cItemJson(status: 'driver_assigned')]),
      ).getOffers();

      expect(offers.single.pickup.name, isEmpty);
    });

    test('offers: data/offers envelopes and an empty offer are read', () async {
      Future<int> count(dynamic body) async =>
          (await C2cParcelsRemoteDataSource(
            FakeDioConsumer(body),
          ).getOffers()).length;

      expect(await count(<String, dynamic>{'data': <dynamic>[c2cItemJson()]}), 1);
      expect(
        await count(<String, dynamic>{'offers': <dynamic>[c2cItemJson()]}),
        1,
      );
      expect(await count(<String, dynamic>{'offer': null}), 0);
      expect(await count(<String, dynamic>{'message': 'No offers'}), 0);
    });

    test('current jobs come from work-history c2c_parcels', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{
        'scope': 'current',
        'orders': <dynamic>[],
        'c2c_parcels': <dynamic>[c2cItemJson()],
        'totals': <String, dynamic>{'orders': 0, 'c2c_parcels': 1},
      });

      final List<C2cParcel> jobs = await C2cParcelsRemoteDataSource(
        consumer,
      ).getCurrentJobs();

      expect(consumer.lastPath, '/delivery-man/work-history');
      expect(consumer.lastQuery?['scope'], 'current');
      expect(jobs.single.pickup.name, 'Sender name');
    });

    test('each action posts to its endpoint with the Idempotency-Key', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{});
      final C2cParcelsRemoteDataSource source = C2cParcelsRemoteDataSource(
        consumer,
      );
      final Map<C2cAction, String> paths = <C2cAction, String>{
        C2cAction.accept: '/delivery-man/c2c-parcels/7/accept',
        C2cAction.arrivePickup: '/delivery-man/c2c-parcels/7/arrive-pickup',
        C2cAction.pickup: '/delivery-man/c2c-parcels/7/pickup',
        C2cAction.outForDelivery:
            '/delivery-man/c2c-parcels/7/out-for-delivery',
        C2cAction.complete: '/delivery-man/c2c-parcels/7/complete',
      };

      for (final MapEntry<C2cAction, String> e in paths.entries) {
        await source.runAction(7, e.key, idempotencyKey: 'k-${e.key.name}');
        expect(consumer.lastPath, e.value);
        expect(consumer.lastHeaders?['Idempotency-Key'], 'k-${e.key.name}');
      }
    });

    test('complete sends the OTP; other actions never do', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{});
      final C2cParcelsRemoteDataSource source = C2cParcelsRemoteDataSource(
        consumer,
      );

      await source.runAction(7, C2cAction.complete, idempotencyKey: 'k', otp: '123456');
      expect(consumer.lastBody, <String, dynamic>{'otp': '123456'});

      await source.runAction(7, C2cAction.pickup, idempotencyKey: 'k', otp: '123456');
      expect(consumer.lastBody, isEmpty);
    });

    test('an action answer is read bare or wrapped, never the info block', () async {
      Future<C2cParcel?> answer(dynamic body) => C2cParcelsRemoteDataSource(
        FakeDioConsumer(body),
      ).runAction(1, C2cAction.pickup, idempotencyKey: 'k');

      expect((await answer(c2cItemJson(status: 'picked_up')))?.status,
          C2cStatus.pickedUp);
      expect(
        (await answer(<String, dynamic>{'data': c2cItemJson(status: 'picked_up')}))
            ?.status,
        C2cStatus.pickedUp,
      );
      // `parcel` here is the item's description block — not a parcel.
      expect(
        await answer(<String, dynamic>{
          'message': 'ok',
          'parcel': <String, dynamic>{'title': 'Document'},
        }),
        isNull,
      );
    });

    test('a location ping posts to the parcel tracking endpoint', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{});

      await C2cParcelsRemoteDataSource(consumer).sendLocation(3, sampleLocation);

      expect(consumer.lastPath, '/delivery-man/c2c-parcels/3/location');
      expect(consumer.lastBody?['latitude'], sampleLocation.latitude);
      expect(consumer.lastBody?.containsKey('driver_id'), isFalse);
    });

    test('a non-object current-work body is a server error', () {
      expect(
        C2cParcelsRemoteDataSource(FakeDioConsumer(<dynamic>[])).getCurrentJobs(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('repository', () {
    test('active jobs drop unaccepted and finished items', () async {
      final C2cParcelsRepositoryImpl repository = C2cParcelsRepositoryImpl(
        C2cParcelsRemoteDataSource(
          FakeDioConsumer(<String, dynamic>{
            'c2c_parcels': <dynamic>[
              c2cItemJson(id: 1, status: 'driver_assigned'),
              c2cItemJson(id: 2, status: 'picked_up'),
              c2cItemJson(id: 3, status: 'delivered', isTerminal: true),
            ],
          }),
        ),
      );

      final jobs = (await repository.getActiveJobs()).getOrElse(() => []);

      expect(jobs.map((C2cParcel j) => j.id), <int>[2]);
    });

    test('an app exception becomes a failure', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(null)
        ..error = const ServerException();

      final result = await C2cParcelsRepositoryImpl(
        C2cParcelsRemoteDataSource(consumer),
      ).getOffers();

      expect(result.fold((Failure f) => f, (_) => null), isA<Failure>());
    });
  });
}
