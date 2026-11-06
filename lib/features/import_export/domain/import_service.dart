import 'dart:convert';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/core/url/content_type_detector.dart';
import 'package:marky/core/url/external_content_id_extractor.dart';
import 'package:marky/core/url/url_hasher.dart';
import 'package:marky/core/url/url_normalizer.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/domain/duplicate_check_result.dart';
import 'package:marky/features/capture/domain/duplicate_detector.dart';
import 'package:marky/features/capture/domain/upsert_merge_service.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

/// Result returned after a JSON restore.
class ImportResult {
  const ImportResult({
    this.bookmarksImported = 0,
    this.bookmarksMerged = 0,
    this.bookmarksSkipped = 0,
    this.tagsImported = 0,
    this.collectionsImported = 0,
  });

  final int bookmarksImported;
  final int bookmarksMerged;
  final int bookmarksSkipped;
  final int tagsImported;
  final int collectionsImported;
}

/// Restores a Marky JSON backup, deduplicating by URL hash.
class ImportService {
  const ImportService({
    required BookmarkRepository bookmarkRepository,
    required TagRepository tagRepository,
    required BookmarkCollectionRepository collectionRepository,
    required DuplicateDetector duplicateDetector,
    required UpsertMergeService mergeService,
  })  : _bookmarks = bookmarkRepository,
        _tags = tagRepository,
        _collections = collectionRepository,
        _duplicateDetector = duplicateDetector,
        _mergeService = mergeService;

  final BookmarkRepository _bookmarks;
  final TagRepository _tags;
  final BookmarkCollectionRepository _collections;
  final DuplicateDetector _duplicateDetector;
  final UpsertMergeService _mergeService;
  static const UrlNormalizer _normalizer = UrlNormalizer();
  static const UrlHasher _hasher = UrlHasher();
  static const ExternalContentIdExtractor _contentIdExtractor =
      ExternalContentIdExtractor();
  static const ContentTypeDetector _contentTypeDetector = ContentTypeDetector();

  /// Parses [jsonString] and inserts missing entities.
  ///
  /// Existing bookmarks (matched by `originalUrl` via `findByUrlHash`)
  /// are **skipped**, not overwritten — the user's local edits win.
  Future<ImportResult> importAll(String jsonString) async {
    final Map<String, dynamic> envelope =
        json.decode(jsonString) as Map<String, dynamic>;

    // Version gate — only v1 for now.
    final int version = (envelope['version'] as int?) ?? 1;
    if (version != 1) {
      throw FormatException('Unsupported backup version: $version');
    }

    int bookmarksImported = 0;
    int bookmarksMerged = 0;
    int bookmarksSkipped = 0;
    int tagsImported = 0;
    int collectionsImported = 0;

    // ── Tags ────────────────────────────────────────────────────
    final List<dynamic> rawTags =
        (envelope['tags'] as List<dynamic>?) ?? <dynamic>[];
    for (final dynamic raw in rawTags) {
      final Map<String, dynamic> m = raw as Map<String, dynamic>;
      final String name = (m['name'] as String?) ?? '';
      if (name.isEmpty) continue;

      final Tag? existing = await _tags.findBySlug(Tag.slugify(name));
      if (existing != null) continue;

      await _tags.createFromName(
        name,
        colorArgb: m['colorArgb'] as int?,
        icon: m['icon'] as String?,
      );
      tagsImported++;
    }

    // ── Collections ─────────────────────────────────────────────
    final List<dynamic> rawCollections =
        (envelope['collections'] as List<dynamic>?) ?? <dynamic>[];
    for (final dynamic raw in rawCollections) {
      final Map<String, dynamic> m = raw as Map<String, dynamic>;
      final String title = (m['title'] as String?) ?? '';
      if (title.isEmpty) continue;

      final BookmarkCollection? existing =
          await _collections.findBySlug(BookmarkCollection.slugify(title));
      if (existing != null) continue;

      await _collections.createFromTitle(
        title,
        accentColorArgb: m['accentColorArgb'] as int?,
        icon: m['icon'] as String?,
      );
      collectionsImported++;
    }

    // ── Bookmarks ───────────────────────────────────────────────
    final List<dynamic> rawBookmarks =
        (envelope['bookmarks'] as List<dynamic>?) ?? <dynamic>[];
    for (final dynamic raw in rawBookmarks) {
      final Map<String, dynamic> m = raw as Map<String, dynamic>;
      final String url = ((m['originalUrl'] as String?) ?? '').trim();
      if (url.isEmpty) continue;

      final Bookmark? incoming = _bookmarkFromJson(m);
      if (incoming == null) {
        bookmarksSkipped++;
        continue;
      }

      final DuplicateCheckResult duplicate = await _duplicateDetector.check(
        urlHash: incoming.urlHash!,
        canonicalUrl: incoming.canonicalUrl!,
        externalContentId: incoming.externalContentId,
      );

      if (duplicate.isNew) {
        await _bookmarks.save(incoming);
        bookmarksImported++;
      } else {
        final Bookmark existing = duplicate.existingBookmark!;
        final Bookmark merged = _mergeService.merge(existing, incoming);
        await _bookmarks.save(merged);
        bookmarksMerged++;
      }
    }

    return ImportResult(
      bookmarksImported: bookmarksImported,
      bookmarksMerged: bookmarksMerged,
      bookmarksSkipped: bookmarksSkipped,
      tagsImported: tagsImported,
      collectionsImported: collectionsImported,
    );
  }

  static Bookmark? _bookmarkFromJson(Map<String, dynamic> m) {
    final String url = ((m['originalUrl'] as String?) ?? '').trim();
    if (url.isEmpty) return null;

    final String? rawCanonical = (m['canonicalUrl'] as String?)?.trim();
    final String? canonicalUrl = rawCanonical != null && rawCanonical.isNotEmpty
        ? _normalizer.normalize(rawCanonical) ?? _normalizer.normalize(url)
        : _normalizer.normalize(url);
    if (canonicalUrl == null) return null;

    final String urlHash = _hasher.hash(canonicalUrl);
    final String? normalizedHost = (m['normalizedHost'] as String?) ??
        _normalizer.extractNormalizedHost(canonicalUrl);
    final String? externalContentId = (m['externalContentId'] as String?) ??
        _contentIdExtractor.extract(canonicalUrl);
    final BookmarkContentType contentType =
        (m['contentType'] as String?) == null
            ? _contentTypeDetector.detect(canonicalUrl)
            : _parseContentType(m['contentType'] as String?);
    final DateTime now = DateTime.now();

    return Bookmark(
      originalUrl: url,
      canonicalUrl: canonicalUrl,
      urlHash: urlHash,
      externalContentId: externalContentId,
      title: m['title'] as String?,
      description: m['description'] as String?,
      snippet: m['snippet'] as String?,
      heroImageUrl: m['heroImageUrl'] as String?,
      faviconUrl: m['faviconUrl'] as String?,
      siteName: m['siteName'] as String?,
      author: m['author'] as String?,
      publisher: m['publisher'] as String?,
      publishDate: _tryParseDate(m['publishDate'] as String?),
      contentType: contentType,
      sourceType: _parseSourceType(m['sourceType'] as String?),
      normalizedHost: normalizedHost,
      isFavorite: (m['isFavorite'] as bool?) ?? false,
      isArchived: (m['isArchived'] as bool?) ?? false,
      isPinned: (m['isPinned'] as bool?) ?? false,
      isRead: (m['isRead'] as bool?) ?? false,
      inlineNotes: m['inlineNotes'] as String?,
      tagIds: _parseIntList(m['tagIds']),
      collectionIds: _parseIntList(m['collectionIds']),
      createdAt: _tryParseDate(m['createdAt'] as String?) ?? now,
      updatedAt: now,
    );
  }

  static DateTime? _tryParseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  static BookmarkContentType _parseContentType(String? s) {
    if (s == null) return BookmarkContentType.article;
    return BookmarkContentType.values.firstWhere(
      (BookmarkContentType e) => e.name == s,
      orElse: () => BookmarkContentType.article,
    );
  }

  static BookmarkSourceType _parseSourceType(String? s) {
    if (s == null) return BookmarkSourceType.manual;
    return BookmarkSourceType.values.firstWhere(
      (BookmarkSourceType e) => e.name == s,
      orElse: () => BookmarkSourceType.manual,
    );
  }

  static List<int> _parseIntList(dynamic raw) {
    if (raw == null) return <int>[];
    if (raw is! List) return <int>[];
    return raw.whereType<int>().toList();
  }
}
