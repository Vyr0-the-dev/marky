import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/automation/data/automation_rule_providers.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';
import 'package:marky/features/automation/presentation/automation_rules_screen.dart';
import 'package:marky/features/automation/presentation/automations_tour_sheet.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _createTestApp({
  List<AutomationRule> rules = const <AutomationRule>[],
}) {
  return ProviderScope(
    overrides: <Override>[
      automationRulesProvider.overrideWith(
        (ref) => Stream<List<AutomationRule>>.value(rules),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AutomationRulesScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Automations Tour', () {
    testWidgets('auto-triggers on first visit and saves persistence flag', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      expect(await hasSeenAutomationsTour(), isFalse);

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsOneWidget);
      expect(find.text('Welcome to Automations'), findsOneWidget);
      expect(await hasSeenAutomationsTour(), isTrue);
    });

    testWidgets('does not auto-trigger when tour was already seen', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        automationsTourSeenKey: true,
      });
      expect(await hasSeenAutomationsTour(), isTrue);

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsNothing);
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    });

    testWidgets('manually re-triggers via AppBar help icon when already seen', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        automationsTourSeenKey: true,
      });

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsNothing);

      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsOneWidget);
      expect(find.text('Welcome to Automations'), findsOneWidget);
    });

    testWidgets('manually triggers via Guide button in empty state card', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        automationsTourSeenKey: true,
      });

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsNothing);

      await tester.tap(find.widgetWithText(TextButton, 'Automation guide'));
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsOneWidget);
    });

    testWidgets('navigates through all 4 steps and finishes with Got it button', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsOneWidget);

      // Step 1: Welcome to Automations
      expect(find.text('Welcome to Automations'), findsOneWidget);
      expect(
        find.byKey(const Key('automations_tour_skip_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('automations_tour_back_button')),
        findsNothing,
      );

      // Step 1 -> Step 2: Powerful Triggers
      await tester.tap(find.byKey(const Key('automations_tour_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Powerful Triggers'), findsOneWidget);
      expect(
        find.byKey(const Key('automations_tour_back_button')),
        findsOneWidget,
      );

      // Step 2 -> Back -> Step 1
      await tester.tap(find.byKey(const Key('automations_tour_back_button')));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Automations'), findsOneWidget);

      // Step 1 -> Step 2
      await tester.tap(find.byKey(const Key('automations_tour_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Powerful Triggers'), findsOneWidget);

      // Step 2 -> Step 3: Instant Actions
      await tester.tap(find.byKey(const Key('automations_tour_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Instant Actions'), findsOneWidget);

      // Step 3 -> Step 4: Priority & Testing
      await tester.tap(find.byKey(const Key('automations_tour_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Priority & Testing'), findsOneWidget);
      expect(
        find.byKey(const Key('automations_tour_next_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('automations_tour_finish_button')),
        findsOneWidget,
      );
      expect(find.text('Got it'), findsOneWidget);

      // Finish / Dismiss
      await tester.tap(find.byKey(const Key('automations_tour_finish_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsNothing);
      expect(await hasSeenAutomationsTour(), isTrue);
    });

    testWidgets('dismisses tour when Skip button is tapped', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsOneWidget);

      await tester.tap(find.byKey(const Key('automations_tour_skip_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsNothing);
      expect(await hasSeenAutomationsTour(), isTrue);
    });

    testWidgets('dismisses tour when Close icon button is tapped', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsOneWidget);

      await tester.tap(find.byKey(const Key('automations_tour_close_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsNothing);
    });

    testWidgets('showAutomationsTour helper launches sheet directly', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () => showAutomationsTour(context),
                  child: const Text('Open Tour'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsNothing);

      await tester.tap(find.text('Open Tour'));
      await tester.pumpAndSettle();

      expect(find.byType(AutomationsTourSheet), findsOneWidget);
      expect(find.text('Welcome to Automations'), findsOneWidget);
    });
  });
}
