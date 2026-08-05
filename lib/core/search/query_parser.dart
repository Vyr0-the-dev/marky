import 'package:marky/core/search/models/search_query.dart';

/// Parses raw user search input into a structured [SearchQuery].
///
/// Supports free-text tokens and structured operators:
/// `tag:`, `source:`, `domain:`, `type:`, `is:`, `has:`, `in:`,
/// `before:`, `after:`.
///
/// Double-quoted strings are treated as single tokens even if they
/// contain spaces. Unrecognized `prefix:value` tokens fall back to
/// free-text.
class QueryParser {
  QueryParser._();

  static const Set<String> _recognizedOperators = <String>{
    'tag',
    'source',
    'domain',
    'type',
    'is',
    'has',
    'in',
    'before',
    'after',
  };

  /// Parses [input] and returns a [SearchQuery].
  ///
  /// Empty or whitespace-only input yields an empty [SearchQuery].
  static SearchQuery parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const SearchQuery();
    }

    final tokens = _tokenize(trimmed);
    final freeText = <String>[];
    final operators = <String, List<String>>{};

    for (final entry in tokens) {
      final token = entry.$1;
      final isQuoted = entry.$2;

      // Quoted tokens and unmatched-quote literals are always free-text.
      if (isQuoted) {
        freeText.add(token);
        continue;
      }

      final operatorEntry = _tryParseOperator(token);
      if (operatorEntry != null) {
        final (key, value) = operatorEntry;
        operators.putIfAbsent(key, () => <String>[]).add(value);
      } else {
        freeText.add(token);
      }
    }

    return SearchQuery(
      freeText: freeText,
      operators: operators,
    );
  }

  /// Splits [input] on whitespace while respecting double-quoted strings.
  ///
  /// Returns a list of `(token, isQuoted)` pairs. Quotes are stripped from
  /// quoted tokens. Unmatched quotes are treated literally — the `"` becomes
  /// part of the token and normal whitespace splitting resumes; tokens that
  /// originate from an unmatched-quoted region bypass operator parsing and
  /// are always treated as free-text.
  static List<(String, bool)> _tokenize(String input) {
    final tokens = <(String, bool)>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];

      if (char == '"') {
        if (inQuotes) {
          // Closing quote — flush buffer as a single quoted token
          tokens.add((buffer.toString(), true));
          buffer.clear();
          inQuotes = false;
        } else {
          // Opening quote — flush any pending unquoted content first
          if (buffer.isNotEmpty) {
            tokens.add((buffer.toString(), false));
            buffer.clear();
          }
          inQuotes = true;
        }
        continue;
      }

      if (!inQuotes && _isWhitespace(char)) {
        if (buffer.isNotEmpty) {
          tokens.add((buffer.toString(), false));
          buffer.clear();
        }
        continue;
      }

      buffer.write(char);
    }

    // Flush remaining buffer
    if (inQuotes) {
      if (buffer.isNotEmpty) {
        // Unmatched quote — treat the opening quote literally and
        // resume normal whitespace splitting. Mark every resulting token
        // as quoted so it bypasses operator parsing.
        final literal = '"$buffer';
        final parts = literal.split(RegExp(r'\s+'));
        for (final part in parts) {
          if (part.isNotEmpty) {
            tokens.add((part, true));
          }
        }
      } else {
        // Lone unmatched quote
        tokens.add(('"', true));
      }
    } else if (buffer.isNotEmpty) {
      tokens.add((buffer.toString(), false));
    }

    return tokens;
  }

  static bool _isWhitespace(String char) {
    final code = char.codeUnitAt(0);
    return code == 0x20 || code == 0x09 || code == 0x0A || code == 0x0D;
  }

  /// Attempts to parse [token] as `prefix:value`.
  ///
  /// Returns `(key, value)` if the prefix is a recognized operator,
  /// otherwise `null` (the caller should treat it as free-text).
  static (String, String)? _tryParseOperator(String token) {
    final colonIndex = token.indexOf(':');
    if (colonIndex <= 0) return null;

    final prefix = token.substring(0, colonIndex).toLowerCase();
    if (!_recognizedOperators.contains(prefix)) return null;

    final value = token.substring(colonIndex + 1);
    return (prefix, value);
  }
}
