import 'package:flutter_test/flutter_test.dart';

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

  test('supports quoted tag values', () {
    final SearchOperatorQuery query = parser.parse('tag:"Reading List" rust');

    expect(query.tagSlug, 'reading-list');
    expect(query.text, 'rust');
  });

  test('keeps invalid operator token in free text', () {
    final SearchOperatorQuery query =
        parser.parse('before:nope domain: article');

    expect(query.createdBefore, isNull);
    expect(query.domain, isNull);
    expect(query.text, 'before:nope domain: article');
  });
}
