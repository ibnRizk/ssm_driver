import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_readers.dart';

/// Parses the registration lookups (`/zone/list`, `/vehicle/list`): a bare
/// JSON array of `{ id, name, display_name }`. `display_name` (translated
/// per `Accept-Language`) wins over `name`; an entry without a usable id or
/// name can't be selected, so it's skipped.
///
/// Throws [ServerException] when the body isn't a list.
List<T> parseNamedOptions<T>(
  dynamic json,
  T Function(int id, String name) build,
) {
  if (json is! List) throw const ServerException();
  return <T>[
    for (final dynamic entry in json)
      if (entry is Map)
        if (_option(entry) case (final int id, final String name))
          build(id, name),
  ];
}

(int, String)? _option(Map<dynamic, dynamic> entry) {
  final int id = readInt(entry['id']);
  final String? name = _text(entry['display_name']) ?? _text(entry['name']);
  return id > 0 && name != null ? (id, name) : null;
}

String? _text(dynamic value) =>
    value is String && value.trim().isNotEmpty ? value.trim() : null;
