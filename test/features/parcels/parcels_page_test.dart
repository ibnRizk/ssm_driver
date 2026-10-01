import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/features/parcels/data/models/parcel_model.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel.dart';

import 'parcels_test_fakes.dart';

void main() {
  test('appending adds the next page after the loaded parcels', () {
    final ParcelsPage first = ParcelsPage(
      parcels: <Parcel>[parcelWithId(1)],
      totalSize: 2,
    );
    final ParcelsPage next = ParcelsPage(
      parcels: <Parcel>[parcelWithId(2)],
      totalSize: 2,
    );

    expect(
      first.appending(next).parcels.map((Parcel p) => p.id),
      <int>[1, 2],
    );
  });

  test('appending skips a parcel that shifted into the next page', () {
    final ParcelsPage first = ParcelsPage(
      parcels: <Parcel>[parcelWithId(1), parcelWithId(2)],
      totalSize: 3,
    );
    final ParcelsPage next = ParcelsPage(
      parcels: <Parcel>[parcelWithId(2), parcelWithId(3)],
      totalSize: 3,
    );

    expect(
      first.appending(next).parcels.map((Parcel p) => p.id),
      <int>[1, 2, 3],
    );
  });

  group('home card summary', () {
    Parcel fromCompany(int id, String? company) => ParcelModel.fromJson(
      <String, dynamic>{
        ...parcelJson(id: id),
        'shipping_company': company == null
            ? null
            : <String, dynamic>{'name': company},
      },
    );

    test('roundSize is the server total', () {
      final ParcelsPage page = ParcelsPage(
        parcels: <Parcel>[parcelWithId(1)],
        totalSize: 7,
      );

      expect(page.roundSize, 7);
    });

    test('roundSize never drops below the loaded parcels', () {
      final ParcelsPage page = ParcelsPage(
        parcels: <Parcel>[parcelWithId(1), parcelWithId(2)],
        totalSize: 1,
      );

      expect(page.roundSize, 2);
    });

    test('names the company when every parcel shares it', () {
      final ParcelsPage page = ParcelsPage(
        parcels: <Parcel>[fromCompany(1, 'FastEx'), fromCompany(2, 'FastEx')],
        totalSize: 2,
      );

      expect(page.singleShippingCompany, 'FastEx');
    });

    test('names no company when parcels are mixed', () {
      final ParcelsPage page = ParcelsPage(
        parcels: <Parcel>[fromCompany(1, 'FastEx'), fromCompany(2, 'Aramex')],
        totalSize: 2,
      );

      expect(page.singleShippingCompany, isNull);
    });

    test('ignores parcels without a company name', () {
      final ParcelsPage page = ParcelsPage(
        parcels: <Parcel>[fromCompany(1, 'FastEx'), fromCompany(2, null)],
        totalSize: 2,
      );

      expect(page.singleShippingCompany, 'FastEx');
    });
  });

  test('appending takes the newer total', () {
    final ParcelsPage first = ParcelsPage(
      parcels: <Parcel>[parcelWithId(1)],
      totalSize: 5,
    );
    final ParcelsPage next = ParcelsPage(
      parcels: <Parcel>[parcelWithId(2)],
      totalSize: 4,
    );

    expect(first.appending(next).totalSize, 4);
  });
}
