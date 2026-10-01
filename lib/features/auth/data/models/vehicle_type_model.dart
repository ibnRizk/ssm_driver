import '../../../../core/error/exceptions.dart';
import '../../domain/entities/vehicle_type.dart';
import 'named_option_json.dart';

/// `GET /vehicle/list` answers with a bare JSON array of vehicle types.
class VehicleTypeModel extends VehicleType {
  const VehicleTypeModel({required super.id, required super.name});

  /// Throws [ServerException] when the body isn't a list.
  static List<VehicleTypeModel> listFromJson(dynamic json) => parseNamedOptions(
    json,
    (int id, String name) => VehicleTypeModel(id: id, name: name),
  );
}
