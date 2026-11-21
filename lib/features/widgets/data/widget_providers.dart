import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/widgets/domain/widget_feed_snapshot_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FutureProvider<SharedPreferences> sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((Ref ref) {
  return SharedPreferences.getInstance();
});

final FutureProvider<WidgetFeedSnapshotService>
    widgetFeedSnapshotServiceProvider =
    FutureProvider<WidgetFeedSnapshotService>((Ref ref) async {
  final SharedPreferences preferences =
      await ref.watch(sharedPreferencesProvider.future);
  return WidgetFeedSnapshotService(
    bookmarkRepository: ref.watch(bookmarkRepositoryProvider),
    preferences: preferences,
    isTurkish: () {
      final AppLocaleChoice choice = ref.read(localeChoiceProvider);
      if (choice == AppLocaleChoice.tr) return true;
      if (choice == AppLocaleChoice.en) return false;
      return ui.PlatformDispatcher.instance.locale.languageCode
          .toLowerCase()
          .startsWith('tr');
    },
  );
});
