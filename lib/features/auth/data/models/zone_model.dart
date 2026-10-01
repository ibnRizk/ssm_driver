import '../../../../core/error/exceptions.dart';
import '../../domain/entities/zone.dart';
import 'named_option_json.dart';

/// `GET /zone/list` answers with a bare JSON array of zones.
class ZoneModel extends Zone {
  const ZoneModel({required super.id, required super.name});

  /// Throws [ServerException] when the body isn't a list.
  static List<ZoneModel> listFromJson(dynamic json) => parseNamedOptions(
    json,
    (int id, String name) => ZoneModel(id: id, name: name),
  );
}
