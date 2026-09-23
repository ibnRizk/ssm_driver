import 'dart:math';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(
    RegExp(' +'),
    ' ',
  ).split(' ').map((str) => str.toCapitalized()).join(' ');
}

extension SaudiPhoneFormat on String {
  /// Normalizes local input (`05XXXXXXXX`, `5XXXXXXXX`) to the international
  /// format the API requires (`+9665XXXXXXXX`). Numbers already typed with a
  /// `+` or `966` country code are kept as-is.
  String toInternationalPhone() {
    final String digits = replaceAll(RegExp(r'\D'), '');
    if (trim().startsWith('+') || digits.startsWith('966')) return '+$digits';
    if (digits.startsWith('0')) return '+966${digits.substring(1)}';
    return '+966$digits';
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension RoundOnlyDouble on double {
  double mRoundDouble(int places) {
    num mod = pow(10.0, places);
    return ((this * mod).round().toDouble() / mod);
  }
}
