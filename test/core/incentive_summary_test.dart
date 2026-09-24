import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/services/driver_stats/incentive_summary.dart';

import 'driver_stats_test_fakes.dart';

IncentiveSummary summary({required int toward, required int required}) =>
    IncentiveSummary(
      currency: 'SAR',
      completedDeliveries: 0,
      completedTowardNextReward: toward,
      deliveriesRequiredForNextReward: required,
      earnedAmount: '0.00',
      awardsCount: 0,
    );

void main() {
  test('the documented example is 8 of 10, not 8 / 2', () {
    // completed_toward 8, required 2 → "required" is what's left.
    expect(sampleIncentive.deliveriesPerReward, 10);
    expect(sampleIncentive.progressToNextReward, closeTo(0.8, 1e-9));
  });

  test('a fresh cycle has no progress', () {
    expect(summary(toward: 0, required: 10).progressToNextReward, 0);
  });

  test('no counts from the server means no progress, not a division error',
      () {
    final IncentiveSummary empty = summary(toward: 0, required: 0);

    expect(empty.deliveriesPerReward, 0);
    expect(empty.progressToNextReward, 0);
  });

  test('progress never exceeds the full bar', () {
    expect(summary(toward: 12, required: -2).progressToNextReward, 1);
  });
}
