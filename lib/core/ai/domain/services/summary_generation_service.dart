import 'package:logger/logger.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Contract for content summarization services.
///
/// Implementations produce a short textual summary from a bookmark's
/// available text fields.  The service is deterministic and never throws;
/// it returns [null] when no summary can be produced or when an error
/// occurs.
// ignore: one_member_abstracts
abstract class SummaryGenerationService {
  /// Generates a summary for [bookmark].
  ///
  /// Returns [null] when the bookmark has no extractable text or when
  /// summarization fails.
  String? generate(BookmarkItem bookmark);
}

/// A pure-Dart heuristic implementation of [SummaryGenerationService]
/// with no external ML dependencies.
///
/// ## Algorithm
/// 1. Try [BookmarkItem.description]; extract up to 2 complete sentences.
/// 2. Fall back to [BookmarkItem.extractedText]; extract up to 2 sentences.
/// 3. Fall back to [BookmarkItem.snippet]; extract up to 2 sentences.
/// 4. Fall back to condensing [BookmarkItem.title] to its first 80 chars.
/// 5. Return [null] when all text sources are empty or missing.
///
/// Sentence boundaries are detected with the regex `[.!?]\s+`.
/// Output is trimmed and whitespace-normalized.
///
/// All operations are synchronous, deterministic, and safe — the service
/// never throws.
class HeuristicSummaryGenerationService implements SummaryGenerationService {
  HeuristicSummaryGenerationService({Logger? logger})
      : _logger = logger ?? Logger();

  final Logger _logger;

  static final RegExp _sentenceBoundary = RegExp(r'[.!?]\s+');
  static const int _maxSentences = 2;
  static const int _titleFallbackMaxLength = 80;

  @override
  String? generate(BookmarkItem bookmark) {
    try {
      _logger.d(
        'SummaryGeneration: starting for bookmark ${bookmark.id}',
      );

      // ── Try description first ────────────────────────────────────────
      final description = bookmark.description;
      if (description != null && description.trim().isNotEmpty) {
        final summary = _extractSentences(description, _maxSentences);
        if (summary != null && summary.isNotEmpty) {
          _logger.d(
            'SummaryGeneration: bookmark ${bookmark.id} — '
            'summary from description (${_sentenceCount(summary)} sentences)',
          );
          return summary;
        }
      }

      // ── Fall back to extractedText ───────────────────────────────────
      final extractedText = bookmark.extractedText;
      if (extractedText != null && extractedText.trim().isNotEmpty) {
        final summary = _extractSentences(extractedText, _maxSentences);
        if (summary != null && summary.isNotEmpty) {
          _logger.d(
            'SummaryGeneration: bookmark ${bookmark.id} — '
            'summary from extractedText (${_sentenceCount(summary)} sentences)',
          );
          return summary;
        }
      }

      // ── Fall back to snippet ─────────────────────────────────────────
      final snippet = bookmark.snippet;
      if (snippet != null && snippet.trim().isNotEmpty) {
        final summary = _extractSentences(snippet, _maxSentences);
        if (summary != null && summary.isNotEmpty) {
          _logger.d(
            'SummaryGeneration: bookmark ${bookmark.id} — '
            'summary from snippet (${_sentenceCount(summary)} sentences)',
          );
          return summary;
        }
      }

      // ── Final fallback: condense title ───────────────────────────────
      final title = bookmark.title;
      if (title != null && title.trim().isNotEmpty) {
        final condensed = _condenseTitle(title);
        _logger.d(
          'SummaryGeneration: bookmark ${bookmark.id} — '
          'fallback to condensed title',
        );
        return condensed;
      }

      // ── Nothing available ────────────────────────────────────────────
      _logger.d(
        'SummaryGeneration: bookmark ${bookmark.id} — '
        'no text sources available, returning null',
      );
      return null;
    } catch (e, stack) {
      _logger.w(
        'SummaryGeneration: error generating summary for bookmark '
        '${bookmark.id}: $e',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Extracts up to [maxSentences] complete sentences from [text].
  ///
  /// Scans for sentence-ending punctuation (`.`, `!`, `?`) that is followed
  /// by whitespace or the end of the string.  If no sentence boundaries are
  /// found but the text has meaningful content, the whole text is returned as
  /// a single sentence.
  ///
  /// Returns [null] when [text] is empty or contains no meaningful content.
  String? _extractSentences(String text, int maxSentences) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final sentences = <String>[];
    var start = 0;
    var foundBoundary = false;

    for (var i = 0;
        i < trimmed.length && sentences.length < maxSentences;
        i++) {
      if (trimmed[i] == '.' || trimmed[i] == '!' || trimmed[i] == '?') {
        final isEndOfString = i == trimmed.length - 1;
        final isFollowedBySpace =
            !isEndOfString && trimmed[i + 1].trim().isEmpty;

        if (isEndOfString || isFollowedBySpace) {
          foundBoundary = true;
          final sentence = trimmed.substring(start, i + 1).trim();
          if (sentence.isNotEmpty && _hasContent(sentence)) {
            sentences.add(sentence);
          }
          while (i < trimmed.length - 1 && trimmed[i + 1].trim().isEmpty) {
            i++;
          }
          start = i + 1;
        }
      }
    }

    if (sentences.isEmpty) {
      if (!foundBoundary && _hasContent(trimmed)) {
        // No sentence boundaries found — return whole text as one sentence.
        return trimmed;
      }
      return null;
    }

    return sentences.join(' ');
  }

  /// Condenses [title] to at most [_titleFallbackMaxLength] characters.
  ///
  /// If truncation is needed, an ellipsis is appended and the result is
  /// trimmed to fit exactly within the limit.
  String _condenseTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.length <= _titleFallbackMaxLength) {
      return trimmed;
    }

    const ellipsis = '…';
    final cutAt = _titleFallbackMaxLength - ellipsis.length;
    return '${trimmed.substring(0, cutAt)}$ellipsis';
  }

  /// Returns the approximate sentence count for logging purposes.
  int _sentenceCount(String text) {
    if (text.isEmpty) return 0;
    return _sentenceBoundary.allMatches(text).length + 1;
  }

  /// Returns `true` when [text] contains at least one letter or digit.
  bool _hasContent(String text) {
    return RegExp(r'[a-zA-Z0-9]').hasMatch(text);
  }
}
