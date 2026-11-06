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
import 'package:marky/features/capture/presentation/providers/clipboard_providers.dart';
import 'package:marky/features/feed/presentation/screens/feed_screen.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ─── Fake Repository ───────────────────────────────────────────────────

/// In-memory fake implementation of [BookmarkItemRepository] that supports
/// duplicate detection via URL hash.
class FakeBookmarkItemRepository implements BookmarkItemRepository {
  final List<BookmarkItem> _items = <BookmarkItem>[];

  void setItems(List<BookmarkItem> items) {
    _items
      ..clear()
      ..addAll(items);
  }

  List<BookmarkItem> get items => List<BookmarkItem>.unmodifiable(_items);

  @override
  Future<BookmarkItem?> getById(Id id) async {
    try {
      return _items.firstWhere((BookmarkItem item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async =>
      List<BookmarkItem>.unmodifiable(_items);

  @override
  Future<Id> insert(BookmarkItem entity) async {
    _items.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async => entity.id;

  @override
  Future<void> delete(Id id) async {
    _items.removeWhere((BookmarkItem item) => item.id == id);
  }

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async {
    try {
      return _items.firstWhere(
        (BookmarkItem item) => item.urlHash == urlHash,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async {
    try {
      return _items.firstWhere(
        (BookmarkItem item) => item.canonicalUrl == canonicalUrl,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async {
    try {
      return _items.firstWhere(
        (BookmarkItem item) => item.externalContentId == externalContentId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async {
    return _items
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

/// Builds the [FeedScreen] with the given overrides.
Widget buildFeedScreen({
  required FakeBookmarkItemRepository fakeRepository,
  String? detectedClipboardUrl,
}) {
  return ProviderScope(
    overrides: <Override>[
      bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
      if (detectedClipboardUrl != null)
        clipboardUrlProvider.overrideWith(
          (Ref ref) => ClipboardNotifier()
            ..setDetectedUrl(
              detectedClipboardUrl,
              UrlNormalizationService.instance
                  .computeUrlHash(detectedClipboardUrl),
            ),
        ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: const FeedScreen(),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('ClipboardBanner', () {
    late FakeBookmarkItemRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeBookmarkItemRepository();
      DuplicateDetectionService.initialize(
        repository: fakeRepository,
        normalizationService: UrlNormalizationService.instance,
      );
    });

    tearDown(DuplicateDetectionService.reset);

    testWidgets('shows banner when clipboardUrlProvider has URL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFeedScreen(
          fakeRepository: fakeRepository,
          detectedClipboardUrl: 'https://example.com/article',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Link detected on clipboard'), findsOneWidget);
      expect(find.text('example.com'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('does not show banner when clipboardUrlProvider is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFeedScreen(fakeRepository: fakeRepository),
      );
      await tester.pumpAndSettle();

      expect(find.text('Link detected on clipboard'), findsNothing);
      expect(find.text('Save'), findsNothing);
      expect(find.text('Dismiss'), findsNothing);
    });

    testWidgets('tapping Save adds bookmark and shows success SnackBar', (
      WidgetTester tester,
    ) async {
      const String url = 'https://flutter.dev';

      await tester.pumpWidget(
        buildFeedScreen(
          fakeRepository: fakeRepository,
          detectedClipboardUrl: url,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Link detected on clipboard'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // SnackBar should show success message.
      expect(find.text('Saved'), findsOneWidget);

      // Banner should be dismissed.
      expect(find.text('Link detected on clipboard'), findsNothing);

      // Bookmark should have been added.
      expect(fakeRepository.items.length, 1);
      expect(fakeRepository.items.first.originalUrl, url);
    });

    testWidgets('tapping Dismiss clears banner without saving', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFeedScreen(
          fakeRepository: fakeRepository,
          detectedClipboardUrl: 'https://example.com',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Link detected on clipboard'), findsOneWidget);

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // Banner should be gone.
      expect(find.text('Link detected on clipboard'), findsNothing);

      // No bookmark should have been saved.
      expect(fakeRepository.items, isEmpty);
    });

    testWidgets('Save with duplicate URL shows duplicate SnackBar', (
      WidgetTester tester,
    ) async {
      const String url = 'https://duplicate.test/page';
      final String hash =
          UrlNormalizationService.instance.computeUrlHash(url);

      // Pre-populate repository with a bookmark having the same hash.
      // ignore: avoid_redundant_argument_values
      final BookmarkItem existing = BookmarkItem(
        originalUrl: url,
        canonicalUrl: url,
        urlHash: hash,
        // ignore: avoid_redundant_argument_values
        createdAt: DateTime(2025, 1, 1),
        // ignore: avoid_redundant_argument_values
        updatedAt: DateTime(2025, 1, 1),
      );
      fakeRepository.setItems(<BookmarkItem>[existing]);

      await tester.pumpWidget(
        buildFeedScreen(
          fakeRepository: fakeRepository,
          detectedClipboardUrl: url,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // SnackBar should show duplicate message.
      expect(find.text('Already saved'), findsOneWidget);

      // Banner should be dismissed.
      expect(find.text('Link detected on clipboard'), findsNothing);
    });

    testWidgets(
        'settings disabled prevents banner via null provider state', (
      WidgetTester tester,
    ) async {
      // When clipboard detection is disabled, the lifecycle observer never
      // sets a detected URL, so the provider state remains null. We simulate
      // this by not providing a detectedClipboardUrl override.
      await tester.pumpWidget(
        buildFeedScreen(fakeRepository: fakeRepository),
      );
      await tester.pumpAndSettle();

      expect(find.text('Link detected on clipboard'), findsNothing);
      expect(find.text('Save'), findsNothing);
      expect(find.text('Dismiss'), findsNothing);
    });

    testWidgets('banner shows above empty state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFeedScreen(
          fakeRepository: fakeRepository,
          detectedClipboardUrl: 'https://example.com',
        ),
      );
      await tester.pumpAndSettle();

      // Both banner and empty state should be visible.
      expect(find.text('Link detected on clipboard'), findsOneWidget);
      expect(find.text('No bookmarks yet'), findsOneWidget);
    });

    testWidgets('banner shows above bookmark list', (
      WidgetTester tester,
    ) async {
      // ignore: avoid_redundant_argument_values
      final BookmarkItem bm = BookmarkItem(
        originalUrl: 'https://flutter.dev',
        title: 'Flutter',
        // ignore: avoid_redundant_argument_values
        createdAt: DateTime(2025, 1, 1),
        // ignore: avoid_redundant_argument_values
        updatedAt: DateTime(2025, 1, 1),
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(
        buildFeedScreen(
          fakeRepository: fakeRepository,
          detectedClipboardUrl: 'https://example.com',
        ),
      );
      await tester.pumpAndSettle();

      // Both banner and bookmark list should be visible.
      expect(find.text('Link detected on clipboard'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
    });
  });
}
