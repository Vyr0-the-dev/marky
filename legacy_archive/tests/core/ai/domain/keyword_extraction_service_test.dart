import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/ai/domain/models/keyword_extraction_result.dart';
import 'package:marky/core/ai/domain/services/keyword_extraction_service.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

BookmarkItem _makeBookmark({
  String? title,
  String? description,
  String? extractedText,
  String? siteName,
  String? normalizedHost,
  String? sourceDomain,
  String? contentType,
}) {
  return BookmarkItem(
    originalUrl: 'https://example.com',
    title: title,
    description: description,
    extractedText: extractedText,
    siteName: siteName,
    normalizedHost: normalizedHost,
    sourceDomain: sourceDomain,
    contentType: contentType,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late HeuristicKeywordExtractionService service;

  setUp(() {
    service = HeuristicKeywordExtractionService();
  });

  // -----------------------------------------------------------------
  // 1. Happy path — keyword extraction
  // -----------------------------------------------------------------
  group('keyword extraction', () {
    test(
      'given title "Flutter State Management with Riverpod" '
      'returns keywords containing flutter and riverpod',
      () {
        final bookmark = _makeBookmark(
          title: 'Flutter State Management with Riverpod',
        );

        final result = service.extract(bookmark);

        expect(result.keywords, contains('flutter'));
        expect(result.keywords, contains('riverpod'));
        expect(result.category, isNull);
      },
    );

    test(
      'given github.com domain and title "Dart CLI tools" '
      'returns category development',
      () {
        final bookmark = _makeBookmark(
          normalizedHost: 'github.com',
          title: 'Dart CLI tools',
        );

        final result = service.extract(bookmark);

        expect(result.category, 'development');
      },
    );

    test(
      'given all-null text fields returns empty keywords and null category',
      () {
        final bookmark = _makeBookmark();

        final result = service.extract(bookmark);

        expect(result.keywords, isEmpty);
        expect(result.category, isNull);
      },
    );

    test('given text with only stopwords returns empty keywords', () {
      final bookmark = _makeBookmark(
        title: 'the and with for',
      );

      final result = service.extract(bookmark);

      expect(result.keywords, isEmpty);
    });

    test('given uppercase/mixed case returns lowercased keywords', () {
      final bookmark = _makeBookmark(
        title: 'Flutter DART riverPod',
      );

      final result = service.extract(bookmark);

      expect(result.keywords, contains('flutter'));
      expect(result.keywords, contains('dart'));
      expect(result.keywords, contains('riverpod'));
      // Ensure no uppercase remains
      for (final kw in result.keywords) {
        expect(kw, equals(kw.toLowerCase()));
      }
    });

    test('given more than 5 candidate keywords returns exactly 5', () {
      final bookmark = _makeBookmark(
        title: 'one two three four five six seven eight',
      );

      final result = service.extract(bookmark);

      expect(result.keywords.length, 5);
    });

    test(
      'calling extract twice on the same bookmark yields identical results',
      () {
        final bookmark = _makeBookmark(
          title: 'Flutter State Management with Riverpod',
          normalizedHost: 'medium.com',
        );

        final first = service.extract(bookmark);
        final second = service.extract(bookmark);

        expect(first, equals(second));
      },
    );
  });

  // -----------------------------------------------------------------
  // 2. Category derivation
  // -----------------------------------------------------------------
  group('category derivation', () {
    test('maps youtube.com to video', () {
      final bookmark = _makeBookmark(
        normalizedHost: 'youtube.com',
        title: 'Cool video',
      );

      final result = service.extract(bookmark);

      expect(result.category, 'video');
    });

    test('maps medium.com to article', () {
      final bookmark = _makeBookmark(
        normalizedHost: 'medium.com',
        title: 'Great read',
      );

      final result = service.extract(bookmark);

      expect(result.category, 'article');
    });

    test('maps reddit.com to discussion', () {
      final bookmark = _makeBookmark(
        normalizedHost: 'reddit.com',
        title: 'Hot thread',
      );

      final result = service.extract(bookmark);

      expect(result.category, 'discussion');
    });

    test('maps x.com to social', () {
      final bookmark = _makeBookmark(
        normalizedHost: 'x.com',
        title: 'Tweet storm',
      );

      final result = service.extract(bookmark);

      expect(result.category, 'social');
    });

    test('maps linkedin.com to professional', () {
      final bookmark = _makeBookmark(
        normalizedHost: 'linkedin.com',
        title: 'Career tips',
      );

      final result = service.extract(bookmark);

      expect(result.category, 'professional');
    });

    test('falls back to contentType when no domain match', () {
      final bookmark = _makeBookmark(
        normalizedHost: 'unknown.example.com',
        contentType: 'podcast',
        title: 'Audio content',
      );

      final result = service.extract(bookmark);

      expect(result.category, 'podcast');
    });

    test('falls back to null when no domain match and no contentType', () {
      final bookmark = _makeBookmark(
        normalizedHost: 'unknown.example.com',
        title: 'Random site',
      );

      final result = service.extract(bookmark);

      expect(result.category, isNull);
    });

    test('strips www prefix from host before matching', () {
      final bookmark = _makeBookmark(
        normalizedHost: 'www.github.com',
        title: 'Dart CLI tools',
      );

      final result = service.extract(bookmark);

      expect(result.category, 'development');
    });

    test('uses sourceDomain when normalizedHost is null', () {
      final bookmark = _makeBookmark(
        sourceDomain: 'youtube.com',
        title: 'Cool video',
      );

      final result = service.extract(bookmark);

      expect(result.category, 'video');
    });
  });

  // -----------------------------------------------------------------
  // 3. Keyword scoring determinism
  // -----------------------------------------------------------------
  group('keyword scoring', () {
    test('ranks more frequent words higher', () {
      // "dart" appears 3 times, "flutter" once
      final bookmark = _makeBookmark(
        title: 'dart',
        description: 'dart',
        extractedText: 'dart flutter',
      );

      final result = service.extract(bookmark);

      expect(result.keywords.first, 'dart');
    });

    test('alphabetical tie-breaker when frequencies are equal', () {
      // Both appear exactly once; alphabetical order should win
      final bookmark = _makeBookmark(
        title: 'zebra apple',
      );

      final result = service.extract(bookmark);

      expect(result.keywords.first, 'apple');
    });

    test('filters single-character tokens', () {
      final bookmark = _makeBookmark(
        title: 'a b c dart',
      );

      final result = service.extract(bookmark);

      expect(result.keywords, isNot(contains('a')));
      expect(result.keywords, isNot(contains('b')));
      expect(result.keywords, isNot(contains('c')));
      expect(result.keywords, contains('dart'));
    });

    test('combines text from all fields', () {
      final bookmark = _makeBookmark(
        title: 'flutter',
        description: 'state',
        extractedText: 'management',
        siteName: 'riverpod',
      );

      final result = service.extract(bookmark);

      expect(result.keywords, contains('flutter'));
      expect(result.keywords, contains('state'));
      expect(result.keywords, contains('management'));
      expect(result.keywords, contains('riverpod'));
    });
  });

  // -----------------------------------------------------------------
  // 4. Result immutability / contract
  // -----------------------------------------------------------------
  group('result contract', () {
    test('KeywordExtractionResult is immutable', () {
      const result = KeywordExtractionResult(
        keywords: ['flutter', 'dart'],
        category: 'development',
      );

      expect(result.keywords, ['flutter', 'dart']);
      expect(result.category, 'development');
    });

    test('empty result is equal to another empty result', () {
      const a = KeywordExtractionResult(keywords: []);
      const b = KeywordExtractionResult(keywords: []);

      expect(a, equals(b));
    });
  });
}
