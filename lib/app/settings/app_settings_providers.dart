import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_repository.dart';

/// The repository used by the notifier. Overridden at bootstrap with
/// a real [SharedPreferencesAppSettingsRepository]; tests and
/// widget-book previews override it with
/// [InMemoryAppSettingsRepository].
///
/// Throwing from the default factory (rather than returning a default
/// in-memory repo) is deliberate: forgetting to override this provider
/// in production is a configuration bug, not a missing feature, and
/// we want it to fail loudly during bootstrap rather than silently
/// losing the user's settings on every restart.
final Provider<AppSettingsRepository> appSettingsRepositoryProvider =
    Provider<AppSettingsRepository>((Ref ref) {
  throw UnimplementedError(
    'appSettingsRepositoryProvider must be overridden at ProviderScope '
    '(bootstrap injects SharedPreferencesAppSettingsRepository).',
  );
});

/// State notifier holding the **current** [AppSettings].
///
/// The initial state is taken from the repository's synchronous
/// [AppSettingsRepository.current] getter — bootstrap awaits
/// [AppSettingsRepository.load] *before* building the ProviderScope,
/// so by the time any UI reads this provider, the load is complete.
///
/// Every mutator method is async for persistence, but the in-memory
/// state update is synchronous so `ref.watch` rebuilds immediately
/// without the UI flickering through a loading state.
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._repository) : super(_repository.current);

  final AppSettingsRepository _repository;

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (state.themeMode == mode) return;
    state = state.copyWith(themeMode: mode);
    await _repository.save(state);
  }

  Future<void> setLocale(AppLocaleChoice locale) async {
    if (state.locale == locale) return;
    state = state.copyWith(locale: locale);
    await _repository.save(state);
  }

  Future<void> setAnimationsEnabled({required bool enabled}) async {
    if (state.animationsEnabled == enabled) return;
    state = state.copyWith(animationsEnabled: enabled);
    await _repository.save(state);
  }

  Future<void> setUnreadReminderCadence(
    UnreadReminderCadence cadence,
  ) async {
    if (state.unreadReminderCadence == cadence) return;
    state = state.copyWith(unreadReminderCadence: cadence);
    await _repository.save(state);
  }

  Future<void> setUnreadReminderTime({
    required int hour,
    required int minute,
  }) async {
    if (state.unreadReminderHour == hour &&
        state.unreadReminderMinute == minute) {
      return;
    }
    state = state.copyWith(
      unreadReminderHour: hour,
      unreadReminderMinute: minute,
    );
    await _repository.save(state);
  }

  Future<void> setUnreadReminderWeekday(int weekday) async {
    if (state.unreadReminderWeekday == weekday) return;
    state = state.copyWith(unreadReminderWeekday: weekday);
    await _repository.save(state);
  }

  Future<void> setUnreadReminderSchedule({
    required UnreadReminderCadence cadence,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    final AppSettings next = state.copyWith(
      unreadReminderCadence: cadence,
      unreadReminderWeekday: weekday,
      unreadReminderHour: hour,
      unreadReminderMinute: minute,
    );
    if (state == next) return;
    state = next;
    await _repository.save(state);
  }

  Future<void> setLeftSwipeAction(SwipeAction action) async {
    if (state.leftSwipeAction == action) return;
    state = state.copyWith(leftSwipeAction: action);
    await _repository.save(state);
  }

  Future<void> setRightSwipeAction(SwipeAction action) async {
    if (state.rightSwipeAction == action) return;
    state = state.copyWith(rightSwipeAction: action);
    await _repository.save(state);
  }

  /// Replaces the whole bag — used by "reset to defaults" in Settings.
  Future<void> replace(AppSettings next) async {
    if (state == next) return;
    state = next;
    await _repository.save(state);
  }
}

/// Primary provider. Exposes the current [AppSettings] as a reactive
/// value. Widgets typically consume one of the [selector]-style
/// providers below rather than the whole bag, so they only rebuild
/// when their slice changes.
final StateNotifierProvider<AppSettingsNotifier, AppSettings>
    appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((Ref ref) {
  final AppSettingsRepository repo = ref.watch(appSettingsRepositoryProvider);
  return AppSettingsNotifier(repo);
});

// ─── Selectors ──────────────────────────────────────────────────────
// Using `select` keeps rebuilds tight.

final Provider<AppThemeMode> themeModeProvider = Provider<AppThemeMode>(
  (Ref ref) =>
      ref.watch(appSettingsProvider.select((AppSettings s) => s.themeMode)),
);

final Provider<AppLocaleChoice> localeChoiceProvider =
    Provider<AppLocaleChoice>(
  (Ref ref) =>
      ref.watch(appSettingsProvider.select((AppSettings s) => s.locale)),
);

final Provider<bool> animationsEnabledProvider = Provider<bool>(
  (Ref ref) => ref.watch(
    appSettingsProvider.select((AppSettings s) => s.animationsEnabled),
  ),
);

final Provider<UnreadReminderCadence> unreadReminderCadenceProvider =
    Provider<UnreadReminderCadence>(
  (Ref ref) => ref.watch(
    appSettingsProvider.select(
      (AppSettings s) => s.unreadReminderCadence,
    ),
  ),
);

final Provider<int> unreadReminderWeekdayProvider = Provider<int>(
  (Ref ref) => ref.watch(
    appSettingsProvider.select(
      (AppSettings s) => s.unreadReminderWeekday,
    ),
  ),
);

final Provider<int> unreadReminderHourProvider = Provider<int>(
  (Ref ref) => ref.watch(
    appSettingsProvider.select(
      (AppSettings s) => s.unreadReminderHour,
    ),
  ),
);

final Provider<int> unreadReminderMinuteProvider = Provider<int>(
  (Ref ref) => ref.watch(
    appSettingsProvider.select(
      (AppSettings s) => s.unreadReminderMinute,
    ),
  ),
);

final Provider<SwipeAction> leftSwipeActionProvider = Provider<SwipeAction>(
  (Ref ref) => ref.watch(
    appSettingsProvider.select((AppSettings s) => s.leftSwipeAction),
  ),
);

final Provider<SwipeAction> rightSwipeActionProvider = Provider<SwipeAction>(
  (Ref ref) => ref.watch(
    appSettingsProvider.select((AppSettings s) => s.rightSwipeAction),
  ),
);

/// Scope-level provider overrides to preload settings before building
/// the app. Usage:
///
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// final repo = SharedPreferencesAppSettingsRepository(prefs);
/// await repo.load();
/// runApp(
///   ProviderScope(
///     overrides: appSettingsBootstrapOverrides(repo),
///     child: const MarkyApp(),
///   ),
/// );
/// ```
List<Override> appSettingsBootstrapOverrides(AppSettingsRepository repo) {
  return <Override>[
    appSettingsRepositoryProvider.overrideWithValue(repo),
  ];
}

/// Test-only helper: builds a ProviderScope with an in-memory
/// repository pre-seeded with [initial]. Keeps widget tests terse.
@visibleForTesting
List<Override> testAppSettingsOverrides({AppSettings? initial}) {
  final InMemoryAppSettingsRepository repo =
      InMemoryAppSettingsRepository(initial: initial);
  return <Override>[
    appSettingsRepositoryProvider.overrideWithValue(repo),
  ];
}
