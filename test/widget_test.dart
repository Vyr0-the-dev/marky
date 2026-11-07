import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marky/app/marky_app.dart';
import 'package:marky/app/routing/app_router.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/search/data/search_query_providers.dart';
import 'package:marky/features/search/domain/search_query.dart';
import 'package:marky/features/search/domain/search_query_repository.dart';
import 'package:marky/features/share_intent/data/share_intent_providers.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';
import 'package:marky/shared/widgets/marky_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_notification_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'marky_onboarding_shown': true,
    });
  });
  Widget wrap({String? initialLocation}) {
    return ProviderScope(
      overrides: <Override>[
        ...testAppSettingsOverrides(),
        markyRouterProvider.overrideWith(
          (ref) => MarkyAppRouter.build(initialLocation: initialLocation),
        ),
        bookmarkFeedProvider.overrideWith(
          (ref, query) => Stream<List<Bookmark>>.value(<Bookmark>[]),
        ),
        bookmarkCountProvider.overrideWith((ref) async => 0),
        bookmarkRepositoryProvider.overrideWithValue(_NoOpBookmarkRepository()),
        searchQueryRepositoryProvider.overrideWithValue(
          _NoOpSearchQueryRepository(),
        ),
        shareIntentInitialTextProvider.overrideWith((ref) async => null),
        shareIntentTextStreamProvider.overrideWith(
          (ref) => const Stream<String?>.empty(),
        ),
        tagRepositoryProvider.overrideWithValue(_NoOpTagRepository()),
        tagsProvider.overrideWith(
          (ref) => Stream<List<Tag>>.value(<Tag>[]),
        ),
        bookmarkCollectionsProvider.overrideWith(
          (ref) => Stream<List<BookmarkCollection>>.value(
            <BookmarkCollection>[],
          ),
        ),
        notificationServiceProvider.overrideWithValue(FakeNotificationService()),
      ],
      child: const MarkyApp(),
    );
  }

  testWidgets('renders the home shell', (WidgetTester tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Marky'), findsOneWidget);
    expect(find.byType(MarkyBottomNav), findsOneWidget);
  });

  testWidgets('can open Add tab through the router', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(initialLocation: Routes.add));
    await tester.pumpAndSettle();

    expect(find.text('Add'), findsWidgets);
    expect(find.text('Paste, share, or type a link'), findsOneWidget);
  });
}

class _NoOpBookmarkRepository implements BookmarkRepository {
  @override
  Future<Bookmark> save(Bookmark bookmark) async => bookmark;
  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) async => bookmarks;
  @override
  Future<Bookmark?> getById(int id) async => null;
  @override
  Future<List<Bookmark>> getByIds(List<int> ids) async => <Bookmark>[];
  @override
  Future<bool> delete(int id) async => false;
  @override
  Future<int> deleteAll(List<int> ids) async => 0;
  @override
  Future<Bookmark?> findByUrlHash(String urlHash) async => null;
  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) async => null;
  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) async =>
      null;
  @override
  Future<int> countAll() async => 0;
  @override
  Future<int> count(BookmarkFeedQuery query) async => 0;
  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => <Bookmark>[];
  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      Stream<List<Bookmark>>.value(<Bookmark>[]);
  @override
  Stream<Bookmark?> watchById(int id) => Stream<Bookmark?>.value(null);
  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async =>
      <Bookmark>[];
}

class _NoOpSearchQueryRepository implements SearchQueryRepository {
  @override
  Future<SearchQuery> recordRecent(String query) async {
    final DateTime now = DateTime(2026);
    return SearchQuery(
      query: query,
      normalizedQuery: SearchQuery.normalize(query),
      createdAt: now,
      lastUsedAt: now,
    );
  }

  @override
  Future<SearchQuery> saveSearch(String query, {String? label}) async {
    final DateTime now = DateTime(2026);
    return SearchQuery(
      query: query,
      normalizedQuery: SearchQuery.normalize(query),
      label: label,
      isSaved: true,
      createdAt: now,
      lastUsedAt: now,
      savedAt: now,
    );
  }

  @override
  Future<SearchQuery?> findByNormalizedQuery(String normalizedQuery) async =>
      null;
  @override
  Future<List<SearchQuery>> getRecent({int limit = 10}) async =>
      <SearchQuery>[];
  @override
  Future<List<SearchQuery>> getSaved() async => <SearchQuery>[];
  @override
  Future<void> removeRecent(int id) async {}
  @override
  Future<void> unsave(int id) async {}
  @override
  Future<void> clearRecent() async {}
  @override
  Stream<List<SearchQuery>> watchRecent({int limit = 10}) =>
      Stream<List<SearchQuery>>.value(<SearchQuery>[]);
  @override
  Stream<List<SearchQuery>> watchSaved() =>
      Stream<List<SearchQuery>>.value(<SearchQuery>[]);
}

class _NoOpTagRepository implements TagRepository {
  @override
  Future<Tag> save(Tag tag) async => tag;
  @override
  Future<Tag> createFromName(String name, {int? colorArgb, String? icon}) {
    throw UnimplementedError();
  }

  @override
  Future<Tag?> getById(int id) async => null;
  @override
  Future<Tag?> findBySlug(String slug) async => null;
  @override
  Future<List<Tag>> getAll() async => <Tag>[];
  @override
  Future<List<Tag>> getByIds(List<int> ids) async => <Tag>[];
  @override
  Future<bool> delete(int id) async => false;
  @override
  Future<void> incrementUsageCount(int tagId) async {}
  @override
  Future<void> decrementUsageCount(int tagId) async {}
  @override
  Future<int> recomputeUsageCount(int tagId) async => 0;
  @override
  Future<Map<int, int>> recomputeAllUsageCounts() async => <int, int>{};
  @override
  Stream<List<Tag>> watchAll() => Stream<List<Tag>>.value(<Tag>[]);
  @override
  Stream<Tag?> watchById(int id) => Stream<Tag?>.value(null);
}
