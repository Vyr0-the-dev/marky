import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/services/duplicate_detection_service.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/features/capture/presentation/providers/share_intent_providers.dart';
import 'package:marky/features/capture/presentation/screens/capture_screen.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/main.dart';
import 'package:marky/shared/models/bookmark_item.dart';

import '../../../fakes/fake_app_settings_repository.dart';

// ─── Fake Bookmark Repository ──────────────────────────────────────────

class _FakeBookmarkRepository implements BookmarkItemRepository {
  @override
  Future<BookmarkItem?> getById(Id id) async => null;

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<Id> insert(BookmarkItem entity) async => entity.id;

  @override
  Future<Id> update(BookmarkItem entity) async => entity.id;

  @override
  Future<void> delete(Id id) async {}

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
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

// ─── Widget Tests ──────────────────────────────────────────────────────

void main() {
  group('Share intent flow', () {
    late FakeAppSettingsRepository fakeSettingsRepo;
    late _FakeBookmarkRepository fakeBookmarkRepo;

    setUp(() {
      fakeSettingsRepo = FakeAppSettingsRepository();
      fakeBookmarkRepo = _FakeBookmarkRepository();
      DuplicateDetectionService.initialize(
        repository: fakeBookmarkRepo,
        normalizationService: UrlNormalizationService.instance,
      );
    });

    tearDown(DuplicateDetectionService.reset);

    Widget buildApp({String? shareUrl}) {
      return ProviderScope(
        overrides: <Override>[
          appSettingsProvider.overrideWith(
            (Ref ref) => AppSettingsNotifier(repository: fakeSettingsRepo),
          ),
          bookmarkRepositoryProvider.overrideWithValue(fakeBookmarkRepo),
          shareIntentInitialUrlProvider.overrideWith(
            (Ref ref) async => shareUrl,
          ),
          shareIntentStreamProvider.overrideWith(
            (Ref ref) => const Stream<String?>.empty(),
          ),
        ],
        child: const MarkyApp(),
      );
    }

    testWidgets(
      'cold-start share intent navigates to Add Link, '
      'pre-fills URL, and auto-saves',
      (WidgetTester tester) async {
        const String testUrl = 'https://example.com/article';

        await tester.pumpWidget(buildApp(shareUrl: testUrl));
        await tester.pumpAndSettle();

        // Verify navigation to Add Link screen.
        expect(find.text('Add Link'), findsOneWidget);

        // Verify the CaptureScreen received the shared URL.
        final CaptureScreen captureScreen = tester.widget<CaptureScreen>(
          find.byType(CaptureScreen),
        );
        expect(captureScreen.initialUrl, testUrl);

        // The URL was pre-filled and auto-saved; verify success SnackBar.
        expect(find.text('Link saved'), findsOneWidget);
      },
    );

    testWidgets(
      'no navigation when cold-start share intent has no URL',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Should remain on the Feed screen.
        expect(find.text('Feed'), findsOneWidget);
        expect(find.text('Add Link'), findsNothing);
      },
    );
  });
}
