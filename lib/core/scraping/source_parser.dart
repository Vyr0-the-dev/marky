import 'package:dio/dio.dart';
import 'package:marky/core/scraping/metadata_result.dart';

/// A parser that can extract [MetadataResult] from a URL.
///
/// Implementations are host-specific (YouTube, Reddit, etc.) or
/// generic (works for any HTML page). The [SourceParserRegistry]
/// selects the most appropriate parser for a given URL.
abstract interface class SourceParser {
  /// Returns `true` when this parser can handle [url].
  ///
  /// The registry calls [canHandle] on each registered parser in
  /// priority order and picks the first match.
  bool canHandle(String url);

  /// Fetches and parses metadata from [url].
  ///
  /// Implementations must handle their own HTTP requests and
  /// return an empty [MetadataResult] (not throw) on failure.
  /// The [html] parameter is provided when the page has already
  /// been fetched by the generic pipeline; platform-specific
  /// parsers may ignore it and use their own API calls.
  /// Supports optional [cancelToken] to abort in-flight requests.
  Future<MetadataResult> parse(
    String url, {
    String? html,
    CancelToken? cancelToken,
  });
}
