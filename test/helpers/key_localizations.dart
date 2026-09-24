import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/config/locale/app_localizations.dart';
import 'package:ssm_driver/injection_container.dart';

/// Echoes keys back so `Strings.*` resolve without loading `lang/*.json`.
class KeyLocalizations extends AppLocalizations {
  KeyLocalizations() : super(null);

  @override
  String text(String key) => key;
}

/// Registers [KeyLocalizations] for the enclosing test file.
void useKeyLocalizations() {
  setUpAll(() => ServiceLocator.injectAppLocalizations(KeyLocalizations()));
  tearDownAll(() => ServiceLocator.instance.unregister<AppLocalizations>());
}
