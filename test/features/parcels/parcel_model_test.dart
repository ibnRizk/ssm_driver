import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/features/parcels/data/models/parcel_model.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel.dart';

import 'parcels_test_fakes.dart';

void main() {
  test('parses the documented parcel object', () {
    expect(ParcelModel.fromJson(parcelJson()), sampleParcel);
  });

  test('a PREPAID parcel is not cash on delivery', () {
    final ParcelModel parcel = ParcelModel.fromJson(
      parcelJson(paymentType: 'PREPAID'),
    );

    expect(parcel.isCashOnDelivery, isFalse);
  });

  test('maps each documented status', () {
    expect(
      ParcelModel.fromJson(parcelJson(status: 'OUT_FOR_DELIVERY')).status,
      ParcelStatus.outForDelivery,
    );
    expect(
      ParcelModel.fromJson(parcelJson(status: 'DELIVERED')).status,
      ParcelStatus.delivered,
    );
  });

  test('an unknown status is null rather than a guess', () {
    expect(ParcelModel.fromJson(parcelJson(status: 'LOST')).status, isNull);
  });

  test('missing metadata and company fall back to empty values', () {
    final ParcelModel parcel = ParcelModel.fromJson(
      parcelJson()
        ..['metadata'] = null
        ..['shipping_company'] = null,
    );

    expect(parcel.customerNotes, isNull);
    expect(parcel.shippingCompanyName, isEmpty);
  });

  test('keeps the COD amount as the exact decimal string', () {
    expect(ParcelModel.fromJson(parcelJson()).codAmount, '75.50');
  });
}
