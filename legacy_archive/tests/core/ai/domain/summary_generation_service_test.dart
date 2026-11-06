import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/ai/domain/services/summary_generation_service.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

BookmarkItem _makeBookmark({
  String? title,
  String? description,
  String? extractedText,
  String? snippet,
}) {
  return BookmarkItem(
    originalUrl: 'https://example.com',
    title: title,
    description: description,
    extractedText: extractedText,
    snippet: snippet,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late HeuristicSummaryGenerationService service;

  setUp(() {
    service = HeuristicSummaryGenerationService();
  });

  // -----------------------------------------------------------------
  // 1. Happy path — description with multiple sentences
  // -----------------------------------------------------------------
  group('happy path', () {
    test(
      'given description with two sentences returns both sentences',
      () {
        final bookmark = _makeBookmark(
          description: 'First sentence here. Second sentence there.',
        );

        final result = service.generate(bookmark);

        expect(result, 'First sentence here. Second sentence there.');
      },
    );

    test(
      'given description with three sentences returns first two only',
      () {
        final bookmark = _makeBookmark(
          description:
              'Alpha starts the story. Beta continues the narrative. '
              'Gamma ends everything.',
        );

        final result = service.generate(bookmark);

        expect(result, 'Alpha starts the story. Beta continues the narrative.');
      },
    );

    test(
      'given description with exclamation and question marks as boundaries',
      () {
        final bookmark = _makeBookmark(
          description: 'What a day! Is this real? Amazing stuff.',
        );

        final result = service.generate(bookmark);

        expect(result, 'What a day! Is this real?');
      },
    );

    test('trims and normalizes whitespace in output', () {
      final bookmark = _makeBookmark(
        description: '  Leading space.  Trailing space.  ',
      );

      final result = service.generate(bookmark);

      expect(result, 'Leading space. Trailing space.');
    });
  });

  // -----------------------------------------------------------------
  // 2. Fallback chain
  // -----------------------------------------------------------------
  group('fallback chain', () {
    test('falls back to extractedText when description is null', () {
      final bookmark = _makeBookmark(
        description: null,
        extractedText: 'Extracted text sentence one. Sentence two here.',
      );

      final result = service.generate(bookmark);

      expect(result, 'Extracted text sentence one. Sentence two here.');
    });

    test('falls back to extractedText when description is empty', () {
      final bookmark = _makeBookmark(
        description: '   ',
        extractedText: 'Real content here. More content.',
      );

      final result = service.generate(bookmark);

      expect(result, 'Real content here. More content.');
    });

    test('falls back to snippet when description and extractedText are null',
        () {
      final bookmark = _makeBookmark(
        description: null,
        extractedText: null,
        snippet: 'Snippet sentence one. Snippet sentence two.',
      );

      final result = service.generate(bookmark);

      expect(result, 'Snippet sentence one. Snippet sentence two.');
    });

    test(
      'falls back to title condensation when all body fields are null',
      () {
        final bookmark = _makeBookmark(
          title: 'A Great Article About Flutter',
          description: null,
          extractedText: null,
          snippet: null,
        );

        final result = service.generate(bookmark);

        expect(result, 'A Great Article About Flutter');
      },
    );

    test(
      'title fallback truncates to 80 chars with ellipsis when too long',
      () {
        final longTitle =
            'This is an extremely long title that definitely exceeds the '
            'eighty character limit and should be truncated properly';
        final bookmark = _makeBookmark(
          title: longTitle,
          description: null,
          extractedText: null,
          snippet: null,
        );

        final result = service.generate(bookmark);

        expect(result!.length, lessThanOrEqualTo(80));
        expect(result.endsWith('…'), isTrue);
      },
    );

    test('title fallback does not truncate short titles', () {
      final bookmark = _makeBookmark(
        title: 'Short title',
        description: null,
        extractedText: null,
        snippet: null,
      );

      final result = service.generate(bookmark);

      expect(result, 'Short title');
    });
  });

  // -----------------------------------------------------------------
  // 3. Empty input
  // -----------------------------------------------------------------
  group('empty input', () {
    test('returns null when all text fields are null', () {
      final bookmark = _makeBookmark();

      final result = service.generate(bookmark);

      expect(result, isNull);
    });

    test('returns null when all text fields are empty or whitespace', () {
      final bookmark = _makeBookmark(
        title: '   ',
        description: '\n\t  ',
        extractedText: '',
        snippet: '    ',
      );

      final result = service.generate(bookmark);

      expect(result, isNull);
    });

    test('returns null when title is null and all body fields are null', () {
      final bookmark = _makeBookmark(
        title: null,
        description: null,
        extractedText: null,
        snippet: null,
      );

      final result = service.generate(bookmark);

      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 4. Long text truncation
  // -----------------------------------------------------------------
  group('long text truncation', () {
    test(
      'truncates description to exactly two sentences when more exist',
      () {
        final bookmark = _makeBookmark(
          description: 'One. Two. Three. Four. Five.',
        );

        final result = service.generate(bookmark);

        expect(result, 'One. Two.');
      },
    );

    test('returns single sentence when only one exists', () {
      final bookmark = _makeBookmark(
        description: 'Only one sentence here.',
      );

      final result = service.generate(bookmark);

      expect(result, 'Only one sentence here.');
    });

    test('handles text without sentence boundaries as single sentence', () {
      final bookmark = _makeBookmark(
        description: 'No punctuation boundaries here',
      );

      final result = service.generate(bookmark);

      expect(result, 'No punctuation boundaries here');
    });
  });

  // -----------------------------------------------------------------
  // 5. Deterministic output
  // -----------------------------------------------------------------
  group('determinism', () {
    test('calling generate twice yields identical results', () {
      final bookmark = _makeBookmark(
        description: 'First sentence. Second sentence. Third sentence.',
      );

      final first = service.generate(bookmark);
      final second = service.generate(bookmark);

      expect(first, equals(second));
    });

    test('different services produce same result for same bookmark', () {
      final bookmark = _makeBookmark(
        description: 'Sentence one. Sentence two.',
      );

      final serviceA = HeuristicSummaryGenerationService();
      final serviceB = HeuristicSummaryGenerationService();

      final resultA = serviceA.generate(bookmark);
      final resultB = serviceB.generate(bookmark);

      expect(resultA, equals(resultB));
    });
  });

  // -----------------------------------------------------------------
  // 6. Description priority over other fields
  // -----------------------------------------------------------------
  group('description priority', () {
    test('uses description even when extractedText and snippet exist', () {
      final bookmark = _makeBookmark(
        description: 'Description wins. Always.',
        extractedText: 'Extracted text is longer but lower priority.',
        snippet: 'Snippet here.',
      );

      final result = service.generate(bookmark);

      expect(result, 'Description wins. Always.');
    });
  });

  // -----------------------------------------------------------------
  // 7. Edge cases
  // -----------------------------------------------------------------
  group('edge cases', () {
    test('handles description with only punctuation and whitespace', () {
      final bookmark = _makeBookmark(
        description: '. ! ?    ',
      );

      final result = service.generate(bookmark);

      // After trimming, the punctuation characters alone become empty sentences
      // and get filtered out, so it falls through to null
      expect(result, isNull);
    });

    test('handles single word title correctly', () {
      final bookmark = _makeBookmark(
        title: 'Flutter',
        description: null,
        extractedText: null,
        snippet: null,
      );

      final result = service.generate(bookmark);

      expect(result, 'Flutter');
    });

    test('handles multi-line description text', () {
      final bookmark = _makeBookmark(
        description: 'Line one here.\nLine two there.\nLine three everywhere.',
      );

      final result = service.generate(bookmark);

      expect(result, 'Line one here. Line two there.');
    });
  });
}
