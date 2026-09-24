import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/driver_stats/driver_stats_remote_data_source.dart';
import 'package:ssm_driver/core/services/driver_stats/driver_stats_repository.dart';

import '../features/orders/orders_test_fakes.dart' show FakeDioConsumer;
import '../helpers/key_localizations.dart';
import 'driver_stats_test_fakes.dart';

void main() {
  useKeyLocalizations();

  group('data source', () {
    test('reads the COD summary endpoint', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{
        'currency': 'SAR',
        'outstanding_cod_liability': '250.00',
        'cod_collections_count': 2,
      });

      expect(
        await DriverStatsRemoteDataSource(consumer).getCodSummary(),
        sampleCod,
      );
      expect(consumer.lastPath, '/delivery-man/cod-summary');
    });

    test('reads the incentive summary endpoint', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(<String, dynamic>{
        'currency': 'SAR',
        'completed_deliveries_count': 18,
        'completed_toward_next_reward': 8,
        'deliveries_required_for_next_reward': 2,
        'earned_incentive_amount': '5.00',
        'awards_count': 1,
      });

      expect(
        await DriverStatsRemoteDataSource(consumer).getIncentiveSummary(),
        sampleIncentive,
      );
      expect(consumer.lastPath, '/delivery-man/incentive-summary');
    });

    test('a non-object body is a server error', () async {
      final source = DriverStatsRemoteDataSource(FakeDioConsumer('<html>'));

      expect(source.getCodSummary(), throwsA(isA<ServerException>()));
    });
  });

  group('repository', () {
    late FakeDriverStatsRemoteDataSource remote;
    late DriverStatsRepositoryImpl repository;

    setUp(() {
      remote = FakeDriverStatsRemoteDataSource();
      repository = DriverStatsRepositoryImpl(remote);
    });

    test('returns the incentive summary', () async {
      final result = await repository.getIncentiveSummary();

      expect(result.getOrElse(() => throw 'failed'), sampleIncentive);
    });

    test('maps a lost connection to a network failure', () async {
      remote.error = const InternetConnectionException(message: 'offline');

      final result = await repository.getCodSummary();

      expect(
        result.swap().getOrElse(() => throw 'succeeded'),
        const NetworkFailure(message: 'offline'),
      );
    });

    test('an unexpected error becomes a generic server failure', () async {
      remote.error = StateError('boom');

      final result = await repository.getCodSummary();

      expect(
        result.swap().getOrElse(() => throw 'succeeded'),
        isA<ServerFailure>(),
      );
    });
  });
}
