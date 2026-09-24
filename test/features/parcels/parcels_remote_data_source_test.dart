import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/features/parcels/data/datasources/parcels_remote_data_source.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel_proof.dart';

import '../../helpers/fake_location_service.dart' show sampleLocation;
import 'parcels_test_fakes.dart';

void main() {
  Map<String, dynamic> single() => <String, dynamic>{
    'status': 'success',
    'data': parcelJson(),
  };

  group('list', () {
    test('parses the paginated data array and total size', () async {
      final source = ParcelsRemoteDataSource(
        FakeDioConsumer(<String, dynamic>{
          'status': 'success',
          'data': <dynamic>[parcelJson()],
          'total_size': 7,
          'limit': 20,
          'offset': 1,
        }),
      );

      expect(
        await source.getParcels(page: 1, limit: 20),
        const ParcelsPage(parcels: <Parcel>[sampleParcel], totalSize: 7),
      );
    });

    test('asks for active parcels by default', () async {
      final consumer = FakeDioConsumer(<String, dynamic>{'data': <dynamic>[]});

      await ParcelsRemoteDataSource(consumer).getParcels(page: 1, limit: 20);

      expect(consumer.lastPath, '/delivery-man/parcels');
      expect(consumer.lastQuery?['status'], 'active');
    });

    test('sends the page number as offset, with the limit', () async {
      final consumer = FakeDioConsumer(<String, dynamic>{'data': <dynamic>[]});

      await ParcelsRemoteDataSource(consumer).getParcels(page: 3, limit: 20);

      expect(consumer.lastQuery?['offset'], 3);
      expect(consumer.lastQuery?['limit'], 20);
    });

    test('falls back to the page length without a total size', () async {
      final source = ParcelsRemoteDataSource(
        FakeDioConsumer(<String, dynamic>{
          'data': <dynamic>[parcelJson(), parcelJson(id: 3)],
        }),
      );

      expect((await source.getParcels(page: 1, limit: 20)).totalSize, 2);
    });

    test('a body without a data array is a server error', () async {
      final source = ParcelsRemoteDataSource(
        FakeDioConsumer(<String, dynamic>{'data': null}),
      );

      expect(
        source.getParcels(page: 1, limit: 20),
        throwsA(isA<ServerException>()),
      );
    });
  });

  test('details unwraps the parcel from the data envelope', () async {
    final consumer = FakeDioConsumer(single());

    final parcel = await ParcelsRemoteDataSource(consumer).getParcelDetails(2);

    expect(consumer.lastPath, '/delivery-man/parcels/2');
    expect(parcel, sampleParcel);
  });

  test('a non-object body is a server error', () async {
    final source = ParcelsRemoteDataSource(FakeDioConsumer('<html>'));

    expect(source.getParcelDetails(2), throwsA(isA<ServerException>()));
  });

  test('start delivery posts to the parcel', () async {
    final consumer = FakeDioConsumer(single());

    await ParcelsRemoteDataSource(consumer).startDelivery(2);

    expect(consumer.lastPath, '/delivery-man/parcels/2/start-delivery');
  });

  group('complete', () {
    late FakeDioConsumer consumer;
    late ParcelsRemoteDataSource source;

    setUp(() {
      consumer = FakeDioConsumer(single());
      source = ParcelsRemoteDataSource(consumer);
    });

    test('sends an uppercase OTP proof', () async {
      await source.completeParcel(
        2,
        proof: const ParcelOtpProof('123456'),
        codCollected: false,
      );

      expect(consumer.lastPath, '/delivery-man/parcels/2/complete');
      expect(consumer.lastBody, <String, dynamic>{
        'proof_type': 'OTP',
        'otp': '123456',
      });
    });

    test('sends a location/time proof with the coordinates', () async {
      await source.completeParcel(
        2,
        proof: ParcelLocationProof(sampleLocation),
        codCollected: false,
      );

      expect(consumer.lastBody, <String, dynamic>{
        'proof_type': 'LOCATION_TIME',
        'latitude': sampleLocation.latitude,
        'longitude': sampleLocation.longitude,
      });
    });

    test('marks the cash collected for a COD parcel', () async {
      await source.completeParcel(
        2,
        proof: const ParcelOtpProof('123456'),
        codCollected: true,
      );

      expect(consumer.lastBody?['cod_collected'], isTrue);
    });
  });
}
