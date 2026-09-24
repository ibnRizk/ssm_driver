import '../../utils/json_readers.dart';
import 'incentive_summary.dart';

class IncentiveSummaryModel extends IncentiveSummary {
  const IncentiveSummaryModel({
    required super.currency,
    required super.completedDeliveries,
    required super.completedTowardNextReward,
    required super.deliveriesRequiredForNextReward,
    required super.earnedAmount,
    required super.awardsCount,
  });

  factory IncentiveSummaryModel.fromJson(Map<String, dynamic> json) {
    return IncentiveSummaryModel(
      currency: json['currency'] as String? ?? '',
      completedDeliveries: readInt(json['completed_deliveries_count']),
      completedTowardNextReward: readInt(json['completed_toward_next_reward']),
      deliveriesRequiredForNextReward: readInt(
        json['deliveries_required_for_next_reward'],
      ),
      earnedAmount: readDecimal(json['earned_incentive_amount']),
      awardsCount: readInt(json['awards_count']),
    );
  }
}
