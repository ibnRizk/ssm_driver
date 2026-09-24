/// The editable part of the Driver's profile
/// (`PATCH /delivery-man/profile`).
///
/// A null [password] keeps the current one.
class ProfileUpdate {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? password;

  const ProfileUpdate({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.password,
  });
}
