/// Extracts valid HTTP(S) URLs from arbitrary text.
///
/// Share intents often deliver payloads like:
///   "Check this out! https://example.com/page - amazing article"
/// or multi-URL payloads from bulk share features.
///
/// Pure function — no I/O, no state.
class UrlExtractor {
  const UrlExtractor();

  /// Well-tested regex that captures most practical HTTP(S) URLs.
  ///
  /// Intentionally liberal on path/query chars to avoid false
  /// truncation on complex URLs (YouTube, Amazon, etc.).  Trailing
  /// punctuation is stripped post-match to avoid capturing sentence
  /// periods or commas.
  static final RegExp _urlPattern = RegExp(
    r'https?://[^\s<>\[\]"]+',
    caseSensitive: false,
  );

  /// Trailing characters that are almost always sentence punctuation,
  /// not part of the URL.
  static final RegExp _trailingJunk = RegExp(r'[.,;:!?>\]]+$');

  /// Returns all HTTP(S) URLs found in [text], in order of appearance.
  ///
  /// Empty list when no URLs are found. Never returns null.
  List<String> extractAll(String text) {
    if (text.trim().isEmpty) return const <String>[];

    final Iterable<RegExpMatch> matches = _urlPattern.allMatches(text);
    final List<String> urls = <String>[];

    for (final RegExpMatch match in matches) {
      String url = match.group(0)!;

      // Strip trailing punctuation that's more likely sentence-end than URL.
      url = url.replaceAll(_trailingJunk, '');

      // Balance parentheses — Wikipedia-style URLs contain parens.
      url = _balanceParentheses(url);

      if (url.isNotEmpty) {
        urls.add(url);
      }
    }

    return urls;
  }

  /// Convenience — returns the first URL or `null`.
  String? extractFirst(String text) {
    final List<String> urls = extractAll(text);
    return urls.isEmpty ? null : urls.first;
  }

  /// If the URL has unbalanced closing parens, trim them.
  /// Handles Wikipedia links like:
  ///   https://en.wikipedia.org/wiki/Dart_(programming_language)
  /// vs sentence context like:
  ///   (see https://example.com)
  String _balanceParentheses(String inputUrl) {
    String url = inputUrl;
    int open = 0;
    int close = 0;
    for (int i = 0; i < url.length; i++) {
      if (url[i] == '(') open++;
      if (url[i] == ')') close++;
    }

    // More closing parens than opening → trim the excess from the end.
    while (close > open && url.endsWith(')')) {
      url = url.substring(0, url.length - 1);
      close--;
    }

    return url;
  }
}
