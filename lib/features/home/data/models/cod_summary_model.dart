import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/cod_summary.dart';

class CodSummaryModel extends CodSummary {
  const CodSummaryModel({
    required super.currency,
    required super.outstandingLiability,
    required super.collectionsCount,
  });

  factory CodSummaryModel.fromJson(Map<String, dynamic> json) {
    return CodSummaryModel(
      currency: json['currency'] as String? ?? '',
      outstandingLiability: readDecimal(json['outstanding_cod_liability']),
      collectionsCount: readInt(json['cod_collections_count']),
    );
  }
}
