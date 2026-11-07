import 'package:flutter_test/flutter_test.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/search/domain/search_operator_query.dart';

void main() {
  const SearchOperatorParser parser = SearchOperatorParser();

  test('parses all supported operators and preserves free text', () {
    final SearchOperatorQuery query = parser.parse(
      'flutter tag:dart is:favorite domain:https://flutter.dev/docs '
      'before:2026-04-25 after:2026-04-01 async await',
    );

    expect(query.text, 'flutter async await');
    expect(query.tagSlug, 'dart');
    expect(query.status, SearchStatusOperator.favorite);
    expect(query.domain, 'flutter.dev');
    expect(query.createdAfter, DateTime(2026, 4));
    expect(query.createdBefore, DateTime(2026, 4, 25, 23, 59, 59, 999, 999));
  });

  test('supports quoted tag and collection values', () {
    final SearchOperatorQuery query = parser.parse(
      'tag:"Reading List" collection:"Design Inspiration" rust',
    );

    expect(query.tagSlug, 'reading-list');
    expect(query.collectionSlug, 'design-inspiration');
    expect(query.text, 'rust');
  });

  test('parses content type and has operators', () {
    final SearchOperatorQuery query = parser.parse(
      'type:video has:notes tutorial',
    );

    expect(query.contentType, BookmarkContentType.video);
    expect(query.has, SearchHasOperator.notes);
    expect(query.text, 'tutorial');
  });

  test('matches verifies content type, collection, and has notes', () {
    const SearchOperatorQuery query = SearchOperatorQuery(
      contentType: BookmarkContentType.video,
      has: SearchHasOperator.notes,
    );

    final Bookmark matching = Bookmark(
      id: 1,
      originalUrl: 'https://youtube.com/watch?v=123',
      contentType: BookmarkContentType.video,
      inlineNotes: 'Great explanation of isolates',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final Bookmark nonMatchingType = Bookmark(
      id: 2,
      originalUrl: 'https://example.com/article',
      contentType: BookmarkContentType.article,
      inlineNotes: 'Great explanation',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final Bookmark nonMatchingNotes = Bookmark(
      id: 3,
      originalUrl: 'https://youtube.com/watch?v=456',
      contentType: BookmarkContentType.video,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    expect(query.matches(matching), isTrue);
    expect(query.matches(nonMatchingType), isFalse);
    expect(query.matches(nonMatchingNotes), isFalse);
  });

  test('keeps invalid operator token in free text', () {
    final SearchOperatorQuery query =
        parser.parse('before:nope domain: article');

    expect(query.createdBefore, isNull);
    expect(query.domain, isNull);
    expect(query.text, 'before:nope domain: article');
  });
}
