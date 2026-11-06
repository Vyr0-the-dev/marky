import 'package:marky/core/scraping/source_parser.dart';

/// Picks the best [SourceParser] for a given URL.
///
/// Parsers are tried in registration order — register platform-
/// specific parsers before the generic fallback.
class SourceParserRegistry {
  SourceParserRegistry(this._parsers);

  final List<SourceParser> _parsers;

  /// Returns the first parser whose [canHandle] returns `true`,
  /// or `null` if no parser can handle [url].
  SourceParser? resolve(String url) {
    for (final SourceParser parser in _parsers) {
      if (parser.canHandle(url)) return parser;
    }
    return null;
  }
}
