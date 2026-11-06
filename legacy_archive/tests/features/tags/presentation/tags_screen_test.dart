import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/features/tags/presentation/screens/tags_screen.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/tag.dart';

// ─── Fake Tag Repository ───────────────────────────────────────────────

/// In-memory fake implementation of [TagRepository] for testing.
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

/// Minimal fake bookmark repository for tags screen tests.
class FakeBookmarkRepo implements BookmarkItemRepository {
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

// ─── Test Helpers ──────────────────────────────────────────────────────

Tag _makeTag({
  required int id,
  required String name,
  String? color,
  int usageCount = 0,
  bool isSystemTag = false,
}) {
  return Tag(
    name: name,
    slug: name.toLowerCase().replaceAll(' ', '-'),
    color: color,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
    usageCount: usageCount,
    isSystemTag: isSystemTag,
  )..id = id;
}

Widget buildTagsScreen(FakeTagRepository tagRepo) {
  return ProviderScope(
    overrides: <Override>[
      tagRepositoryProvider.overrideWithValue(tagRepo),
      bookmarkRepositoryProvider.overrideWithValue(FakeBookmarkRepo()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: const TagsScreen(),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('TagsScreen', () {
    late FakeTagRepository fakeTagRepo;

    setUp(() {
      fakeTagRepo = FakeTagRepository();
    });

    testWidgets('renders loading state initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTagsScreen(fakeTagRepo));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no tags', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTagsScreen(fakeTagRepo));
      await tester.pumpAndSettle();

      expect(find.text('No tags yet'), findsOneWidget);
      expect(find.text('Create your first tag to organize bookmarks'), findsOneWidget);
    });

    testWidgets('renders tag names and usage counts', (
      WidgetTester tester,
    ) async {
      fakeTagRepo.setTags(<Tag>[
        _makeTag(id: 1, name: 'Flutter', usageCount: 3),
        _makeTag(id: 2, name: 'Dart', usageCount: 1),
      ]);

      await tester.pumpWidget(buildTagsScreen(fakeTagRepo));
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('3 bookmarks'), findsOneWidget);
      expect(find.text('1 bookmark'), findsOneWidget);
    });

    testWidgets('filters tags by search query', (
      WidgetTester tester,
    ) async {
      fakeTagRepo.setTags(<Tag>[
        _makeTag(id: 1, name: 'Flutter'),
        _makeTag(id: 2, name: 'Dart'),
      ]);

      await tester.pumpWidget(buildTagsScreen(fakeTagRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Flu');
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsNothing);
    });

    testWidgets('hides edit button for system tags', (
      WidgetTester tester,
    ) async {
      fakeTagRepo.setTags(<Tag>[
        _makeTag(id: 1, name: 'System', isSystemTag: true),
        _makeTag(id: 2, name: 'Custom'),
      ]);

      await tester.pumpWidget(buildTagsScreen(fakeTagRepo));
      await tester.pumpAndSettle();

      // Two list tiles, only the custom tag has an edit button.
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets(' FAB is present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTagsScreen(fakeTagRepo));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tag row is tappable', (
      WidgetTester tester,
    ) async {
      fakeTagRepo.setTags(<Tag>[
        _makeTag(id: 1, name: 'Flutter'),
      ]);

      await tester.pumpWidget(buildTagsScreen(fakeTagRepo));
      await tester.pumpAndSettle();

      // Verify the InkWell is present (tappable area).
      expect(find.byType(InkWell), findsWidgets);
    });
  });
}
