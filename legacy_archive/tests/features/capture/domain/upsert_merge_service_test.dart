// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/capture/domain/models/save_bookmark_params.dart';
import 'package:marky/features/capture/domain/services/upsert_merge_service.dart';
import 'package:marky/shared/models/bookmark_item.dart';

void main() {
  group('UpsertMergeService', () {
    late UpsertMergeService service;

    setUp(() {
      service = UpsertMergeService.instance;
    });

    BookmarkItem makeExisting({
      List<int>? tagIds,
      List<int>? collectionIds,
      String? sharedText,
      String? resolvedUrl,
    }) {
      return BookmarkItem(
        originalUrl: 'https://example.com/article',
        sharedText: sharedText,
        resolvedUrl: resolvedUrl,
        tagIds: tagIds,
        collectionIds: collectionIds,
        createdAt: DateTime(2024, 1, 1, 10, 0, 0),
        updatedAt: DateTime(2024, 1, 1, 10, 0, 0),
        lastInteractionAt: DateTime(2024, 1, 1, 10, 0, 0),
      );
    }

    group('tag union', () {
      test('adds incoming tags to existing tags', () {
        final BookmarkItem existing = makeExisting(tagIds: <int>[1, 2]);
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          tagIds: <int>[2, 3],
        );

        service.merge(existing, incoming);

        expect(existing.tagIds, unorderedEquals(<int>[1, 2, 3]));
      });

      test('creates new tag list when existing has no tags', () {
        final BookmarkItem existing = makeExisting();
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          tagIds: <int>[10, 20],
        );

        service.merge(existing, incoming);

        expect(existing.tagIds, unorderedEquals(<int>[10, 20]));
      });

      test('null incoming tagIds is a no-op', () {
        final BookmarkItem existing = makeExisting(tagIds: <int>[1, 2]);
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.tagIds, unorderedEquals(<int>[1, 2]));
      });

      test('empty incoming tagIds leaves existing tags unchanged', () {
        final BookmarkItem existing = makeExisting(tagIds: <int>[1, 2]);
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          tagIds: <int>[],
        );

        service.merge(existing, incoming);

        expect(existing.tagIds, unorderedEquals(<int>[1, 2]));
      });
    });

    group('collection union', () {
      test('adds incoming collections to existing collections', () {
        final BookmarkItem existing =
            makeExisting(collectionIds: <int>[100, 200]);
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          collectionIds: <int>[200, 300],
        );

        service.merge(existing, incoming);

        expect(
          existing.collectionIds,
          unorderedEquals(<int>[100, 200, 300]),
        );
      });

      test('creates new collection list when existing has none', () {
        final BookmarkItem existing = makeExisting();
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          collectionIds: <int>[10],
        );

        service.merge(existing, incoming);

        expect(existing.collectionIds, unorderedEquals(<int>[10]));
      });

      test('null incoming collectionIds is a no-op', () {
        final BookmarkItem existing =
            makeExisting(collectionIds: <int>[100]);
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.collectionIds, unorderedEquals(<int>[100]));
      });

      test('empty incoming collectionIds leaves existing collections unchanged',
          () {
        final BookmarkItem existing =
            makeExisting(collectionIds: <int>[100]);
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          collectionIds: <int>[],
        );

        service.merge(existing, incoming);

        expect(existing.collectionIds, unorderedEquals(<int>[100]));
      });
    });

    group('sharedText', () {
      test('keeps existing sharedText when it is non-null', () {
        final BookmarkItem existing =
            makeExisting(sharedText: 'existing text');
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          sharedText: 'incoming text',
        );

        service.merge(existing, incoming);

        expect(existing.sharedText, 'existing text');
      });

      test('accepts incoming sharedText when existing is null', () {
        final BookmarkItem existing = makeExisting();
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          sharedText: 'incoming text',
        );

        service.merge(existing, incoming);

        expect(existing.sharedText, 'incoming text');
      });

      test('accepts incoming sharedText when existing is empty', () {
        final BookmarkItem existing = makeExisting(sharedText: '');
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          sharedText: 'incoming text',
        );

        service.merge(existing, incoming);

        expect(existing.sharedText, 'incoming text');
      });

      test('null incoming sharedText is a no-op', () {
        final BookmarkItem existing =
            makeExisting(sharedText: 'existing text');
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.sharedText, 'existing text');
      });

      test('empty incoming sharedText does not overwrite existing', () {
        final BookmarkItem existing =
            makeExisting(sharedText: 'existing text');
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          sharedText: '',
        );

        service.merge(existing, incoming);

        expect(existing.sharedText, 'existing text');
      });
    });

    group('resolvedUrl', () {
      test('keeps existing resolvedUrl when present', () {
        final BookmarkItem existing =
            makeExisting(resolvedUrl: 'https://existing.com');
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          rawUrl: 'https://incoming.com',
        );

        service.merge(existing, incoming);

        expect(existing.resolvedUrl, 'https://existing.com');
      });

      test('accepts rawUrl as resolvedUrl when existing is null', () {
        final BookmarkItem existing = makeExisting();
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          rawUrl: 'https://incoming.com',
        );

        service.merge(existing, incoming);

        expect(existing.resolvedUrl, 'https://incoming.com');
      });

      test('accepts rawUrl when existing resolvedUrl is empty', () {
        final BookmarkItem existing = makeExisting(resolvedUrl: '');
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          rawUrl: 'https://incoming.com',
        );

        service.merge(existing, incoming);

        expect(existing.resolvedUrl, 'https://incoming.com');
      });

      test('null rawUrl is a no-op', () {
        final BookmarkItem existing =
            makeExisting(resolvedUrl: 'https://existing.com');
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.resolvedUrl, 'https://existing.com');
      });
    });

    group('user flag preservation', () {
      test('preserves isFavorite under all conditions', () {
        final BookmarkItem existing = BookmarkItem(
          originalUrl: 'https://example.com/article',
          isFavorite: true,
          createdAt: DateTime(2024, 1, 1, 10, 0, 0),
          updatedAt: DateTime(2024, 1, 1, 10, 0, 0),
          lastInteractionAt: DateTime(2024, 1, 1, 10, 0, 0),
        );
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.isFavorite, isTrue);
      });

      test('preserves isArchived under all conditions', () {
        final BookmarkItem existing = BookmarkItem(
          originalUrl: 'https://example.com/article',
          isArchived: true,
          createdAt: DateTime(2024, 1, 1, 10, 0, 0),
          updatedAt: DateTime(2024, 1, 1, 10, 0, 0),
          lastInteractionAt: DateTime(2024, 1, 1, 10, 0, 0),
        );
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.isArchived, isTrue);
      });

      test('preserves isRead under all conditions', () {
        final BookmarkItem existing = BookmarkItem(
          originalUrl: 'https://example.com/article',
          isRead: true,
          createdAt: DateTime(2024, 1, 1, 10, 0, 0),
          updatedAt: DateTime(2024, 1, 1, 10, 0, 0),
          lastInteractionAt: DateTime(2024, 1, 1, 10, 0, 0),
        );
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.isRead, isTrue);
      });

      test('preserves isPinned under all conditions', () {
        final BookmarkItem existing = BookmarkItem(
          originalUrl: 'https://example.com/article',
          isPinned: true,
          createdAt: DateTime(2024, 1, 1, 10, 0, 0),
          updatedAt: DateTime(2024, 1, 1, 10, 0, 0),
          lastInteractionAt: DateTime(2024, 1, 1, 10, 0, 0),
        );
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.isPinned, isTrue);
      });

      test('preserves flags when they are false', () {
        final BookmarkItem existing = makeExisting();
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.isFavorite, isFalse);
        expect(existing.isArchived, isFalse);
        expect(existing.isRead, isFalse);
        expect(existing.isPinned, isFalse);
      });
    });

    group('timestamps', () {
      test('always refreshes updatedAt', () {
        final BookmarkItem existing = makeExisting();
        final DateTime before = DateTime.now();
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.updatedAt, isNotNull);
        expect(existing.updatedAt, greaterThanOrEqualTo(before));
      });

      test('always refreshes lastInteractionAt', () {
        final BookmarkItem existing = makeExisting();
        final DateTime before = DateTime.now();
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.lastInteractionAt, isNotNull);
        expect(existing.lastInteractionAt, greaterThanOrEqualTo(before));
      });
    });

    group('createdAt immutability', () {
      test('never modifies createdAt', () {
        final BookmarkItem existing = makeExisting();
        final DateTime originalCreatedAt = existing.createdAt;
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          tagIds: <int>[1],
          collectionIds: <int>[2],
          sharedText: 'new text',
          rawUrl: 'https://new.com',
        );

        service.merge(existing, incoming);

        expect(existing.createdAt, originalCreatedAt);
      });
    });

    group('enriched metadata preservation', () {
      test('preserves title, description, thumbnailUrl', () {
        final BookmarkItem existing = BookmarkItem(
          originalUrl: 'https://example.com',
          title: 'Original Title',
          description: 'Original Description',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          lastInteractionAt: DateTime(2024, 1, 1),
        );
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          rawUrl: 'https://incoming.com',
        );

        service.merge(existing, incoming);

        expect(existing.title, 'Original Title');
        expect(existing.description, 'Original Description');
        expect(existing.thumbnailUrl, 'https://example.com/thumb.jpg');
      });
    });

    group('sourceType preservation', () {
      test('preserves original sourceType', () {
        final BookmarkItem existing = BookmarkItem(
          originalUrl: 'https://example.com',
          sourceType: 'share_sheet',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          lastInteractionAt: DateTime(2024, 1, 1),
        );
        const SaveBookmarkParams incoming = SaveBookmarkParams(
          sourceType: 'clipboard',
        );

        service.merge(existing, incoming);

        expect(existing.sourceType, 'share_sheet');
      });
    });

    group('duplicateGroupId preservation', () {
      test('does not modify duplicateGroupId', () {
        final BookmarkItem existing = BookmarkItem(
          originalUrl: 'https://example.com',
          duplicateGroupId: 'group-abc',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          lastInteractionAt: DateTime(2024, 1, 1),
        );
        const SaveBookmarkParams incoming = SaveBookmarkParams();

        service.merge(existing, incoming);

        expect(existing.duplicateGroupId, 'group-abc');
      });
    });

    group('all-null params', () {
      test('only refreshes timestamps when all params are null', () {
        final BookmarkItem existing = BookmarkItem(
          originalUrl: 'https://example.com/article',
          tagIds: <int>[1],
          collectionIds: <int>[100],
          sharedText: 'hello',
          resolvedUrl: 'https://example.com',
          isFavorite: true,
          createdAt: DateTime(2024, 1, 1, 10, 0, 0),
          updatedAt: DateTime(2024, 1, 1, 10, 0, 0),
          lastInteractionAt: DateTime(2024, 1, 1, 10, 0, 0),
        );
        const SaveBookmarkParams incoming = SaveBookmarkParams();
        final DateTime originalCreatedAt = existing.createdAt;

        service.merge(existing, incoming);

        // Timestamps refreshed.
        expect(existing.updatedAt.isAfter(DateTime(2024, 1, 1, 10, 0, 0)), isTrue);
        expect(
          existing.lastInteractionAt!.isAfter(DateTime(2024, 1, 1, 10, 0, 0)),
          isTrue,
        );

        // Everything else untouched.
        expect(existing.tagIds, unorderedEquals(<int>[1]));
        expect(existing.collectionIds, unorderedEquals(<int>[100]));
        expect(existing.sharedText, 'hello');
        expect(existing.resolvedUrl, 'https://example.com');
        expect(existing.isFavorite, isTrue);
        expect(existing.createdAt, originalCreatedAt);
      });
    });
  });
}
