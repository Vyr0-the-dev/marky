import 'package:dio/dio.dart';
import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/source_parser.dart';

/// Twitter / X metadata parser.
///
/// Twitter doesn't offer a public oEmbed or API without auth,
/// so this parser relies on OG tags from the pre-fetched HTML.
/// It primarily exists to:
/// 1. Claim the URL so the registry routes it here.
/// 2. Set the correct siteName.
/// 3. Delegate to OG tag extraction via the [html] parameter.
class TwitterParser implements SourceParser {
  const TwitterParser();

  static final RegExp _hostPattern = RegExp(
    r'(twitter\.com|x\.com|mobile\.twitter\.com)',
    caseSensitive: false,
  );

  @override
  bool canHandle(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return false;
    return _hostPattern.hasMatch(uri.host);
  }

  @override
  Future<MetadataResult> parse(
    String url, {
    String? html,
    CancelToken? cancelToken,
  }) async {
    // Twitter blocks most scraping; we return the siteName and let
    // the generic HTML parser fill OG fields from pre-fetched html.
    // The MetadataScraperService merges both results.
    return const MetadataResult(
      siteName: 'X (Twitter)',
      faviconUrl: 'https://abs.twimg.com/favicons/twitter.3.ico',
    );
  }
}
