import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/features/orders/data/models/active_offer_model.dart';
import 'package:ssm_driver/features/orders/data/models/work_transition_model.dart';
import 'package:ssm_driver/features/orders/domain/entities/current_work.dart';

import 'orders_test_fakes.dart';

void main() {
  test('parses the documented active-offer object', () {
    expect(ActiveOfferModel.fromJson(activeOfferJson()), sampleOffer);
  });

  test('keeps the COD amount as the exact decimal string', () {
    final ActiveOfferModel offer = ActiveOfferModel.fromJson(
      activeOfferJson()..['cod_amount'] = '0.10',
    );

    expect(offer.codAmount, '0.10');
  });

  test('accepts the delivery address as an address object', () {
    final ActiveOfferModel offer = ActiveOfferModel.fromJson(
      activeOfferJson()
        ..['delivery_address'] = <String, dynamic>{'address': 'Olaya St 12'},
    );

    expect(offer.deliveryAddress, 'Olaya St 12');
  });

  test('missing fields fall back instead of throwing', () {
    final ActiveOfferModel offer = ActiveOfferModel.fromJson(<String, dynamic>{
      'assignment_id': '7',
      'remaining_seconds': -3,
    });

    expect(offer.assignmentId, 7);
    expect(offer.remainingSeconds, 0);
    expect(offer.distanceMeters, isNull);
    expect(offer.isCashOnDelivery, isFalse);
  });

  test('parses a lifecycle response, including a replay', () {
    final WorkTransitionModel transition =
        WorkTransitionModel.fromJson(<String, dynamic>{
          'message': 'Delivery completed.',
          'order_id': 9001,
          'ssm_status': 'delivered',
          'ssm_status_version': 7,
          'idempotent_replay': true,
        });

    expect(
      transition,
      const WorkTransitionModel(
        orderId: 9001,
        status: WorkStatus.delivered,
        statusVersion: 7,
        isReplay: true,
      ),
    );
  });
}
