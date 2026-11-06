import 'package:flutter_test/flutter_test.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/smart_collection_evaluator.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';

void main() {
  const SmartCollectionEvaluator evaluator = DefaultSmartCollectionEvaluator();

  BookmarkCollection smart(SmartCollectionRule rule) {
    return BookmarkCollection(
      id: 1,
      title: 'Smart',
      slug: 'smart',
      isSmart: true,
      smartRuleJson: rule.encode(),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  Bookmark bookmark({
    int id = 1,
    List<int> tagIds = const <int>[],
    String host = 'example.com',
    BookmarkContentType contentType = BookmarkContentType.article,
    bool favorite = false,
    bool archived = false,
    bool read = false,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id,
      originalUrl: 'https://$host/$id',
      normalizedHost: host,
      tagIds: tagIds,
      contentType: contentType,
      isFavorite: favorite,
      isArchived: archived,
      isRead: read,
      createdAt: createdAt ?? DateTime(2026, 4, 25),
      updatedAt: createdAt ?? DateTime(2026, 4, 25),
    );
  }

  group('SmartCollectionRule JSON', () {
    test('round-trips all supported predicates', () {
      const SmartCollectionRule rule = SmartCollectionRule(
        filter: BookmarkFeedFilter.unread,
        tagId: 42,
        host: 'flutter.dev',
        contentType: BookmarkContentType.article,
        addedWithinDays: 7,
      );

      expect(SmartCollectionRule.decode(rule.encode()), rule);
    });
  });

  group('queryFor', () {
    test('returns null for manual collections', () {
      final BookmarkCollection manual = BookmarkCollection(
        id: 1,
        title: 'Manual',
        slug: 'manual',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(evaluator.queryFor(manual), isNull);
    });

    test('turns a smart rule into a feed query', () {
      final DateTime now = DateTime(2026, 4, 25);
      final BookmarkCollection collection = smart(
        const SmartCollectionRule(
          filter: BookmarkFeedFilter.favorites,
          tagId: 4,
          host: 'flutter.dev',
          contentType: BookmarkContentType.article,
          addedWithinDays: 7,
        ),
      );

      final BookmarkFeedQuery query = evaluator.queryFor(
        collection,
        now: now,
      )!;

      expect(query.filter, BookmarkFeedFilter.favorites);
      expect(query.tagId, 4);
      expect(query.host, 'flutter.dev');
      expect(query.contentType, BookmarkContentType.article);
      expect(query.createdAfter, DateTime(2026, 4, 18));
    });
  });

  group('matches', () {
    test('requires every predicate to match', () {
      final BookmarkCollection collection = smart(
        const SmartCollectionRule(
          filter: BookmarkFeedFilter.unread,
          tagId: 9,
          host: 'flutter.dev',
          contentType: BookmarkContentType.article,
          addedWithinDays: 7,
        ),
      );
      final DateTime now = DateTime(2026, 4, 25);

      expect(
        evaluator.matches(
          collection,
          bookmark(tagIds: <int>[9], host: 'flutter.dev'),
          now: now,
        ),
        isTrue,
      );
      expect(
        evaluator.matches(
          collection,
          bookmark(tagIds: <int>[9], host: 'flutter.dev', read: true),
          now: now,
        ),
        isFalse,
      );
      expect(
        evaluator.matches(
          collection,
          bookmark(tagIds: <int>[8], host: 'flutter.dev'),
          now: now,
        ),
        isFalse,
      );
      expect(
        evaluator.matches(
          collection,
          bookmark(
            tagIds: <int>[9],
            host: 'flutter.dev',
            createdAt: DateTime(2026, 4),
          ),
          now: now,
        ),
        isFalse,
      );
    });

    test('filter returns matching bookmarks only', () {
      final BookmarkCollection collection = smart(
        const SmartCollectionRule(contentType: BookmarkContentType.video),
      );

      final List<Bookmark> matches = evaluator.filter(
        collection,
        <Bookmark>[
          bookmark(contentType: BookmarkContentType.video),
          bookmark(id: 2),
          bookmark(id: 3, contentType: BookmarkContentType.video),
        ],
      );

      expect(matches.map((Bookmark b) => b.id), <int?>[1, 3]);
    });
  });
}
