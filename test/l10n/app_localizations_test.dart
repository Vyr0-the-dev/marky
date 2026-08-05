import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    test('supports English and Turkish locales', () {
      expect(
        AppLocalizations.supportedLocales,
        const <Locale>[Locale('en'), Locale('tr')],
      );
    });

    test('loads English and Turkish navigation labels', () async {
      final AppLocalizations english = await AppLocalizations.delegate.load(
        const Locale('en'),
      );
      final AppLocalizations turkish = await AppLocalizations.delegate.load(
        const Locale('tr'),
      );

      expect(english.navigationFeed, 'Feed');
      expect(english.navigationSearch, 'Search');
      expect(turkish.navigationFeed, 'Akış');
      expect(turkish.navigationSearch, 'Ara');
    });
  });
}
