import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/routing/app_router.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/automation/domain/repositories/automation_rule_repository.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/services/share_intent_handler.dart';
import 'package:marky/features/capture/presentation/providers/share_intent_providers.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/feed/presentation/screens/feed_screen.dart';
import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/main.dart';
import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/automation_rule.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/note.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:marky/shared/models/tag.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FAKE REPOSITORIES
// ═══════════════════════════════════════════════════════════════════════════

/// Minimal fake bookmark repository for smoke tests.
class _FakeBookmarkRepository implements BookmarkItemRepository {
  @override
  Future<BookmarkItem?> getById(int id) async => null;
  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => <BookmarkItem>[];
  @override
  Future<int> insert(BookmarkItem entity) async => 0;
  @override
  Future<int> update(BookmarkItem entity) async => 0;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> clear() async {}
  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;
  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;
  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async => null;
  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => <BookmarkItem>[];
  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => <BookmarkItem>[];
  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => <BookmarkItem>[];
  @override
  Future<List<BookmarkItem>> getByCollectionId(int collectionId, {int? offset, int? limit}) async => <BookmarkItem>[];
  @override
  Future<List<BookmarkItem>> getByTagId(int tagId, {int? offset, int? limit}) async => <BookmarkItem>[];
  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

/// Minimal fake tag repository for smoke tests.
class _FakeTagRepository implements TagRepository {
  @override
  Future<List<Tag>> getAll() async => <Tag>[];
  @override
  Future<Tag?> getById(int id) async => null;
  @override
  Future<Tag?> getBySlug(String slug) async => null;
  @override
  Future<int> insert(Tag entity) async => 0;
  @override
  Future<int> update(Tag entity) async => 0;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> clear() async {}
}

/// Minimal fake collection repository for smoke tests.
class _FakeCollectionRepository implements CollectionRepository {
  @override
  Future<List<BookmarkCollection>> getAll() async => <BookmarkCollection>[];
  @override
  Future<BookmarkCollection?> getById(int id) async => null;
  @override
  Future<BookmarkCollection?> getBySlug(String slug) async => null;
  @override
  Future<int> insert(BookmarkCollection entity) async => 0;
  @override
  Future<int> update(BookmarkCollection entity) async => 0;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> clear() async {}
}

/// Minimal fake note repository for smoke tests.
class _FakeNoteRepository implements NoteRepository {
  @override
  Future<List<Note>> getAll() async => <Note>[];
  @override
  Future<Note?> getById(int id) async => null;
  @override
  Future<List<Note>> getByBookmarkId(int bookmarkId) async => <Note>[];
  @override
  Future<int> insert(Note entity) async => 0;
  @override
  Future<int> update(Note entity) async => 0;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> clear() async {}
}

/// Minimal fake reminder repository for smoke tests.
class _FakeReminderRepository implements ReminderRepository {
  @override
  Future<List<Reminder>> getAll() async => <Reminder>[];
  @override
  Future<Reminder?> getById(int id) async => null;
  @override
  Future<List<Reminder>> getByBookmarkId(int bookmarkId) async => <Reminder>[];
  @override
  Future<List<Reminder>> getPending() async => <Reminder>[];

  Future<List<Reminder>> getOverdue() async => <Reminder>[];
  @override
  Future<int> insert(Reminder entity) async => 0;
  @override
  Future<int> update(Reminder entity) async => 0;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> clear() async {}
}

/// Minimal fake automation rule repository for smoke tests.
class _FakeAutomationRuleRepository implements AutomationRuleRepository {
  @override
  Future<List<AutomationRule>> getAll() async => <AutomationRule>[];
  @override
  Future<List<AutomationRule>> getEnabled() async => <AutomationRule>[];
  @override
  Future<List<AutomationRule>> getByPriority() async => <AutomationRule>[];
  @override
  Future<AutomationRule?> getById(int id) async => null;
  @override
  Future<int> insert(AutomationRule entity) async => 0;
  @override
  Future<int> update(AutomationRule entity) async => 0;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> clear() async {}
}

/// Fake app settings repository for smoke tests.
class _FakeAppSettingsRepository implements AppSettingsRepository {
  AppSettings? _settings;

  @override
  Future<AppSettings?> getSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }

  @override
  Future<void> deleteSettings() async {
    _settings = null;
  }
}

/// Fake share intent handler for smoke tests.
class _FakeShareIntentHandler implements ShareIntentHandler {
  @override
  Stream<String?> get urlStream => const Stream<String?>.empty();

  @override
  Future<String?> getInitialUrl() async => null;

  Future<void> reset() async {}
}

// ═══════════════════════════════════════════════════════════════════════════
// TEST HELPERS
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildSmokeTestApp() {
  final _FakeAppSettingsRepository fakeSettingsRepo = _FakeAppSettingsRepository();
  final _FakeShareIntentHandler fakeShareHandler = _FakeShareIntentHandler();
  final GoRouter router = AppRouter.createRouter();

  return ProviderScope(
    overrides: <Override>[
      appRouterProvider.overrideWithValue(router),
      bookmarkRepositoryProvider.overrideWithValue(_FakeBookmarkRepository()),
      tagRepositoryProvider.overrideWithValue(_FakeTagRepository()),
      collectionRepositoryProvider.overrideWithValue(_FakeCollectionRepository()),
      noteRepositoryProvider.overrideWithValue(_FakeNoteRepository()),
      reminderRepositoryProvider.overrideWithValue(_FakeReminderRepository()),
      automationRuleRepositoryProvider.overrideWithValue(_FakeAutomationRuleRepository()),
      appSettingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
      appSettingsProvider.overrideWith(
        (Ref ref) => AppSettingsNotifier(repository: fakeSettingsRepo),
      ),
      shareIntentHandlerProvider.overrideWithValue(fakeShareHandler),
    ],
    child: const MarkyApp(),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// TESTS
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  group('MarkyApp smoke test', () {
    testWidgets('mounts without error and shows Feed screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildSmokeTestApp());
      await tester.pumpAndSettle();

      // Verify the app mounted and the feed screen is visible.
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(FeedScreen), findsOneWidget);
    });

    testWidgets('navigates to Search tab via bottom nav', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildSmokeTestApp());
      await tester.pumpAndSettle();

      // Tap the Search tab.
      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      // Search screen should be visible (search bar hint text).
      expect(find.text('Search bookmarks...'), findsOneWidget);
    });

    testWidgets('navigates to Add tab via bottom nav', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildSmokeTestApp());
      await tester.pumpAndSettle();

      // Tap the Add button (center circle button).
      await tester.tap(find.bySemanticsLabel('Add'));
      await tester.pumpAndSettle();

      // Capture screen should be visible.
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('navigates to Collections tab via bottom nav', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildSmokeTestApp());
      await tester.pumpAndSettle();

      // Tap the Collections tab.
      await tester.tap(find.bySemanticsLabel('Collections'));
      await tester.pumpAndSettle();

      // Collections screen empty state should be visible.
      expect(find.text('No collections yet'), findsOneWidget);
    });

    testWidgets('navigates to Profile/Settings tab via bottom nav', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildSmokeTestApp());
      await tester.pumpAndSettle();

      // Tap the Profile tab.
      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();

      // Settings screen should be visible.
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('provides localization delegates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildSmokeTestApp());
      await tester.pumpAndSettle();

      final MaterialApp materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );

      expect(materialApp.supportedLocales, AppLocalizations.supportedLocales);
      expect(
        materialApp.localizationsDelegates,
        contains(AppLocalizations.delegate),
      );
    });

    testWidgets('bottom nav has 5 tabs with correct semantics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildSmokeTestApp());
      await tester.pumpAndSettle();

      // Verify all 5 nav items are present via semantics labels.
      expect(find.bySemanticsLabel('Feed'), findsOneWidget);
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
      expect(find.bySemanticsLabel('Add'), findsOneWidget);
      expect(find.bySemanticsLabel('Collections'), findsOneWidget);
      expect(find.bySemanticsLabel('Profile'), findsOneWidget);
    });
  });
}
