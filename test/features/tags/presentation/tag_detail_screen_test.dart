import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/features/tags/presentation/screens/tag_detail_screen.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/tag.dart';

// ─── Fake Tag Repository ───────────────────────────────────────────────

class FakeTagRepository implements TagRepository {
  final List<Tag> _tags = <Tag>[];

  void setTags(List<Tag> tags) {
    _tags
      ..clear()
      ..addAll(tags);
  }

  @override
  Future<List<Tag>> getAll() async => List<Tag>.unmodifiable(_tags);

  @override
  Future<Tag?> getById(int id) async {
    try {
      return _tags.firstWhere((Tag t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Tag?> getBySlug(String slug) async {
    try {
      return _tags.firstWhere((Tag t) => t.slug == slug);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insert(Tag entity) async {
    _tags.add(entity);
    return entity.id;
  }

  @override
  Future<int> update(Tag entity) async => entity.id;

  @override
  Future<void> delete(int id) async {
    _tags.removeWhere((Tag t) => t.id == id);
  }

  @override
  Future<void> clear() async => _tags.clear();

  Future<List<Tag>> searchByName(String query) async => <Tag>[];

  Future<void> incrementUsageCount(int id) async {}

  Future<void> decrementUsageCount(int id) async {}

  Future<void> syncUsageCounts() async {}
}

// ─── Fake Bookmark Repository ──────────────────────────────────────────

class FakeBookmarkRepo implements BookmarkItemRepository {
  final List<BookmarkItem> _items = <BookmarkItem>[];

  void setItems(List<BookmarkItem> items) {
    _items
      ..clear()
      ..addAll(items);
  }

  @override
  Future<BookmarkItem?> getById(int id) async => null;
  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => List<BookmarkItem>.unmodifiable(_items);
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
  Future<List<BookmarkItem>> getByTagId(int tagId, {int? offset, int? limit}) async {
    return _items.where((BookmarkItem b) => b.id == tagId).toList();
  }

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

// ─── Test Helpers ──────────────────────────────────────────────────────

Tag _makeTag({
  required int id,
  required String name,
  String? color,
}) {
  return Tag(
    name: name,
    slug: name.toLowerCase().replaceAll(' ', '-'),
    color: color,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  )..id = id;
}

BookmarkItem _makeBookmark({
  required int id,
  required String url,
  String? title,
}) {
  final DateTime now = DateTime(2025, 1, 15);
  return BookmarkItem(
    originalUrl: url,
    title: title,
    createdAt: now,
    updatedAt: now,
  )..id = id;
}

Widget buildTagDetailScreen(FakeTagRepository tagRepo, FakeBookmarkRepo bookmarkRepo, int id) {
  return ProviderScope(
    overrides: <Override>[
      tagRepositoryProvider.overrideWithValue(tagRepo),
      bookmarkRepositoryProvider.overrideWithValue(bookmarkRepo),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: TagDetailScreen(id: id),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('TagDetailScreen', () {
    late FakeTagRepository fakeTagRepo;
    late FakeBookmarkRepo fakeBookmarkRepo;

    setUp(() {
      fakeTagRepo = FakeTagRepository();
      fakeBookmarkRepo = FakeBookmarkRepo();
    });

    testWidgets('renders loading state initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTagDetailScreen(fakeTagRepo, fakeBookmarkRepo, 1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders tag name in app bar when loaded', (
      WidgetTester tester,
    ) async {
      fakeTagRepo.setTags(<Tag>[
        _makeTag(id: 1, name: 'Flutter', color: '#7C5CFF'),
      ]);

      await tester.pumpWidget(buildTagDetailScreen(fakeTagRepo, fakeBookmarkRepo, 1));
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('renders "Tag not found" for missing tag', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTagDetailScreen(fakeTagRepo, fakeBookmarkRepo, 999));
      await tester.pumpAndSettle();

      expect(find.text('Tag not found'), findsOneWidget);
    });

    testWidgets('renders bookmarks with the tag', (
      WidgetTester tester,
    ) async {
      fakeTagRepo.setTags(<Tag>[
        _makeTag(id: 1, name: 'Flutter'),
      ]);
      fakeBookmarkRepo.setItems(<BookmarkItem>[
        _makeBookmark(id: 1, url: 'https://flutter.dev', title: 'Flutter Docs'),
      ]);

      await tester.pumpWidget(buildTagDetailScreen(fakeTagRepo, fakeBookmarkRepo, 1));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Docs'), findsOneWidget);
    });

    testWidgets('renders empty state when no bookmarks have tag', (
      WidgetTester tester,
    ) async {
      fakeTagRepo.setTags(<Tag>[
        _makeTag(id: 1, name: 'EmptyTag'),
      ]);

      await tester.pumpWidget(buildTagDetailScreen(fakeTagRepo, fakeBookmarkRepo, 1));
      await tester.pumpAndSettle();

      expect(find.text('No bookmarks with this tag yet'), findsOneWidget);
    });
  });
}
