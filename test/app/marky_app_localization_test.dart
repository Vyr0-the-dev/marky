import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/features/capture/domain/services/share_intent_handler.dart';
import 'package:marky/features/capture/presentation/providers/share_intent_providers.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/main.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../fakes/fake_app_settings_repository.dart';

void main() {
  group('MarkyApp localization wiring', () {
    late FakeAppSettingsRepository fakeRepo;
    late GoRouter router;
    late ShareIntentHandler shareIntentHandler;

    setUp(() {
      fakeRepo = FakeAppSettingsRepository();
      router = GoRouter(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const SizedBox.shrink(),
          ),
        ],
      );
      shareIntentHandler = ShareIntentHandler(
        mediaStream: const Stream<List<SharedMediaFile>>.empty(),
        initialMediaGetter: () async => const <SharedMediaFile>[],
        reset: () async {},
      );
    });

    testWidgets('provides localization delegates and supported locales', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            appSettingsProvider.overrideWith(
              (Ref ref) => AppSettingsNotifier(repository: fakeRepo),
            ),
            appRouterProvider.overrideWithValue(router),
            shareIntentHandlerProvider.overrideWithValue(shareIntentHandler),
          ],
          child: const MarkyApp(),
        ),
      );
      await tester.pumpAndSettle();

      final MaterialApp materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      final BuildContext context = tester.element(find.byType(MaterialApp));

      expect(materialApp.supportedLocales, AppLocalizations.supportedLocales);
      expect(
        materialApp.localizationsDelegates,
        contains(AppLocalizations.delegate),
      );
      expect(materialApp.onGenerateTitle?.call(context), 'Marky');
    });
  });
}
