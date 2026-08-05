import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/feed/presentation/providers/feed_providers.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ─── Fake Repository ───────────────────────────────────────────────────

/// In-memory fake implementation of [BookmarkItemRepository] for testing.
class FakeBookmarkItemRepository implements BookmarkItemRepository {
  final List<BookmarkItem> _items = <BookmarkItem>[];

  void addItems(List<BookmarkItem> items) {
    _items.addAll(items);
  }

  void setItems(List<BookmarkItem> items) {
    _items
      ..clear()
      ..addAll(items);
  }

  @override
  Future<BookmarkItem?> getById(Id id) async {
    try {
      return _items.firstWhere((BookmarkItem item) => item.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async {
    var result = List<BookmarkItem>.from(_items);
    if (offset != null && offset > 0) {
      final int start = offset.clamp(0, result.length);
      result = result.sublist(start);
    }
    if (limit != null && limit >= 0) {
      result = result.take(limit).toList();
    }
    return result;
  }

  @override
  Future<Id> insert(BookmarkItem entity) async {
    final int id = _items.isEmpty
        ? 1
        : _items.map((BookmarkItem i) => i.id).reduce((int a, int b) => a > b ? a : b) + 1;
    entity.id = id;
    _items.add(entity);
    return id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    final int index = _items.indexWhere((BookmarkItem item) => item.id == entity.id);
    if (index != -1) {
      _items[index] = entity;
    }
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _items.removeWhere((BookmarkItem item) => item.id == id);
  }

  @override
  Future<void> clear() async {
    _items.clear();
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async {
    try {
      return _items.firstWhere((BookmarkItem item) => item.urlHash == urlHash);
    } on StateError {
      return null;
    }
  }

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async {
    try {
      return _items.firstWhere((BookmarkItem item) => item.canonicalUrl == canonicalUrl);
    } on StateError {
      return null;
    }
  }

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async {
    try {
      return _items.firstWhere((BookmarkItem item) => item.externalContentId == externalContentId);
    } on StateError {
      return null;
    }
  }

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async {
    return _items.where((BookmarkItem item) => item.duplicateGroupId == groupId).toList();
  }

  List<BookmarkItem> _applyPagination(List<BookmarkItem> items, {int? offset, int? limit}) {
    var result = List<BookmarkItem>.from(items);
    if (offset != null && offset > 0) {
      final int start = offset.clamp(0, result.length);
      result = result.sublist(start);
    }
    if (limit != null && limit >= 0) {
      result = result.take(limit).toList();
    }
    return result;
  }

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async {
    final filtered = _items.where((BookmarkItem item) => item.isFavorite).toList();
    return _applyPagination(filtered, offset: offset, limit: limit);
  }

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async {
    final filtered = _items.where((BookmarkItem item) => item.isArchived).toList();
    return _applyPagination(filtered, offset: offset, limit: limit);
  }

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async {
    final filtered = _items.where((BookmarkItem item) {
      return item.collectionIds?.contains(collectionId) ?? false;
    }).toList();
    return _applyPagination(filtered, offset: offset, limit: limit);
  }

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async {
    final filtered = _items.where((BookmarkItem item) {
      return item.tagIds?.contains(tagId) ?? false;
    }).toList();
    return _applyPagination(filtered, offset: offset, limit: limit);
  }

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async {
    var filtered = _items.where((BookmarkItem item) {
      // Soft-delete guard
      if (item.isDeleted) return false;

      // Vault exclusion unless in:vault is present
      final bool includeVault = query.hasOperator('in') &&
          query.operatorValues('in').any((String v) => v.toLowerCase() == 'vault');
      if (!includeVault && item.isInVault) return false;

      // Free-text matching across title/description/snippet/extractedText/originalUrl
      for (final term in query.freeText) {
        final lowerTerm = term.toLowerCase();
        final matches = (item.title?.toLowerCase().contains(lowerTerm) ?? false) ||
            (item.description?.toLowerCase().contains(lowerTerm) ?? false) ||
            (item.snippet?.toLowerCase().contains(lowerTerm) ?? false) ||
            (item.extractedText?.toLowerCase().contains(lowerTerm) ?? false) ||
            (item.originalUrl.toLowerCase().contains(lowerTerm));
        if (!matches) return false;
      }

      return true;
    }).toList();

    return _applyPagination(filtered, offset: offset, limit: limit);
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────

BookmarkItem _makeBookmark({
  required int id,
  required String url,
  String? title,
}) {
  final DateTime now = DateTime.now();
  return BookmarkItem(
    originalUrl: url,
    canonicalUrl: url,
    urlHash: 'hash_$id',
    title: title,
    createdAt: now,
    updatedAt: now,
  )..id = id;
}

void main() {
  group('PaginatedFeedNotifier', () {
    late FakeBookmarkItemRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeBookmarkItemRepository();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is loading', () {
      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      final PaginatedFeedState state = container.read(bookmarkListProvider);

      expect(state.items, isEmpty);
      expect(state.isLoadingMore, isTrue);
      expect(state.hasMore, isTrue);
      expect(state.error, isNull);
    });

    test('loads first page on init', () async {
      final List<BookmarkItem> items = List<BookmarkItem>.generate(
        24,
        (int i) => _makeBookmark(id: i + 1, url: 'https://example.com/$i'),
      );
      fakeRepository.addItems(items);

      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      // Trigger provider creation and wait for async init.
      container.read(bookmarkListProvider);
      await Future<void>.delayed(Duration.zero);

      final PaginatedFeedState state = container.read(bookmarkListProvider);

      expect(state.items.length, 24);
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isTrue);
      expect(state.error, isNull);
    });

    test('hasMore is false when first page has fewer than page size', () async {
      final List<BookmarkItem> items = List<BookmarkItem>.generate(
        10,
        (int i) => _makeBookmark(id: i + 1, url: 'https://example.com/$i'),
      );
      fakeRepository.addItems(items);

      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      container.read(bookmarkListProvider);
      await Future<void>.delayed(Duration.zero);

      final PaginatedFeedState state = container.read(bookmarkListProvider);

      expect(state.items.length, 10);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);
    });

    test('loadMore appends next page', () async {
      final List<BookmarkItem> items = List<BookmarkItem>.generate(
        47,
        (int i) => _makeBookmark(id: i + 1, url: 'https://example.com/$i'),
      );
      fakeRepository.addItems(items);

      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      container.read(bookmarkListProvider);
      await Future<void>.delayed(Duration.zero);

      var state = container.read(bookmarkListProvider);
      expect(state.items.length, 24);

      await container.read(bookmarkListProvider.notifier).loadMore();

      state = container.read(bookmarkListProvider);
      expect(state.items.length, 47);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);
    });

    test('loadMore is no-op when hasMore is false', () async {
      final List<BookmarkItem> items = List<BookmarkItem>.generate(
        10,
        (int i) => _makeBookmark(id: i + 1, url: 'https://example.com/$i'),
      );
      fakeRepository.addItems(items);

      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      container.read(bookmarkListProvider);
      await Future<void>.delayed(Duration.zero);

      var state = container.read(bookmarkListProvider);
      expect(state.hasMore, isFalse);

      await container.read(bookmarkListProvider.notifier).loadMore();

      state = container.read(bookmarkListProvider);
      expect(state.items.length, 10);
      expect(state.isLoadingMore, isFalse);
    });

    test('loadMore is no-op when already loading', () async {
      final List<BookmarkItem> items = List<BookmarkItem>.generate(
        48,
        (int i) => _makeBookmark(id: i + 1, url: 'https://example.com/$i'),
      );
      fakeRepository.addItems(items);

      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      container.read(bookmarkListProvider);
      await Future<void>.delayed(Duration.zero);

      // Start first loadMore
      final Future<void> firstLoad =
          container.read(bookmarkListProvider.notifier).loadMore();

      // Try concurrent loadMore — should be no-op
      await container.read(bookmarkListProvider.notifier).loadMore();

      await firstLoad;

      final PaginatedFeedState state = container.read(bookmarkListProvider);
      expect(state.items.length, 48);
      expect(state.isLoadingMore, isFalse);
    });

    test('refresh reloads from first page', () async {
      final List<BookmarkItem> items = List<BookmarkItem>.generate(
        48,
        (int i) => _makeBookmark(id: i + 1, url: 'https://example.com/$i'),
      );
      fakeRepository.addItems(items);

      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      container.read(bookmarkListProvider);
      await Future<void>.delayed(Duration.zero);
      await container.read(bookmarkListProvider.notifier).loadMore();

      var state = container.read(bookmarkListProvider);
      expect(state.items.length, 48);

      // Remove some items from repo to simulate external change
      fakeRepository.setItems(items.sublist(0, 12));

      await container.read(bookmarkListProvider.notifier).refresh();

      state = container.read(bookmarkListProvider);
      expect(state.items.length, 12);
      expect(state.hasMore, isFalse);
    });

    test('exposes error when repository throws', () async {
      final ErrorThrowingRepository throwingRepo = ErrorThrowingRepository();

      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(throwingRepo),
        ],
      );

      container.read(bookmarkListProvider);
      await Future<void>.delayed(Duration.zero);

      final PaginatedFeedState state = container.read(bookmarkListProvider);

      expect(state.items, isEmpty);
      expect(state.error, isNotNull);
      expect(state.isLoadingMore, isFalse);
    });
  });

  group('bookmarkByIdProvider', () {
    late FakeBookmarkItemRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeBookmarkItemRepository();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns bookmark when ID exists', () async {
      final BookmarkItem item = BookmarkItem(
        originalUrl: 'https://example.com/1',
        canonicalUrl: 'https://example.com/1',
        urlHash: 'hash1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      item.id = 1;

      fakeRepository.addItems(<BookmarkItem>[item]);

      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      final BookmarkItem? result =
          await container.read(bookmarkByIdProvider(1).future);

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.originalUrl, 'https://example.com/1');
    });

    test('returns null when ID does not exist', () async {
      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );

      final BookmarkItem? result =
          await container.read(bookmarkByIdProvider(999).future);

      expect(result, isNull);
    });
  });
}

// ─── Error-throwing repository ─────────────────────────────────────────

class ErrorThrowingRepository implements BookmarkItemRepository {
  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async {
    throw Exception('Repository error');
  }

  @override
  Future<BookmarkItem?> getById(Id id) async => throw Exception('Repository error');

  @override
  Future<Id> insert(BookmarkItem entity) async => throw Exception('Repository error');

  @override
  Future<Id> update(BookmarkItem entity) async => throw Exception('Repository error');

  @override
  Future<void> delete(Id id) async => throw Exception('Repository error');

  @override
  Future<void> clear() async => throw Exception('Repository error');

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => throw Exception('Repository error');

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => throw Exception('Repository error');

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async => throw Exception('Repository error');

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => throw Exception('Repository error');

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => throw Exception('Repository error');

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => throw Exception('Repository error');

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async => throw Exception('Repository error');

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => throw Exception('Repository error');

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => throw Exception('Repository error');
}
