import 'package:marky/core/scraping/parsers/source_parser.dart';

/// Routes URLs to the first registered [SourceParser] whose claimed hosts
/// match the URL's host.
///
/// Host matching is case-insensitive and `www.` prefix is normalized so
/// parsers only need to register the bare domain (e.g. `youtube.com`).
///
/// The registry is pure Dart and exposes a singleton [instance] for
/// convenience. Call [clear] between tests to reset state.
///
/// Usage:
/// ```dart
/// final parser = SourceParserRegistry.instance.resolve(url);
/// if (parser != null) {
///   final metadata = await parser.parse(url);
/// }
/// ```
class SourceParserRegistry {
  SourceParserRegistry._();

  /// Shared singleton instance.
  static final SourceParserRegistry instance = SourceParserRegistry._();

  final List<SourceParser> _parsers = <SourceParser>[];

  /// Registers a [parser] to be considered during [resolve].
  ///
  /// Parsers are evaluated in registration order; the first match wins.
  void register(SourceParser parser) => _parsers.add(parser);

  /// Removes all registered parsers.
  ///
  /// Intended for test isolation.
  void clear() => _parsers.clear();

  /// Returns the number of registered parsers.
  int get length => _parsers.length;

  /// Returns `true` if no parsers have been registered.
  bool get isEmpty => _parsers.isEmpty;

  /// Attempts to find a [SourceParser] whose [SourceParser.hosts] contain
  /// the host extracted from [url].
  ///
  /// Host entries may use a `*.` prefix to match any subdomain
  /// (e.g. `*.medium.com` matches `pub.medium.com`).
  ///
  /// Returns `null` when:
  /// - [url] is empty or cannot be parsed.
  /// - The parsed URI has no host.
  /// - No registered parser claims the normalized host.
  ///
  /// The caller is expected to fall back to a generic parser when this
  /// returns `null`.
  SourceParser? resolve(String url) {
    if (url.isEmpty) return null;

    final Uri? uri = Uri.tryParse(url.trim());
    if (uri == null) return null;

    final String host = _normalizeHost(uri.host);
    if (host.isEmpty) return null;

    for (final SourceParser parser in _parsers) {
      for (final String parserHost in parser.hosts) {
        if (_matchesHost(parserHost, host)) {
          return parser;
        }
      }
    }

    return null;
  }

  /// Checks whether [parserHost] matches [urlHost].
  ///
  /// Exact matches work after normalizing `www.`.  Wildcard entries
  /// beginning with `*.` match any subdomain of the suffix.
  static bool _matchesHost(String parserHost, String urlHost) {
    final String normalizedParser = _normalizeHost(parserHost);

    if (normalizedParser.startsWith('*.')) {
      final String suffix = normalizedParser.substring(2);
      return urlHost == suffix || urlHost.endsWith('.$suffix');
    }

    return normalizedParser == urlHost;
  }

  /// Normalizes a host for matching: lower-cased with `www.` stripped.
  static String _normalizeHost(String host) {
    String h = host.toLowerCase().trim();
    if (h.startsWith('www.')) {
      h = h.substring(4);
    }
    return h;
  }
}
