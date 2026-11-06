import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/l10n/app_localizations.dart';

void main() {
  testWidgets('provides app localization delegates and supported locales', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) {
            return Text(AppLocalizations.of(context)!.appTitle);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final MaterialApp materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );

    expect(materialApp.supportedLocales, AppLocalizations.supportedLocales);
    expect(materialApp.localizationsDelegates,
        contains(AppLocalizations.delegate));
    expect(find.text('Marky'), findsOneWidget);
  });
}
