import 'package:actualia/utils/locales.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  test('Locales dictionary matches actual locales', () {
    expect(LOCALES.length, equals(AppLocalizations.supportedLocales.length));
    for (var l in LOCALES.keys) {
      expect(
          AppLocalizations.supportedLocales
              .where((loc) => loc.languageCode == l)
              .length,
          equals(1));
    }
  });
}
