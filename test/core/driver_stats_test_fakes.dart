import 'package:dartz/dartz.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/driver_stats/cod_summary.dart';
import 'package:ssm_driver/core/services/driver_stats/cod_summary_model.dart';
import 'package:ssm_driver/core/services/driver_stats/driver_stats_remote_data_source.dart';
import 'package:ssm_driver/core/services/driver_stats/driver_stats_repository.dart';
import 'package:ssm_driver/core/services/driver_stats/incentive_summary.dart';
import 'package:ssm_driver/core/services/driver_stats/incentive_summary_model.dart';

/// The documented `GET /delivery-man/cod-summary` body, parsed.
const CodSummaryModel sampleCod = CodSummaryModel(
  currency: 'SAR',
  outstandingLiability: '250.00',
  collectionsCount: 2,
);

/// The documented `GET /delivery-man/incentive-summary` body, parsed.
const IncentiveSummaryModel sampleIncentive = IncentiveSummaryModel(
  currency: 'SAR',
  completedDeliveries: 18,
  completedTowardNextReward: 8,
  deliveriesRequiredForNextReward: 2,
  earnedAmount: '5.00',
  awardsCount: 1,
);

/// Throws [error] when set, otherwise returns the samples.
class FakeDriverStatsRemoteDataSource implements DriverStatsRemoteDataSource {
  Object? error;

  Future<T> _answer<T>(T value) async {
    if (error != null) throw error!;
    return value;
  }

  @override
  Future<CodSummaryModel> getCodSummary() => _answer(sampleCod);

  @override
  Future<IncentiveSummaryModel> getIncentiveSummary() =>
      _answer(sampleIncentive);
}

class FakeDriverStatsRepository implements DriverStatsRepository {
  Either<Failure, CodSummary> codResult = const Right<Failure, CodSummary>(
    sampleCod,
  );
  Either<Failure, IncentiveSummary> incentiveResult =
      const Right<Failure, IncentiveSummary>(sampleIncentive);

  @override
  Future<Either<Failure, CodSummary>> getCodSummary() async => codResult;

  @override
  Future<Either<Failure, IncentiveSummary>> getIncentiveSummary() async =>
      incentiveResult;
}
