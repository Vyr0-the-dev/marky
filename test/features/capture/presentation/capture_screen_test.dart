import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/services/duplicate_detection_service.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/features/capture/presentation/screens/capture_screen.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ─── Fake Repository ───────────────────────────────────────────────────

/// In-memory fake implementation of [BookmarkItemRepository] for testing.
class FakeBookmarkItemRepository implements BookmarkItemRepository {
  final Map<int, BookmarkItem> _items = <int, BookmarkItem>{};
  int _nextId = 1;

  @override
  Future<BookmarkItem?> getById(Id id) async => _items[id];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => _items.values.toList();

  @override
  Future<Id> insert(BookmarkItem entity) async {
    final int id = _nextId++;
    entity.id = id;
    _items[id] = entity;
    return id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    _items[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _items.remove(id);
  }

  @override
  Future<void> clear() async {
    _items.clear();
    _nextId = 1;
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async {
    for (final BookmarkItem item in _items.values) {
      if (item.urlHash == urlHash) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async {
    for (final BookmarkItem item in _items.values) {
      if (item.canonicalUrl == canonicalUrl) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async {
    for (final BookmarkItem item in _items.values) {
      if (item.externalContentId == externalContentId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async {
    return _items.values
        .where((BookmarkItem item) => item.duplicateGroupId == groupId)
        .toList();
  }

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

// ─── Test Helpers ──────────────────────────────────────────────────────

/// Builds the [CaptureScreen] inside a [MaterialApp] with the Marky dark
/// theme and a [ProviderScope] that overrides the bookmark repository with
/// the given [fakeRepository].
Widget buildCaptureScreen(FakeBookmarkItemRepository fakeRepository) {
  return ProviderScope(
    overrides: <Override>[
      bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: const CaptureScreen(),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('CaptureScreen', () {
    late FakeBookmarkItemRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeBookmarkItemRepository();
      DuplicateDetectionService.initialize(
        repository: fakeRepository,
        normalizationService: UrlNormalizationService.instance,
      );
    });

    tearDown(DuplicateDetectionService.reset);

    testWidgets('renders app bar title "Add Link"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCaptureScreen(fakeRepository));
      await tester.pumpAndSettle();

      expect(find.text('Add Link'), findsOneWidget);
    });

    testWidgets('renders URL text field with hint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCaptureScreen(fakeRepository));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Paste or type a URL...'), findsOneWidget);
    });

    testWidgets('entering URL enables Save Link button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCaptureScreen(fakeRepository));
      await tester.pumpAndSettle();

      final Finder saveButton = find.widgetWithText(ElevatedButton, 'Save Link');
      final ElevatedButton button =
          tester.widget<ElevatedButton>(saveButton);
      expect(button.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'https://example.com');
      await tester.pumpAndSettle();

      final ElevatedButton enabledButton =
          tester.widget<ElevatedButton>(saveButton);
      expect(enabledButton.onPressed, isNotNull);
    });

    testWidgets('tapping Save Link with valid URL shows success SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCaptureScreen(fakeRepository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'https://example.com');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Link'));
      await tester.pumpAndSettle();

      expect(find.text('Link saved'), findsOneWidget);
    });

    testWidgets(
        'tapping Save Link stores bookmark in repository with correct URL',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildCaptureScreen(fakeRepository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'https://example.com');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Link'));
      await tester.pumpAndSettle();

      final List<BookmarkItem> all = await fakeRepository.getAll();
      expect(all.length, 1);
      expect(all.first.originalUrl, 'https://example.com');
    });

    testWidgets('saving duplicate URL shows duplicate SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCaptureScreen(fakeRepository));
      await tester.pumpAndSettle();

      // First save.
      await tester.enterText(find.byType(TextField), 'https://example.com');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Link'));
      await tester.pumpAndSettle();

      // Dismiss the first SnackBar.
      await tester.pump(const Duration(seconds: 4));

      // Second save with same URL.
      await tester.enterText(find.byType(TextField), 'https://example.com');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Link'));
      await tester.pumpAndSettle();

      expect(find.text('Link already saved'), findsOneWidget);
    });

    testWidgets('clear button removes text and disables save', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCaptureScreen(fakeRepository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'https://example.com');
      await tester.pumpAndSettle();

      // Clear button should be visible after text entry.
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('https://example.com'), findsNothing);

      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Link'),
      );
      expect(button.onPressed, isNull);
    });
  });
}
