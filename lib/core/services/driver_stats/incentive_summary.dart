import 'package:equatable/equatable.dart';

/// The incentive rule the API doesn't send: "5 SAR for every 10 qualifying
/// completed deliveries" (API docs §12). The amount is a decimal string like
/// every other money value. Update here if the backend rule changes.
abstract final class IncentiveRule {
  static const String rewardAmount = '5.00';
}

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

  /// Deliveries each reward takes (10 under the current rule). The API sends
  /// the progress and the *remaining* count, so the target is their sum —
  /// e.g. 8 toward + 2 required → 10. `0` when the server sent neither.
  int get deliveriesPerReward =>
      completedTowardNextReward + deliveriesRequiredForNextReward;

  /// Share of the way to the next reward, clamped to 0–1. A count ratio,
  /// not money, so a double is fine here.
  double get progressToNextReward {
    final int target = deliveriesPerReward;
    if (target <= 0) return 0;
    return (completedTowardNextReward / target).clamp(0.0, 1.0);
  }

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
