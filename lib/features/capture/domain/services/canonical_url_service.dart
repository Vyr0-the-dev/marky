import 'package:marky/features/capture/domain/services/canonical_extractors/canonical_extraction_result.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/html_canonical_extractor.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/platform_canonical_extractor.dart';

/// Orchestrates canonical URL extraction by trying the fast, offline
/// [PlatformCanonicalExtractor] first and falling back to the network-based
/// [HtmlCanonicalExtractor] when no platform pattern matches.
///
/// Pure Dart — no Flutter dependencies. All failures are silent (return `null`).
class CanonicalUrlService {
  CanonicalUrlService({
    required this.platformExtractor,
    required this.htmlExtractor,
  });

  /// Shared singleton instance using the default extractors.
  static CanonicalUrlService? _instance;
  static CanonicalUrlService get instance {
    _instance ??= CanonicalUrlService(
      platformExtractor: PlatformCanonicalExtractor.instance,
      htmlExtractor: HtmlCanonicalExtractor.instance,
    );
    return _instance!;
  }

  final PlatformCanonicalExtractor platformExtractor;
  final HtmlCanonicalExtractor htmlExtractor;

  /// Attempts to extract a canonical URL and external content ID from [url].
  ///
  /// 1. Tries [platformExtractor] — fast, offline pattern matching.
  /// 2. If that returns `null`, falls back to [htmlExtractor] which fetches
  ///    the page and parses `<link rel="canonical">` / `<meta property="og:url">`.
  ///
  /// Returns the first non-null result, or `null` if both fail or the input
  /// is empty/null.
  Future<CanonicalExtractionResult?> extract(String? url) async {
    if (url == null || url.isEmpty) return null;

    final CanonicalExtractionResult? platformResult =
        platformExtractor.extract(url);
    if (platformResult != null) return platformResult;

    return htmlExtractor.extract(url);
  }
}
