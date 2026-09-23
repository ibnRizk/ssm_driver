/// Matches the API contract's `identity_type` values exactly.
enum IdentityType {
  nid('nid'),
  passport('passport'),
  drivingLicense('driving_license');

  final String apiValue;
  const IdentityType(this.apiValue);
}
