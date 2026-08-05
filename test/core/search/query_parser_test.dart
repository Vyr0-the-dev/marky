import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/core/search/query_parser.dart';

void main() {
  group('QueryParser', () {
    test('empty string yields empty SearchQuery', () {
      final result = QueryParser.parse('');
      expect(result.isEmpty, isTrue);
      expect(result.freeText, isEmpty);
      expect(result.operators, isEmpty);
    });

    test('whitespace-only string yields empty SearchQuery', () {
      final result = QueryParser.parse('     ');
      expect(result.isEmpty, isTrue);
    });

    test('tab and newline whitespace yields empty SearchQuery', () {
      final result = QueryParser.parse('\t\n  \r ');
      expect(result.isEmpty, isTrue);
    });

    test('plain free-text tokens are collected', () {
      final result = QueryParser.parse('flutter dart riverpod');
      expect(result.freeText, <String>['flutter', 'dart', 'riverpod']);
      expect(result.operators, isEmpty);
      expect(result.isEmpty, isFalse);
    });

    test('single operator is parsed', () {
      final result = QueryParser.parse('tag:mobile');
      expect(result.freeText, isEmpty);
      expect(result.operators, <String, List<String>>{
        'tag': <String>['mobile'],
      });
    });

    test('multiple operators are parsed', () {
      final result = QueryParser.parse('tag:foo tag:bar domain:example.com');
      expect(result.freeText, isEmpty);
      expect(result.operators['tag'], <String>['foo', 'bar']);
      expect(result.operators['domain'], <String>['example.com']);
    });

    test('mixed free-text and operators', () {
      final result = QueryParser.parse('flutter tutorials tag:mobile is:favorite');
      expect(result.freeText, <String>['flutter', 'tutorials']);
      expect(result.operators['tag'], <String>['mobile']);
      expect(result.operators['is'], <String>['favorite']);
    });

    test('double-quoted strings are treated as single tokens', () {
      final result = QueryParser.parse('"hello world" tag:foo');
      expect(result.freeText, <String>['hello world']);
      expect(result.operators['tag'], <String>['foo']);
    });

    test('quoted string containing operator-like text stays free-text', () {
      final result = QueryParser.parse('"tag:not an operator"');
      expect(result.freeText, <String>['tag:not an operator']);
      expect(result.operators, isEmpty);
    });

    test('unmatched quote is treated literally', () {
      final result = QueryParser.parse('"unmatched tag:foo');
      expect(result.freeText, <String>['"unmatched', 'tag:foo']);
      expect(result.operators, isEmpty);
    });

    test('empty quotes yield empty token', () {
      final result = QueryParser.parse('""');
      expect(result.freeText, <String>['']);
    });

    test('unknown operator falls back to free-text', () {
      final result = QueryParser.parse('unknown:value');
      expect(result.freeText, <String>['unknown:value']);
      expect(result.operators, isEmpty);
    });

    test('operator keys are case-insensitive', () {
      final result = QueryParser.parse('TAG:foo Is:Archived DOMAIN:Example.COM');
      expect(result.operators['tag'], <String>['foo']);
      expect(result.operators['is'], <String>['Archived']);
      expect(result.operators['domain'], <String>['Example.COM']);
    });

    test('all recognized is: values are parsed', () {
      final result = QueryParser.parse('is:favorite is:archived is:unread');
      expect(result.operators['is'], <String>['favorite', 'archived', 'unread']);
    });

    test('has:note operator is parsed', () {
      final result = QueryParser.parse('has:note');
      expect(result.operators['has'], <String>['note']);
    });

    test('in:vault operator is parsed', () {
      final result = QueryParser.parse('in:vault');
      expect(result.operators['in'], <String>['vault']);
    });

    test('source: and type: operators are parsed', () {
      final result = QueryParser.parse('source:youtube type:video');
      expect(result.operators['source'], <String>['youtube']);
      expect(result.operators['type'], <String>['video']);
    });

    test('before: and after: operators are parsed', () {
      final result = QueryParser.parse('before:2024-01-01 after:2023-01-01');
      expect(result.operators['before'], <String>['2024-01-01']);
      expect(result.operators['after'], <String>['2023-01-01']);
    });

    test('colon without prefix falls back to free-text', () {
      final result = QueryParser.parse(':value');
      expect(result.freeText, <String>[':value']);
      expect(result.operators, isEmpty);
    });

    test('multiple spaces between tokens are collapsed', () {
      final result = QueryParser.parse('hello    world   tag:foo');
      expect(result.freeText, <String>['hello', 'world']);
      expect(result.operators['tag'], <String>['foo']);
    });

    // ─── Boundary / negative tests ───────────────────────────────────────

    test('very long token is handled', () {
      final longToken = 'a' * 1000;
      final result = QueryParser.parse(longToken);
      expect(result.freeText, hasLength(1));
      expect(result.freeText.first, hasLength(1000));
    });

    test('many operators are handled', () {
      final buffer = StringBuffer();
      for (var i = 0; i < 50; i++) {
        buffer.write('tag:value$i ');
      }
      final result = QueryParser.parse(buffer.toString());
      expect(result.operators['tag'], hasLength(50));
    });

    test('SearchQuery copyWith replaces freeText', () {
      const query = SearchQuery(freeText: <String>['hello']);
      final copy = query.copyWith(freeText: <String>['world']);
      expect(copy.freeText, <String>['world']);
      expect(copy.operators, isEmpty);
    });

    test('SearchQuery copyWith replaces operators', () {
      const query = SearchQuery(
        operators: <String, List<String>>{'tag': <String>['foo']},
      );
      final copy = query.copyWith(
        operators: <String, List<String>>{'is': <String>['favorite']},
      );
      expect(copy.operators['is'], <String>['favorite']);
      expect(copy.freeText, isEmpty);
    });

    test('SearchQuery operatorValues returns empty list for missing key', () {
      const query = SearchQuery();
      expect(query.operatorValues('tag'), isEmpty);
    });

    test('SearchQuery hasOperator is case-insensitive', () {
      const query = SearchQuery(
        operators: <String, List<String>>{'tag': <String>['foo']},
      );
      expect(query.hasOperator('tag'), isTrue);
      expect(query.hasOperator('TAG'), isTrue);
      expect(query.hasOperator('is'), isFalse);
    });

    test('SearchQuery equality works via Equatable', () {
      const a = SearchQuery(
        freeText: <String>['hello'],
        operators: <String, List<String>>{'tag': <String>['foo']},
      );
      const b = SearchQuery(
        freeText: <String>['hello'],
        operators: <String, List<String>>{'tag': <String>['foo']},
      );
      const c = SearchQuery(freeText: <String>['world']);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
