/// Matches the API contract's `identity_type` values exactly.
enum IdentityType {
  nid('nid'),
  passport('passport'),
  drivingLicense('driving_license');

  final String apiValue;
  const IdentityType(this.apiValue);

  /// `null` for a missing or unrecognised value.
  static IdentityType? fromApi(String? value) {
    for (final IdentityType type in values) {
      if (type.apiValue == value) return type;
    }
    return null;
  }
}
