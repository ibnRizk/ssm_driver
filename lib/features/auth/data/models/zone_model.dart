import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/zone.dart';

/// `GET /zone/list` answers with a bare JSON array of zones.
class ZoneModel extends Zone {
  const ZoneModel({required super.id, required super.name});

  /// Null for an entry without a usable id or name — it can't be selected.
  static ZoneModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final int id = readInt(json['id']);
    final String? name = _text(json['display_name']) ?? _text(json['name']);
    if (id <= 0 || name == null) return null;
    return ZoneModel(id: id, name: name);
  }

  /// Throws [ServerException] when the body isn't a list.
  static List<ZoneModel> listFromJson(dynamic json) {
    if (json is! List) throw const ServerException();
    return json.map(tryFromJson).whereType<ZoneModel>().toList(growable: false);
  }

  static String? _text(dynamic value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;
}
