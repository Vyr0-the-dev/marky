import 'package:marky/core/scraping/models/parsed_metadata.dart';

/// Abstract contract for a domain-specific metadata parser.
///
/// Implementations are registered in [SourceParserRegistry] and matched
/// against URL host patterns. Each parser is responsible for turning a
/// raw URL into a structured [ParsedMetadata] instance.
///
/// Parsers must be pure Dart — no Flutter framework imports.
abstract class SourceParser {
  /// Attempts to extract [ParsedMetadata] from [url].
  ///
  /// Returns `null` when the parser cannot handle the URL or the source
  /// does not provide usable metadata.
  Future<ParsedMetadata?> parse(String url);

  /// The set of hostnames this parser claims.
  ///
  /// Registry matching is case-insensitive. Include both bare and www
  /// variants when applicable, e.g. `{'youtube.com', 'www.youtube.com'}`.
  Set<String> get hosts;
}
