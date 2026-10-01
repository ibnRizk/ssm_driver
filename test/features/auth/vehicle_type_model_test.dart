import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/exceptions.dart';
import 'package:ssm_driver/features/auth/data/models/vehicle_type_model.dart';

void main() {
  test('parses the documented vehicle list, preferring display_name', () {
    final vehicles = VehicleTypeModel.listFromJson(<dynamic>[
      <String, dynamic>{
        'id': 1,
        'name': 'motorcycle',
        'display_name': 'دراجة نارية',
      },
      <String, dynamic>{'id': 2, 'name': 'car', 'display_name': 'سيارة'},
    ]);

    expect(vehicles, const <VehicleTypeModel>[
      VehicleTypeModel(id: 1, name: 'دراجة نارية'),
      VehicleTypeModel(id: 2, name: 'سيارة'),
    ]);
  });

  test('a non-list body is a server error', () {
    expect(
      () => VehicleTypeModel.listFromJson(<String, dynamic>{'data': <dynamic>[]}),
      throwsA(isA<ServerException>()),
    );
  });
}
