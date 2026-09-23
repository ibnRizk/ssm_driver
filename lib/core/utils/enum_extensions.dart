import 'enums.dart';
import 'values/strings.dart';

extension LanguageCodeExtension on LanguageCode {
  static LanguageCode fromString(String value) =>
      LanguageCode.values.firstWhere(
        (LanguageCode element) => element.name == value,
        orElse: () => LanguageCode.en,
      );

  String get displayName {
    switch (this) {
      case LanguageCode.en:
        return Strings.english;
      case LanguageCode.ar:
        return Strings.arabic;
    }
  }

  /// The language's own name, shown untranslated in the language picker so
  /// users can find their language whatever the current UI language is.
  String get nativeName => switch (this) {
    LanguageCode.en => 'English',
    LanguageCode.ar => 'العربية',
  };
}

extension UserTypeExtension on UserType {
  static UserType fromString(String value) => UserType.values.firstWhere(
    (UserType element) => element.name == value,
    orElse: () => UserType.guest,
  );
}

extension UserCycleExtension on UserCycle {
  static UserCycle fromString(String value) => UserCycle.values.firstWhere(
    (UserCycle element) => element.name == value,
    orElse: () => UserCycle.firstOpen,
  );
}
