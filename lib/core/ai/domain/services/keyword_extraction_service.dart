import 'package:logger/logger.dart';
import 'package:marky/core/ai/domain/models/keyword_extraction_result.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Contract for keyword extraction and category assignment services.
///
/// Implementations must be deterministic: calling [extract] twice with the
/// same bookmark must yield identical results. This allows caching and
/// reproducible test assertions.
// ignore: one_member_abstracts
abstract class KeywordExtractionService {
  /// Extracts keywords and suggests a category for [bookmark].
  ///
  /// Returns an empty result when the bookmark has no extractable text.
  KeywordExtractionResult extract(BookmarkItem bookmark);
}

/// A pure-Dart heuristic implementation of [KeywordExtractionService]
/// with no external ML dependencies.
///
/// ## Algorithm
/// 1. Concatenate `title`, `description`, `extractedText`, and `siteName`.
/// 2. Tokenize by splitting on non-alphanumeric characters.
/// 3. Lowercase and filter out stopwords.
/// 4. Score tokens by frequency.
/// 5. Return the top 5 most frequent unique tokens.
/// 6. Derive category from a domain-to-category map, falling back to
///    `contentType` if no domain match.
///
/// All operations are synchronous and deterministic.
class HeuristicKeywordExtractionService implements KeywordExtractionService {
  HeuristicKeywordExtractionService({Logger? logger})
      : _logger = logger ?? Logger();

  final Logger _logger;

  /// Domain-to-category mapping for common sites.
  static const Map<String, String> _domainCategoryMap = {
    'github.com': 'development',
    'gitlab.com': 'development',
    'stackoverflow.com': 'development',
    'youtube.com': 'video',
    'youtu.be': 'video',
    'medium.com': 'article',
    'substack.com': 'article',
    'reddit.com': 'discussion',
    'x.com': 'social',
    'twitter.com': 'social',
    'linkedin.com': 'professional',
    'arxiv.org': 'research',
    'producthunt.com': 'product',
    'news.ycombinator.com': 'news',
  };

  static final RegExp _wordSplitter = RegExp('[^a-zA-Z0-9]+');

  @override
  KeywordExtractionResult extract(BookmarkItem bookmark) {
    _logger.d(
      'KeywordExtraction: starting extraction for bookmark ${bookmark.id}',
    );

    final textBuffer = StringBuffer()
      ..write(bookmark.title ?? '')
      ..write(' ')
      ..write(bookmark.description ?? '')
      ..write(' ')
      ..write(bookmark.extractedText ?? '')
      ..write(' ')
      ..write(bookmark.siteName ?? '');

    final rawText = textBuffer.toString().trim();

    if (rawText.isEmpty) {
      _logger.d(
        'KeywordExtraction: bookmark ${bookmark.id} has no text fields — '
        'returning empty result',
      );
      return const KeywordExtractionResult(keywords: []);
    }

    // ── Tokenize, lowercase, filter stopwords ────────────────────────────
    final tokens = rawText
        .split(_wordSplitter)
        .where((s) => s.isNotEmpty)
        .map((s) => s.toLowerCase())
        .where((s) => !_stopwords.contains(s))
        .where((s) => s.length > 1); // drop single-char tokens

    // ── Score by frequency ───────────────────────────────────────────────
    final frequency = <String, int>{};
    for (final token in tokens) {
      frequency[token] = (frequency[token] ?? 0) + 1;
    }

    // Sort by frequency descending, then alphabetically for determinism
    final sorted = frequency.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.compareTo(a.value);
        return cmp != 0 ? cmp : a.key.compareTo(b.key);
      });

    final keywords = sorted.take(5).map((e) => e.key).toList();

    // ── Category derivation ──────────────────────────────────────────────
    final category = _deriveCategory(bookmark);

    _logger.d(
      'KeywordExtraction: bookmark ${bookmark.id} — '
      '${keywords.length} keywords extracted, category=$category',
    );

    return KeywordExtractionResult(
      keywords: keywords,
      category: category,
    );
  }

  /// Derives a category from domain mapping or content type.
  String? _deriveCategory(BookmarkItem bookmark) {
    final host = bookmark.normalizedHost ?? bookmark.sourceDomain;
    if (host != null && host.isNotEmpty) {
      // Try exact match first
      var mapped = _domainCategoryMap[host.toLowerCase()];
      if (mapped != null) return mapped;

      // Try stripping www prefix
      final withoutWww = host.toLowerCase().replaceFirst(RegExp('^www.'), '');
      mapped = _domainCategoryMap[withoutWww];
      if (mapped != null) return mapped;
    }

    // Fall back to contentType when it looks like a known category
    final contentType = bookmark.contentType;
    if (contentType != null && contentType.isNotEmpty) {
      return contentType.toLowerCase();
    }

    return null;
  }
}

// ─── Stopword list ──────────────────────────────────────────────────────────

const Set<String> _stopwords = {
  'a',
  'about',
  'above',
  'after',
  'again',
  'against',
  'all',
  'am',
  'an',
  'and',
  'any',
  'are',
  'as',
  'at',
  'be',
  'because',
  'been',
  'before',
  'being',
  'below',
  'between',
  'both',
  'but',
  'by',
  'can',
  'cannot',
  'could',
  'did',
  'do',
  'does',
  'doing',
  'down',
  'during',
  'each',
  'few',
  'for',
  'from',
  'further',
  'had',
  'has',
  'have',
  'having',
  'he',
  'her',
  'here',
  'hers',
  'herself',
  'him',
  'himself',
  'his',
  'how',
  'i',
  'if',
  'in',
  'into',
  'is',
  'it',
  'its',
  'itself',
  'let',
  'me',
  'more',
  'most',
  'my',
  'myself',
  'no',
  'nor',
  'not',
  'of',
  'off',
  'on',
  'once',
  'only',
  'or',
  'other',
  'our',
  'ours',
  'ourselves',
  'out',
  'over',
  'own',
  'same',
  'she',
  'should',
  'so',
  'some',
  'such',
  'than',
  'that',
  'the',
  'their',
  'theirs',
  'them',
  'themselves',
  'then',
  'there',
  'these',
  'they',
  'this',
  'those',
  'through',
  'to',
  'too',
  'under',
  'until',
  'up',
  'very',
  'was',
  'we',
  'were',
  'what',
  'when',
  'where',
  'which',
  'while',
  'who',
  'whom',
  'why',
  'with',
  'would',
  'you',
  'your',
  'yours',
  'yourself',
  'yourselves',
};
