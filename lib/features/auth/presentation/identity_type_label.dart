import '../../../core/utils/values/strings.dart';
import '../domain/entities/identity_type.dart';

/// Localized display name — shared by registration and the profile screens.
extension IdentityTypeLabel on IdentityType {
  String get label => switch (this) {
    IdentityType.nid => Strings.authIdentityTypeNid,
    IdentityType.passport => Strings.authIdentityTypePassport,
    IdentityType.drivingLicense => Strings.authIdentityTypeDrivingLicense,
  };
}
