import 'dart:convert';

import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

/// Serialises the entire Marky vault into a portable JSON string.
///
/// The output envelope:
/// ```json
/// {
///   "version": 1,
///   "exportedAt": "2025-04-25T01:00:00.000Z",
///   "bookmarks": [ ... ],
///   "tags": [ ... ],
///   "collections": [ ... ]
/// }
/// ```
class ExportService {
  const ExportService({
    required BookmarkRepository bookmarkRepository,
    required TagRepository tagRepository,
    required BookmarkCollectionRepository collectionRepository,
  })  : _bookmarks = bookmarkRepository,
        _tags = tagRepository,
        _collections = collectionRepository;

  final BookmarkRepository _bookmarks;
  final TagRepository _tags;
  final BookmarkCollectionRepository _collections;
  static const int _exportPageSize = 500;

  /// Returns the full JSON backup as a UTF-8 string.
  Future<String> exportAll() async {
    final List<Bookmark> bookmarks = await _exportBookmarks();
    final List<Tag> tags = await _tags.getAll();
    final List<BookmarkCollection> collections =
        await _collections.getAll(includeArchived: true);

    final Map<String, dynamic> envelope = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'bookmarks': bookmarks.map(_bookmarkToJson).toList(),
      'tags': tags.map(_tagToJson).toList(),
      'collections': collections.map(_collectionToJson).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  Future<List<Bookmark>> _exportBookmarks() async {
    final List<Bookmark> active = await _exportBookmarkPageSet(
      const BookmarkFeedQuery(
        limit: _exportPageSize,
      ),
    );
    final List<Bookmark> archived = await _exportBookmarkPageSet(
      const BookmarkFeedQuery(
        filter: BookmarkFeedFilter.archived,
        limit: _exportPageSize,
      ),
    );
    return <Bookmark>[...active, ...archived];
  }

  Future<List<Bookmark>> _exportBookmarkPageSet(BookmarkFeedQuery base) async {
    final List<Bookmark> all = <Bookmark>[];
    int offset = 0;
    while (true) {
      final List<Bookmark> page = await _bookmarks.feed(
        base.copyWith(offset: offset),
      );
      if (page.isEmpty) break;
      all.addAll(page);
      if (page.length < _exportPageSize) break;
      offset += page.length;
    }
    return all;
  }

  static Map<String, dynamic> _bookmarkToJson(Bookmark b) {
    return <String, dynamic>{
      'originalUrl': b.originalUrl,
      'canonicalUrl': b.canonicalUrl,
      'urlHash': b.urlHash,
      'externalContentId': b.externalContentId,
      'title': b.title,
      'description': b.description,
      'snippet': b.snippet,
      'heroImageUrl': b.heroImageUrl,
      'faviconUrl': b.faviconUrl,
      'siteName': b.siteName,
      'author': b.author,
      'publisher': b.publisher,
      'publishDate': b.publishDate?.toIso8601String(),
      'contentType': b.contentType.name,
      'sourceType': b.sourceType.name,
      'normalizedHost': b.normalizedHost,
      'isFavorite': b.isFavorite,
      'isArchived': b.isArchived,
      'isPinned': b.isPinned,
      'isRead': b.isRead,
      'inlineNotes': b.inlineNotes,
      'tagIds': b.tagIds,
      'collectionIds': b.collectionIds,
      'createdAt': b.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _tagToJson(Tag t) {
    return <String, dynamic>{
      'name': t.name,
      'slug': t.slug,
      'colorArgb': t.colorArgb,
      'icon': t.icon,
      'description': t.description,
      'isPinned': t.isPinned,
      'orderIndex': t.orderIndex,
      'createdAt': t.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _collectionToJson(BookmarkCollection c) {
    return <String, dynamic>{
      'title': c.title,
      'slug': c.slug,
      'description': c.description,
      'icon': c.icon,
      'accentColorArgb': c.accentColorArgb,
      'isPinned': c.isPinned,
      'isArchived': c.isArchived,
      'sortMode': c.sortMode.name,
      'orderIndex': c.orderIndex,
      'createdAt': c.createdAt.toIso8601String(),
    };
  }
}
