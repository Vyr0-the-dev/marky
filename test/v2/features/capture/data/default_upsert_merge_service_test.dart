import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/capture/data/default_upsert_merge_service.dart';

void main() {
  const DefaultUpsertMergeService merger = DefaultUpsertMergeService();

  final DateTime now = DateTime(2025);

  Bookmark existing({
    String? title,
    String? description,
    String? heroImageUrl,
    String? faviconUrl,
    String? canonicalUrl,
    String? urlHash,
    String? externalContentId,
    BookmarkContentType contentType = BookmarkContentType.unknown,
    List<int> tagIds = const <int>[],
    List<int> collectionIds = const <int>[],
    String? inlineNotes,
    bool isFavorite = false,
    bool isPinned = false,
    int? readingTimeMinutes,
  }) {
    return Bookmark(
      id: 1,
      originalUrl: 'https://example.com/page',
      canonicalUrl: canonicalUrl,
      urlHash: urlHash,
      externalContentId: externalContentId,
      title: title,
      description: description,
      heroImageUrl: heroImageUrl,
      faviconUrl: faviconUrl,
      contentType: contentType,
      tagIds: tagIds,
      collectionIds: collectionIds,
      inlineNotes: inlineNotes,
      isFavorite: isFavorite,
      isPinned: isPinned,
      readingTimeMinutes: readingTimeMinutes,
      createdAt: now,
      updatedAt: now,
    );
  }

  Bookmark incoming({
    String? title,
    String? description,
    String? heroImageUrl,
    String? faviconUrl,
    String? canonicalUrl,
    String? urlHash,
    String? externalContentId,
    BookmarkContentType contentType = BookmarkContentType.unknown,
    List<int> tagIds = const <int>[],
    List<int> collectionIds = const <int>[],
    String? inlineNotes,
    int? readingTimeMinutes,
  }) {
    return Bookmark(
      originalUrl: 'https://example.com/page',
      canonicalUrl: canonicalUrl,
      urlHash: urlHash,
      externalContentId: externalContentId,
      title: title,
      description: description,
      heroImageUrl: heroImageUrl,
      faviconUrl: faviconUrl,
      contentType: contentType,
      tagIds: tagIds,
      collectionIds: collectionIds,
      inlineNotes: inlineNotes,
      readingTimeMinutes: readingTimeMinutes,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ─── String? fill-gap ──────────────────────────────────────────

  group('fill-gap for nullable strings', () {
    test('fills null title from incoming', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(title: 'New Title'),
      );
      expect(result.title, 'New Title');
    });

    test('keeps existing title when already set', () {
      final Bookmark result = merger.merge(
        existing(title: 'Old Title'),
        incoming(title: 'New Title'),
      );
      expect(result.title, 'Old Title');
    });

    test('fills null description from incoming', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(description: 'Desc'),
      );
      expect(result.description, 'Desc');
    });

    test('fills null heroImageUrl from incoming', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(heroImageUrl: 'https://img.com/hero.jpg'),
      );
      expect(result.heroImageUrl, 'https://img.com/hero.jpg');
    });

    test('fills null faviconUrl from incoming', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(faviconUrl: 'https://img.com/fav.ico'),
      );
      expect(result.faviconUrl, 'https://img.com/fav.ico');
    });

    test('fills null canonicalUrl from incoming', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(canonicalUrl: 'https://example.com/canonical'),
      );
      expect(result.canonicalUrl, 'https://example.com/canonical');
    });

    test('fills null urlHash from incoming', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(urlHash: 'hash_abc'),
      );
      expect(result.urlHash, 'hash_abc');
    });

    test('fills null externalContentId from incoming', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(externalContentId: 'youtube:abc'),
      );
      expect(result.externalContentId, 'youtube:abc');
    });
  });

  // ─── Content type upgrade ──────────────────────────────────────

  group('content type', () {
    test('upgrades from unknown to detected', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(contentType: BookmarkContentType.video),
      );
      expect(result.contentType, BookmarkContentType.video);
    });

    test('does not downgrade existing classification', () {
      final Bookmark result = merger.merge(
        existing(contentType: BookmarkContentType.article),
        incoming(contentType: BookmarkContentType.video),
      );
      expect(result.contentType, BookmarkContentType.article);
    });

    test('keeps existing when incoming is also unknown', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(),
      );
      expect(result.contentType, BookmarkContentType.unknown);
    });
  });

  // ─── List union ────────────────────────────────────────────────

  group('list union', () {
    test('unions tagIds without duplicates', () {
      final Bookmark result = merger.merge(
        existing(tagIds: <int>[1, 2, 3]),
        incoming(tagIds: <int>[2, 3, 4, 5]),
      );
      expect(result.tagIds, <int>[1, 2, 3, 4, 5]);
    });

    test('preserves existing order, appends new', () {
      final Bookmark result = merger.merge(
        existing(tagIds: <int>[10, 20]),
        incoming(tagIds: <int>[5, 10, 30]),
      );
      expect(result.tagIds, <int>[10, 20, 5, 30]);
    });

    test('unions collectionIds', () {
      final Bookmark result = merger.merge(
        existing(collectionIds: <int>[1]),
        incoming(collectionIds: <int>[1, 2]),
      );
      expect(result.collectionIds, <int>[1, 2]);
    });

    test('empty incoming leaves existing intact', () {
      final Bookmark result = merger.merge(
        existing(tagIds: <int>[1, 2]),
        incoming(),
      );
      expect(result.tagIds, <int>[1, 2]);
    });

    test('empty existing takes incoming', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(tagIds: <int>[1, 2]),
      );
      expect(result.tagIds, <int>[1, 2]);
    });
  });

  // ─── Flags & identity ─────────────────────────────────────────

  group('flags and identity', () {
    test('preserves id from existing', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(),
      );
      expect(result.id, 1);
    });

    test('preserves originalUrl from existing', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(),
      );
      expect(result.originalUrl, 'https://example.com/page');
    });

    test('preserves isFavorite from existing', () {
      final Bookmark result = merger.merge(
        existing(isFavorite: true),
        incoming(),
      );
      expect(result.isFavorite, isTrue);
    });

    test('preserves isPinned from existing', () {
      final Bookmark result = merger.merge(
        existing(isPinned: true),
        incoming(),
      );
      expect(result.isPinned, isTrue);
    });

    test('preserves createdAt from existing', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(),
      );
      expect(result.createdAt, now);
    });

    test('bumps updatedAt to a recent time', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(),
      );
      // updatedAt should be after the fixture time (2025-01-01).
      expect(result.updatedAt.isAfter(now), isTrue);
    });
  });

  // ─── Notes ─────────────────────────────────────────────────────

  group('notes', () {
    test('fills null notes from incoming', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(inlineNotes: 'New note'),
      );
      expect(result.inlineNotes, 'New note');
    });

    test('keeps existing notes', () {
      final Bookmark result = merger.merge(
        existing(inlineNotes: 'My note'),
        incoming(inlineNotes: 'Different note'),
      );
      expect(result.inlineNotes, 'My note');
    });
  });

  // ─── Reading time ──────────────────────────────────────────────

  group('reading time', () {
    test('fills null reading time from incoming', () {
      final Bookmark result = merger.merge(
        existing(),
        incoming(readingTimeMinutes: 5),
      );
      expect(result.readingTimeMinutes, 5);
    });

    test('keeps existing reading time', () {
      final Bookmark result = merger.merge(
        existing(readingTimeMinutes: 3),
        incoming(readingTimeMinutes: 10),
      );
      expect(result.readingTimeMinutes, 3);
    });
  });
}
