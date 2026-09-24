import '../../api/api_endpoints.dart';
import '../../api/dio_consumer.dart';
import '../../error/exceptions.dart';
import 'cod_summary_model.dart';
import 'incentive_summary_model.dart';

/// Raw COD / incentive summary calls (API docs §12), shared by the Home and
/// Earnings tabs. Throws [AppException]s; the repository maps them.
class DriverStatsRemoteDataSource {
  final DioConsumer _consumer;

  const DriverStatsRemoteDataSource(this._consumer);

  Future<CodSummaryModel> getCodSummary() async => CodSummaryModel.fromJson(
    _asMap(await _consumer.get(ApiEndpoints.codSummary)),
  );

  Future<IncentiveSummaryModel> getIncentiveSummary() async =>
      IncentiveSummaryModel.fromJson(
        _asMap(await _consumer.get(ApiEndpoints.incentiveSummary)),
      );

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is! Map<String, dynamic>) throw const ServerException();
    return data;
  }
}
