import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/features/auth/data/models/zone_model.dart';

void main() {
  test('parses the bare zone array', () {
    final zones = ZoneModel.listFromJson(<dynamic>[
      <String, dynamic>{'id': 1, 'name': 'Riyadh', 'status': 1},
      <String, dynamic>{'id': 2, 'name': 'Jeddah', 'status': 1},
    ]);

    expect(zones, const <ZoneModel>[
      ZoneModel(id: 1, name: 'Riyadh'),
      ZoneModel(id: 2, name: 'Jeddah'),
    ]);
  });

  test('prefers display_name over name', () {
    final zones = ZoneModel.listFromJson(<dynamic>[
      <String, dynamic>{'id': 1, 'name': 'riyadh', 'display_name': 'الرياض'},
    ]);

    expect(zones.single.name, 'الرياض');
  });

  test('accepts a numeric-string id', () {
    final zones = ZoneModel.listFromJson(<dynamic>[
      <String, dynamic>{'id': '7', 'name': 'Dammam'},
    ]);

    expect(zones.single.id, 7);
  });

  test('skips entries without a usable id or name', () {
    final zones = ZoneModel.listFromJson(<dynamic>[
      <String, dynamic>{'name': 'No id'},
      <String, dynamic>{'id': 3, 'name': '  '},
      'not a zone',
      <String, dynamic>{'id': 4, 'name': 'Kept'},
    ]);

    expect(zones, const <ZoneModel>[ZoneModel(id: 4, name: 'Kept')]);
  });

  test('a non-list body is a server error', () {
    expect(
      () => ZoneModel.listFromJson(<String, dynamic>{'message': 'oops'}),
      throwsA(isA<ServerException>()),
    );
  });
}
