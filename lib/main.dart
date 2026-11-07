import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/marky_app.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/settings/app_settings_repository.dart';
import 'package:marky/app/startup/app_startup_coordinator.dart';
import 'package:marky/core/database/database_providers.dart';
import 'package:marky/features/share_intent/presentation/share_overlay_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> shareOverlayMain() => runShareOverlayApp();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).catchError((Object _) {}),
  );

  final (
    SharedPreferencesAppSettingsRepository settingsRepository,
    ({Isar isar, List<Override> overrides}) databaseBootstrap,
  ) = await (
    SharedPreferences.getInstance().then((SharedPreferences prefs) async {
      final SharedPreferencesAppSettingsRepository repo =
          SharedPreferencesAppSettingsRepository(prefs);
      await repo.load();
      return repo;
    }),
    markyDatabaseBootstrap(),
  ).wait;

  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      ...databaseBootstrap.overrides,
      ...appSettingsBootstrapOverrides(settingsRepository),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MarkyApp(),
    ),
  );

  unawaited(
    container
        .read(appStartupCoordinatorProvider)
        .runPostLaunchStartup(settingsRepository.current),
  );
}
