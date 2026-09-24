import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/features/home/data/models/cod_summary_model.dart';
import 'package:ssm_driver/features/home/data/models/incentive_summary_model.dart';

import 'home_test_fakes.dart';

void main() {
  test('parses the documented COD summary', () {
    final CodSummaryModel model = CodSummaryModel.fromJson(<String, dynamic>{
      'currency': 'SAR',
      'outstanding_cod_liability': '250.00',
      'cod_collections_count': 2,
    });

    expect(model, sampleCod);
  });

  test('parses the documented incentive summary', () {
    final IncentiveSummaryModel model =
        IncentiveSummaryModel.fromJson(<String, dynamic>{
          'currency': 'SAR',
          'completed_deliveries_count': 18,
          'completed_toward_next_reward': 8,
          'deliveries_required_for_next_reward': 2,
          'earned_incentive_amount': '5.00',
          'awards_count': 1,
        });

    expect(model, sampleIncentive);
  });

  test('missing money falls back to a zero decimal string', () {
    final CodSummaryModel model = CodSummaryModel.fromJson(<String, dynamic>{
      'cod_collections_count': '3',
    });

    expect(model.outstandingLiability, '0.00');
    expect(model.collectionsCount, 3);
  });
}
