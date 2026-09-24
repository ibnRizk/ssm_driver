import 'package:equatable/equatable.dart';

/// `GET /delivery-man/incentive-summary` — earned incentives and progress to
/// the next reward. [earnedAmount] is a decimal string, like all money here.
class IncentiveSummary extends Equatable {
  final String currency;
  final int completedDeliveries;
  final int completedTowardNextReward;
  final int deliveriesRequiredForNextReward;
  final String earnedAmount;
  final int awardsCount;

  const IncentiveSummary({
    required this.currency,
    required this.completedDeliveries,
    required this.completedTowardNextReward,
    required this.deliveriesRequiredForNextReward,
    required this.earnedAmount,
    required this.awardsCount,
  });

  @override
  List<Object?> get props => [
    currency,
    completedDeliveries,
    completedTowardNextReward,
    deliveriesRequiredForNextReward,
    earnedAmount,
    awardsCount,
  ];
}
