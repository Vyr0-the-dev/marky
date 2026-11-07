import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/source_parser.dart';

/// Fallback parser that works for any HTML page.
///
/// Extracts metadata from standard HTML elements:
/// - `<title>`
/// - `<meta name="description">`
/// - `<meta name="author">`
/// - `<link rel="canonical">`
/// - `<link rel="icon">` / `<link rel="shortcut icon">`
/// - Open Graph (`og:*`) and Twitter Card (`twitter:*`) tags
/// - `<html lang="...">`
///
/// This parser is **always** registered last in the
/// [SourceParserRegistry] as the universal fallback.
class GenericHtmlParser implements SourceParser {
  GenericHtmlParser({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: <String, dynamic>{
                'User-Agent':
                    'Mozilla/5.0 (compatible; MarkyBot/1.0; +https://marky.app)',
                'Accept': 'text/html,application/xhtml+xml',
              },
            ));

  final Dio _dio;

  @override
  bool canHandle(String url) => true; // universal fallback

  @override
  Future<MetadataResult> parse(
    String url, {
    String? html,
    CancelToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled ?? false) return const MetadataResult();
    final String? body = html ?? await _fetchHtml(url, cancelToken: cancelToken);
    if (body == null || (cancelToken?.isCancelled ?? false)) {
      return const MetadataResult();
    }

    return _extractInBackground(url, body);
  }

  /// Full-document HTML parsing is the most expensive step of a capture
  /// (hundreds of ms on large pages), so it never runs on the UI isolate.
  /// Static so the isolate closure captures only [url] and [body], not
  /// this parser and its [Dio] client.
  static Future<MetadataResult> _extractInBackground(String url, String body) {
    return Isolate.run(() => _extractMetadata(url, body));
  }

  static MetadataResult _extractMetadata(String url, String body) {
    final Document doc = html_parser.parse(body);
    final Uri baseUri = Uri.tryParse(url) ?? Uri();

    return MetadataResult(
      title: _extractTitle(doc),
      description: _extractDescription(doc),
      canonicalUrl: _extractCanonical(doc),
      author: _extractAuthor(doc),
      siteName: _extractOg(doc, 'og:site_name'),
      publisher: _extractMeta(doc, 'publisher'),
      publishDate: _extractPublishDate(doc),
      languageCode: _extractLanguage(doc),
      heroImageUrl: _resolveUrl(baseUri, _extractHeroImage(doc)),
      faviconUrl: _resolveUrl(baseUri, _extractFavicon(doc, baseUri)),
      snippet: _extractSnippet(doc),
    );
  }

  // ─── HTTP ──────────────────────────────────────────────────────

  Future<String?> _fetchHtml(String url, {CancelToken? cancelToken}) async {
    try {
      final Response<String> response = await _dio.get<String>(
        url,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (_) {
      return null;
    }
  }

  // ─── Extraction helpers ────────────────────────────────────────

  static String? _extractTitle(Document doc) {
    // Priority: og:title → twitter:title → <title>
    final String? title = _extractOg(doc, 'og:title') ??
        _extractMeta(doc, 'twitter:title') ??
        _extractMeta(doc, 'twitter:title', attribute: 'property') ??
        doc.querySelector('title')?.text.trim();
    return _cleanMetadataText(title);
  }

  static String? _extractDescription(Document doc) {
    final String? description = _extractOg(doc, 'og:description') ??
        _extractMeta(doc, 'twitter:description') ??
        _extractMeta(doc, 'description');
    return _cleanMetadataText(description);
  }

  static String? _extractCanonical(Document doc) {
    // <link rel="canonical" href="...">
    final Element? link = doc.querySelector('link[rel="canonical"]');
    final String? href = link?.attributes['href']?.trim();
    if (href != null && href.isNotEmpty) return href;

    // Fallback to og:url
    return _extractOg(doc, 'og:url');
  }

  static String? _extractAuthor(Document doc) {
    return _extractMeta(doc, 'author') ??
        _extractMeta(doc, 'article:author', attribute: 'property');
  }

  static DateTime? _extractPublishDate(Document doc) {
    final String? raw =
        _extractMeta(doc, 'article:published_time', attribute: 'property') ??
            _extractMeta(doc, 'date') ??
            _extractMeta(doc, 'pubdate');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static String? _extractLanguage(Document doc) {
    final String? lang = doc.querySelector('html')?.attributes['lang'];
    if (lang == null || lang.isEmpty) return null;
    // Normalise "en-US" → "en"
    return lang.split('-').first.toLowerCase();
  }

  static String? _extractHeroImage(Document doc) {
    return _extractOg(doc, 'og:image') ??
        _extractMeta(doc, 'twitter:image') ??
        _extractMeta(doc, 'twitter:image:src');
  }

  static String? _extractFavicon(Document doc, Uri baseUri) {
    // <link rel="icon" href="...">
    final Element? icon = doc.querySelector('link[rel="icon"]') ??
        doc.querySelector('link[rel="shortcut icon"]') ??
        doc.querySelector('link[rel="apple-touch-icon"]');
    final String? href = icon?.attributes['href']?.trim();
    if (href != null && href.isNotEmpty) return href;

    // Fallback: /favicon.ico
    return '${baseUri.scheme}://${baseUri.host}/favicon.ico';
  }

  static String? _extractSnippet(Document doc) {
    // Try the first <p> with meaningful text.
    for (final Element p in doc.querySelectorAll('article p, main p, p')) {
      final String text = p.text.trim();
      if (text.length > 40) {
        return text.length > 300 ? '${text.substring(0, 300)}…' : text;
      }
    }
    return null;
  }

  // ─── Meta tag helpers ──────────────────────────────────────────

  /// Extracts content from `<meta property="[property]" content="...">`.
  static String? _extractOg(Document doc, String property) {
    final Element? meta = doc.querySelector('meta[property="$property"]');
    final String? content = meta?.attributes['content']?.trim();
    return (content != null && content.isNotEmpty) ? content : null;
  }

  /// Extracts content from `<meta [attribute]="[name]" content="...">`.
  static String? _extractMeta(
    Document doc,
    String name, {
    String attribute = 'name',
  }) {
    final Element? meta = doc.querySelector('meta[$attribute="$name"]');
    final String? content = meta?.attributes['content']?.trim();
    return (content != null && content.isNotEmpty) ? content : null;
  }

  /// Resolves a potentially relative URL against [baseUri].
  static String? _resolveUrl(Uri baseUri, String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return null;
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }
    try {
      return baseUri.resolve(rawUrl).toString();
    } catch (_) {
      return rawUrl;
    }
  }

  static String? _cleanMetadataText(String? value) {
    final String? trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final String normalized = trimmed.toLowerCase();
    final List<String> blocked = <String>[
      'please wait for verification',
      'just a moment',
      'attention required',
      'checking your browser',
      'verify you are human',
      'are you a robot',
      'cloudflare',
    ];
    if (blocked.any(normalized.contains)) return null;
    return trimmed;
  }
}
