import 'package:flutter_test/flutter_test.dart';
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
