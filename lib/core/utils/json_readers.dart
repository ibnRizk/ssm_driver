// Lenient readers for API fields that arrive as either numbers or numeric
// strings. They never throw — a missing or malformed value falls back.

int readInt(dynamic value, {int fallback = 0}) => switch (value) {
  final int n => n,
  final num n => n.toInt(),
  final String s => int.tryParse(s) ?? num.tryParse(s)?.toInt() ?? fallback,
  _ => fallback,
};

double? readDouble(dynamic value) => switch (value) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

/// Money is a decimal *string* in this API ("125.00"). Keep it verbatim so
/// no binary floating-point rounding ever touches an authoritative amount.
String readDecimal(dynamic value, {String fallback = '0.00'}) =>
    switch (value) {
      final String s when s.isNotEmpty => s,
      final num n => n.toString(),
      _ => fallback,
    };
