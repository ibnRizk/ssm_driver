import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/parcels/data/repositories/parcels_repository_impl.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel_proof.dart';

import '../../helpers/key_localizations.dart';
import 'parcels_test_fakes.dart';

void main() {
  useKeyLocalizations();

  late FakeParcelsRemoteDataSource remote;
  late ParcelsRepositoryImpl repository;

  setUp(() {
    remote = FakeParcelsRemoteDataSource();
    repository = ParcelsRepositoryImpl(remote);
  });

  test('returns the parcel page', () async {
    final result = await repository.getParcels(page: 1, limit: 20);

    expect(result.getOrElse(() => throw 'failed'), samplePage);
  });

  test('maps a server error to a failure with its message', () async {
    remote.error = const ServerException(message: 'Parcel not found.');

    final result = await repository.getParcelDetails(99);

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      const ServerFailure(message: 'Parcel not found.'),
    );
  });

  test('maps a lost connection to a network failure', () async {
    remote.error = const InternetConnectionException(message: 'offline');

    final result = await repository.startDelivery(2);

    expect(
      result.swap().getOrElse(() => throw 'succeeded'),
      const NetworkFailure(message: 'offline'),
    );
  });

  test('maps an unexpected error to a generic failure', () async {
    remote.error = StateError('boom');

    final result = await repository.completeParcel(
      2,
      proof: const ParcelOtpProof('123456'),
      codCollected: true,
    );

    expect(result.swap().getOrElse(() => throw 'succeeded'), isA<ServerFailure>());
  });
}
