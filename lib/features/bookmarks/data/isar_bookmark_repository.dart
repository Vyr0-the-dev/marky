import 'package:isar/isar.dart';
import 'package:marky/core/database/entities/bookmark_entity.dart';
import 'package:marky/features/bookmarks/data/bookmark_mapper.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';

/// Isar-backed implementation of [BookmarkRepository].
///
/// Responsibilities beyond plain mapping:
/// 1. **Stamp `updatedAt`** on every save so callers can't forget.
/// 2. **Float pinned items** to the top of every feed query
///    regardless of the chosen sort. Without this the user's pin
///    silently loses meaning when they switch sort modes.
/// 3. **Translate the [BookmarkFeedQuery] value object** into Isar's
///    typed query DSL. The DSL is fluent but generic-heavy; we
///    centralise the chain here so feature code never needs to know
///    which composite index serves which query.
class IsarBookmarkRepository implements BookmarkRepository {
  IsarBookmarkRepository(this._isar);

  final Isar _isar;
  static const int _maxFeedPageSize = 500;
  static const int _maxSearchLimit = 100;

  // ─── CRUD ───────────────────────────────────────────────────────

  @override
  Future<Bookmark> save(Bookmark bookmark) async {
    // Stamp `updatedAt` here so domain callers never need to remember.
    final Bookmark stamped = bookmark.copyWith(updatedAt: DateTime.now());
    final BookmarkEntity entity = BookmarkMapper.toEntity(stamped);

    final int id = await _isar.writeTxn<int>(() async {
      return _isar.bookmarks.put(entity);
    });

    return stamped.copyWith(id: id);
  }

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) async {
    final DateTime now = DateTime.now();
    final List<Bookmark> stamped = bookmarks
        .map((Bookmark b) => b.copyWith(updatedAt: now))
        .toList(growable: false);

    final List<BookmarkEntity> entities =
        stamped.map(BookmarkMapper.toEntity).toList(growable: false);

    final List<int> ids = await _isar.writeTxn<List<int>>(() async {
      return _isar.bookmarks.putAll(entities);
    });

    return List<Bookmark>.generate(
      stamped.length,
      (int i) => stamped[i].copyWith(id: ids[i]),
      growable: false,
    );
  }

  @override
  Future<Bookmark?> getById(int id) async {
    final BookmarkEntity? entity = await _isar.bookmarks.get(id);
    return entity == null ? null : BookmarkMapper.toDomain(entity);
  }

  @override
  Future<List<Bookmark>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return const <Bookmark>[];
    final List<BookmarkEntity?> entities = await _isar.bookmarks.getAll(ids);
    // Filter nulls but preserve relative order of survivors.
    return entities
        .whereType<BookmarkEntity>()
        .map(BookmarkMapper.toDomain)
        .toList(growable: false);
  }

  @override
  Future<bool> delete(int id) async {
    return _isar.writeTxn<bool>(() async {
      return _isar.bookmarks.delete(id);
    });
  }

  @override
  Future<int> deleteAll(List<int> ids) async {
    if (ids.isEmpty) return 0;
    return _isar.writeTxn<int>(() async {
      return _isar.bookmarks.deleteAll(ids);
    });
  }

  // ─── Lookup probes ──────────────────────────────────────────────

  @override
  Future<Bookmark?> findByUrlHash(String urlHash) async {
    final BookmarkEntity? entity =
        await _isar.bookmarks.where().urlHashEqualTo(urlHash).findFirst();
    return entity == null ? null : BookmarkMapper.toDomain(entity);
  }

  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) async {
    final BookmarkEntity? entity = await _isar.bookmarks
        .where()
        .canonicalUrlEqualTo(canonicalUrl)
        .findFirst();
    return entity == null ? null : BookmarkMapper.toDomain(entity);
  }

  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) async {
    final BookmarkEntity? entity = await _isar.bookmarks
        .where()
        .externalContentIdEqualTo(externalContentId)
        .findFirst();
    return entity == null ? null : BookmarkMapper.toDomain(entity);
  }

  // ─── Counts ─────────────────────────────────────────────────────

  @override
  Future<int> countAll() {
    return _isar.bookmarks.filter().isArchivedEqualTo(false).count();
  }

  @override
  Future<int> count(BookmarkFeedQuery query) {
    return _filtered(query).count();
  }

  // ─── Feed queries ───────────────────────────────────────────────

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async {
    final int limit = _clampedLimit(query.limit, max: _maxFeedPageSize);
    if (limit == 0) return const <Bookmark>[];
    final List<BookmarkEntity> rows = await _sorted(_filtered(query), query)
        .offset(_safeOffset(query.offset))
        .limit(limit)
        .findAll();
    return rows.map(BookmarkMapper.toDomain).toList(growable: false);
  }

  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) {
    final int limit = _clampedLimit(query.limit, max: _maxFeedPageSize);
    if (limit == 0) return Stream<List<Bookmark>>.value(const <Bookmark>[]);
    // Build the materialized query once; Isar streams its results so
    // we react to any underlying mutation without re-issuing the
    // query ourselves.
    final Query<BookmarkEntity> built = _sorted(_filtered(query), query)
        .offset(_safeOffset(query.offset))
        .limit(limit)
        .build();

    return built.watch(fireImmediately: true).map(
          (List<BookmarkEntity> rows) =>
              rows.map(BookmarkMapper.toDomain).toList(growable: false),
        );
  }

  @override
  Stream<Bookmark?> watchById(int id) {
    return _isar.bookmarks.watchObject(id, fireImmediately: true).map(
        (BookmarkEntity? entity) =>
            entity == null ? null : BookmarkMapper.toDomain(entity));
  }

  // ─── Query-builder helpers ──────────────────────────────────────

  /// Translates [BookmarkFeedQuery] into an Isar filter chain.
  ///
  /// Returned at the `QAfterFilterCondition` stage so the caller can
  /// either tack on a sort + paging (the [_sorted] helper) or call
  /// `.count()` directly.
  ///
  /// Why a free function instead of an extension: Isar's generic
  /// chain types are intimidating, and a free function with the
  /// explicit return type doubles as the place future maintainers
  /// can read to learn the predicate set.
  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition> _filtered(
      BookmarkFeedQuery q) {
    QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition> chain =
        _isar.bookmarks.filter().isArchivedEqualTo(
              q.filter == BookmarkFeedFilter.archived,
            );

    switch (q.filter) {
      case BookmarkFeedFilter.all:
      case BookmarkFeedFilter.archived:
        // No further status narrowing.
        break;
      case BookmarkFeedFilter.favorites:
        chain = chain.isFavoriteEqualTo(true);
      case BookmarkFeedFilter.unread:
        chain = chain.isReadEqualTo(false);
    }

    if (q.tagId != null) {
      chain = chain.tagIdsElementEqualTo(q.tagId!);
    }
    if (q.collectionId != null) {
      chain = chain.collectionIdsElementEqualTo(q.collectionId!);
    }
    if (q.contentType != null) {
      chain = chain.contentTypeEqualTo(q.contentType!);
    }
    if (q.host != null) {
      chain = chain.normalizedHostEqualTo(q.host);
    }
    if (q.createdAfter != null) {
      chain = chain.createdAtGreaterThan(q.createdAfter!, include: true);
    }
    if (q.createdBefore != null) {
      chain = chain.createdAtLessThan(q.createdBefore!, include: true);
    }

    return chain;
  }

  /// Applies the sort phase. Pinned items always float to the top
  /// regardless of [BookmarkSort] — see class docstring.
  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> _sorted(
    QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition> chain,
    BookmarkFeedQuery q,
  ) {
    // Step 1: pinned-first.
    final QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> pinned =
        chain.sortByIsPinnedDesc();

    // Step 2: requested order, applied as the secondary sort.
    switch (q.sort) {
      case BookmarkSort.newestFirst:
        return pinned.thenByCreatedAtDesc();
      case BookmarkSort.oldestFirst:
        return pinned.thenByCreatedAt();
      case BookmarkSort.recentlyOpened:
        // `lastInteractionAt` is nullable; Isar puts NULLs at the end
        // for ASC and at the start for DESC. We want recent activity
        // first, NULLs last → DESC.
        return pinned.thenByLastInteractionAtDesc();
      case BookmarkSort.titleAscending:
        // Tiebreak alphabetical sorts by createdAt DESC so newer
        // items in a name collision surface first.
        return pinned.thenByTitle().thenByCreatedAtDesc();
    }
  }

  // ─── Search ────────────────────────────────────────────────────

  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return <Bookmark>[];
    final int effectiveLimit = _clampedLimit(limit, max: _maxSearchLimit);
    if (effectiveLimit == 0) return const <Bookmark>[];

    // Isar doesn't have a UNION-OR across different string fields in a
    // single filter clause that works cleanly for partial contains, so
    // we fetch more rows and rank in Dart.
    final List<BookmarkEntity> candidates = await _isar.bookmarks
        .filter()
        .group((QueryBuilder<BookmarkEntity, BookmarkEntity, QFilterCondition>
                f) =>
            f
                .titleContains(q, caseSensitive: false)
                .or()
                .normalizedHostContains(q, caseSensitive: false)
                .or()
                .snippetContains(q, caseSensitive: false)
                .or()
                .authorContains(q, caseSensitive: false)
                .or()
                .siteNameContains(q, caseSensitive: false)
                .or()
                .descriptionContains(q, caseSensitive: false))
        .sortByCreatedAtDesc()
        .limit(effectiveLimit * 2) // over-fetch so we can re-rank
        .findAll();

    // Simple relevance: title match > host match > other.
    int score(BookmarkEntity e) {
      if (e.title?.toLowerCase().contains(q) ?? false) return 0;
      if (e.normalizedHost?.toLowerCase().contains(q) ?? false) return 1;
      return 2;
    }

    candidates.sort(
        (BookmarkEntity a, BookmarkEntity b) => score(a).compareTo(score(b)));

    return candidates
        .take(effectiveLimit)
        .map(BookmarkMapper.toDomain)
        .toList(growable: false);
  }

  static int _safeOffset(int offset) => offset < 0 ? 0 : offset;

  static int _clampedLimit(int limit, {required int max}) {
    if (limit <= 0) return 0;
    return limit > max ? max : limit;
  }
}
