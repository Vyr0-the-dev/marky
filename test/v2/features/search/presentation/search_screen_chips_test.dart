import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';
import 'package:marky/features/search/data/search_query_providers.dart';
import 'package:marky/features/search/domain/search_query.dart';
import 'package:marky/features/search/domain/search_query_repository.dart';
import 'package:marky/features/search/presentation/search_screen.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';
import 'package:marky/l10n/app_localizations.dart';

void main() {
  testWidgets('SearchScreen operator chips toggle search operators into query field',
      (WidgetTester tester) async {
    final _MockBookmarkRepository bookmarkRepo = _MockBookmarkRepository();
    final _MockTagRepository tagRepo = _MockTagRepository();
    final _MockCollectionRepository collectionRepo = _MockCollectionRepository();
    final _MockSearchQueryRepository queryRepo = _MockSearchQueryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(bookmarkRepo),
          tagRepositoryProvider.overrideWithValue(tagRepo),
          bookmarkCollectionRepositoryProvider.overrideWithValue(collectionRepo),
          searchQueryRepositoryProvider.overrideWithValue(queryRepo),
          recentSearchQueriesProvider.overrideWith(
            (ref) => Stream<List<SearchQuery>>.value(<SearchQuery>[]),
          ),
          savedSearchQueriesProvider.overrideWith(
            (ref) => Stream<List<SearchQuery>>.value(<SearchQuery>[]),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SearchScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify operator chips are present
    expect(find.text('Unread'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Articles'), findsOneWidget);
    expect(find.text('Videos'), findsOneWidget);

    final Finder textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    // Initial text should be empty
    TextField textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.controller?.text, isEmpty);

    // Tap "Unread" chip -> appends is:unread
    await tester.tap(find.text('Unread'));
    await tester.pumpAndSettle();

    textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.controller?.text, 'is:unread');

    // Tap "Articles" chip -> appends type:article
    await tester.tap(find.text('Articles'));
    await tester.pumpAndSettle();

    textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.controller?.text, 'is:unread type:article');

    // Tap "Unread" chip again -> removes is:unread
    await tester.tap(find.text('Unread'));
    await tester.pumpAndSettle();

    textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.controller?.text, 'type:article');
  });
}

class _MockBookmarkRepository implements BookmarkRepository {
  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async =>
      <Bookmark>[];

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => <Bookmark>[];

  @override
  Future<Bookmark> save(Bookmark bookmark) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) =>
      throw UnimplementedError();
  @override
  Future<Bookmark?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> getByIds(List<int> ids) => throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<int> deleteAll(List<int> ids) => throw UnimplementedError();
  @override
  Future<Bookmark?> findByUrlHash(String urlHash) => throw UnimplementedError();
  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) =>
      throw UnimplementedError();
  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) =>
      throw UnimplementedError();
  @override
  Future<int> countAll() => throw UnimplementedError();
  @override
  Future<int> count(BookmarkFeedQuery query) => throw UnimplementedError();
  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      throw UnimplementedError();
  @override
  Stream<Bookmark?> watchById(int id) => throw UnimplementedError();
}

class _MockTagRepository implements TagRepository {
  @override
  Future<Tag?> findBySlug(String slug) async => null;
  @override
  Future<Tag> save(Tag tag) => throw UnimplementedError();
  @override
  Future<Tag> createFromName(String name, {int? colorArgb, String? icon}) =>
      throw UnimplementedError();
  @override
  Future<Tag?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<Tag>> getAll() => throw UnimplementedError();
  @override
  Future<List<Tag>> getByIds(List<int> ids) => throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<void> incrementUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<void> decrementUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<int> recomputeUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<Map<int, int>> recomputeAllUsageCounts() => throw UnimplementedError();
  @override
  Stream<List<Tag>> watchAll() => throw UnimplementedError();
  @override
  Stream<Tag?> watchById(int id) => throw UnimplementedError();
}

class _MockCollectionRepository implements BookmarkCollectionRepository {
  @override
  Future<BookmarkCollection?> findBySlug(String slug) async => null;
  @override
  Future<BookmarkCollection> save(BookmarkCollection collection) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection> createFromTitle(String title,
          {int? accentColorArgb, String? icon}) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection> createSmartFromRule(
          String title, SmartCollectionRule rule,
          {int? accentColorArgb, String? icon}) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<BookmarkCollection>> getAll({bool includeArchived = false}) =>
      throw UnimplementedError();
  @override
  Future<List<BookmarkCollection>> getByIds(List<int> ids) =>
      throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<void> incrementItemCount(int collectionId) =>
      throw UnimplementedError();
  @override
  Future<void> decrementItemCount(int collectionId) =>
      throw UnimplementedError();
  @override
  Future<int> recomputeItemCount(int collectionId) =>
      throw UnimplementedError();
  @override
  Future<Map<int, int>> recomputeAllItemCounts() => throw UnimplementedError();
  @override
  Stream<List<BookmarkCollection>> watchAll({bool includeArchived = false}) =>
      throw UnimplementedError();
  @override
  Stream<BookmarkCollection?> watchById(int id) => throw UnimplementedError();
}

class _MockSearchQueryRepository implements SearchQueryRepository {
  @override
  Future<SearchQuery?> findByNormalizedQuery(String normalizedQuery) async =>
      null;
  @override
  Future<void> removeRecent(int id) async {}
  @override
  Future<void> clearRecent() async {}
  @override
  Future<List<SearchQuery>> getRecent({int limit = 10}) async =>
      <SearchQuery>[];
  @override
  Future<List<SearchQuery>> getSaved() async => <SearchQuery>[];
  @override
  Future<SearchQuery> recordRecent(String query) async => SearchQuery(
        query: query,
        normalizedQuery: SearchQuery.normalize(query),
        createdAt: DateTime(2026),
        lastUsedAt: DateTime(2026),
      );
  @override
  Future<SearchQuery> saveSearch(String query, {String? label}) async =>
      SearchQuery(
        query: query,
        normalizedQuery: SearchQuery.normalize(query),
        createdAt: DateTime(2026),
        lastUsedAt: DateTime(2026),
        isSaved: true,
      );
  @override
  Future<bool> unsave(int id) async => true;
  @override
  Stream<List<SearchQuery>> watchRecent({int limit = 10}) =>
      Stream<List<SearchQuery>>.value(<SearchQuery>[]);
  @override
  Stream<List<SearchQuery>> watchSaved() =>
      Stream<List<SearchQuery>>.value(<SearchQuery>[]);
}
