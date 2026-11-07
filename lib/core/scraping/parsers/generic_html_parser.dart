import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/source_parser.dart';

/// Industrial-grade multi-tier HTML metadata parser.
///
/// Extraction tiers (executed inside a background [Isolate.run]):
/// 1. **Tier 1 — JSON-LD & Schema.org**: `NewsArticle`, `Article`,
///    `BlogPosting`, `WebPage`, `VideoObject`, and `@graph` nodes.
/// 2. **Tier 2 — OpenGraph, Twitter Cards & Meta**: `og:*`, `twitter:*`,
///    `article:*`, `<link rel="canonical">`.
/// 3. **Tier 3 — DOM Readability & Heuristic Scoring**: Strips noise
///    containers (`<nav>`, `<footer>`, `<script>`, ads/banners), scores
///    candidate article blocks by paragraph density & punctuation,
///    computes `readingTimeMinutes`, and extracts content images.
/// 4. **Tier 4 — Public oEmbed & URL Slug Fallback**: When a target
///    returns HTTP `403`/`503` or blocks scraping, probes public oEmbed
///    endpoints and synthesizes humanized slug metadata.
class GenericHtmlParser implements SourceParser {
  GenericHtmlParser({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                followRedirects: true,
                maxRedirects: 5,
                headers: browserNavigationHeaders(),
              ),
            );

  final Dio _dio;
  static int _uaCursor = 0;

  /// Realistic stable browser User-Agent strings rotated across requests.
  static const List<String> kBrowserUserAgents = <String>[
    'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.6478.122 Mobile Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.15',
    'Mozilla/5.0 (X11; Linux x86_64; rv:127.0) Gecko/20100101 Firefox/127.0',
  ];

  /// Standard browser navigation headers to minimize false bot blocks.
  static Map<String, String> browserNavigationHeaders({
    int? seed,
    String? url,
  }) {
    final int index = (seed ?? (_uaCursor++)) % kBrowserUserAgents.length;
    final Uri? parsedUri = url != null ? Uri.tryParse(url) : null;
    final String? referer = parsedUri != null &&
            parsedUri.hasScheme &&
            parsedUri.host.isNotEmpty
        ? '${parsedUri.scheme}://${parsedUri.host}/'
        : null;
    return <String, String>{
      'User-Agent': kBrowserUserAgents[index],
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9,tr;q=0.8',
      'Sec-Fetch-Dest': 'document',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'none',
      'Upgrade-Insecure-Requests': '1',
      if (referer != null) 'Referer': referer,
    };
  }

  @override
  bool canHandle(String url) => true;

  @override
  Future<MetadataResult> parse(
    String url, {
    String? html,
    CancelToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled ?? false) return const MetadataResult();

    if (html != null) {
      if (html.trim().isEmpty) return const MetadataResult();
      return _extractStringInBackground(url, html);
    }

    final _FetchResponse fetched = await _fetchHtmlResponse(
      url,
      cancelToken: cancelToken,
    );
    if (cancelToken?.isCancelled ?? false) return const MetadataResult();

    if (fetched.bytes != null && fetched.bytes!.isNotEmpty) {
      final MetadataResult extracted = await _extractBytesInBackground(
        fetched.effectiveUrl,
        fetched.bytes!,
        fetched.contentTypeHeader,
      );
      if (_hasMeaningfulContent(extracted)) {
        return extracted;
      }
      if (fetched.statusCode == 403 || fetched.statusCode == 503) {
        final MetadataResult oembed = await _tryOEmbed(
          fetched.effectiveUrl,
          cancelToken: cancelToken,
        );
        final MetadataResult fallback =
            synthesizeFallbackMetadata(fetched.effectiveUrl);
        return oembed.mergeWith(fallback).mergeWith(extracted);
      }
      return extracted;
    }

    if (fetched.body != null && fetched.body!.trim().isNotEmpty) {
      final MetadataResult extracted = await _extractStringInBackground(
        fetched.effectiveUrl,
        fetched.body!,
      );
      if (_hasMeaningfulContent(extracted)) {
        return extracted;
      }
      if (fetched.statusCode == 403 || fetched.statusCode == 503) {
        final MetadataResult oembed = await _tryOEmbed(
          fetched.effectiveUrl,
          cancelToken: cancelToken,
        );
        final MetadataResult fallback =
            synthesizeFallbackMetadata(fetched.effectiveUrl);
        return oembed.mergeWith(fallback).mergeWith(extracted);
      }
      return extracted;
    }

    if (fetched.statusCode == 403 || fetched.statusCode == 503) {
      final MetadataResult oembed = await _tryOEmbed(
        fetched.effectiveUrl,
        cancelToken: cancelToken,
      );
      final MetadataResult fallback =
          synthesizeFallbackMetadata(fetched.effectiveUrl);
      return oembed.mergeWith(fallback);
    }

    return const MetadataResult();
  }

  /// Parses raw HTML bytes in a background isolate with automatic
  /// charset detection (UTF-8, ISO-8859-9 / Windows-1254 Turkish, Latin-1).
  Future<MetadataResult> parseBytes(
    String url,
    List<int> bytes, {
    String? contentTypeHeader,
  }) {
    if (bytes.isEmpty) return Future<MetadataResult>.value(const MetadataResult());
    return _extractBytesInBackground(url, bytes, contentTypeHeader);
  }

  static bool _hasMeaningfulContent(MetadataResult result) =>
      result.title != null ||
      result.description != null ||
      result.heroImageUrl != null;

  static const int _maxHtmlLength = 350000;

  static Future<MetadataResult> _extractStringInBackground(
    String url,
    String body,
  ) {
    final String cappedBody =
        body.length > _maxHtmlLength ? body.substring(0, _maxHtmlLength) : body;
    return Isolate.run(() => _extractMetadata(url, cappedBody));
  }

  static Future<MetadataResult> _extractBytesInBackground(
    String url,
    List<int> bytes,
    String? contentTypeHeader,
  ) {
    final List<int> cappedBytes = bytes.length > _maxHtmlLength
        ? bytes.sublist(0, _maxHtmlLength)
        : bytes;
    return Isolate.run(() {
      final String decoded = decodeHtmlBytes(
        cappedBytes,
        contentTypeHeader: contentTypeHeader,
      );
      return _extractMetadata(url, decoded);
    });
  }

  // ─── Charset Decoding (UTF-8 / ISO-8859-9 / Windows-1254 / Latin-1) ───

  /// Decodes raw HTML [bytes] into a [String], inspecting the HTTP
  /// [contentTypeHeader] and `<meta charset>` / `<meta http-equiv="Content-Type">`
  /// declarations. Supports UTF-8, Turkish ISO-8859-9 / Windows-1254, and Latin-1.
  static String decodeHtmlBytes(
    List<int> bytes, {
    String? contentTypeHeader,
  }) {
    if (bytes.isEmpty) return '';

    final String? declaredCharset =
        _extractCharsetFromHeader(contentTypeHeader) ??
            _sniffMetaCharset(bytes);

    if (declaredCharset != null) {
      final String norm = declaredCharset.toLowerCase().replaceAll('_', '-');
      if (norm.contains('1254') ||
          norm.contains('8859-9') ||
          norm.contains('latin5') ||
          norm == 'turkish') {
        return _decodeWindows1254(bytes);
      }
      if (norm.contains('8859-1') || norm == 'latin1' || norm == 'ascii') {
        return latin1.decode(bytes, allowInvalid: true);
      }
      if (norm.contains('utf-8') || norm == 'utf8') {
        return utf8.decode(bytes, allowMalformed: true);
      }
    }

    // Try strict UTF-8 first; if invalid byte sequences exist, fall back to
    // Windows-1254 / ISO-8859-9 (which preserves Turkish glyphs and Latin-1).
    try {
      return utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      return _decodeWindows1254(bytes);
    }
  }

  static String? _extractCharsetFromHeader(String? header) {
    if (header == null || header.isEmpty) return null;
    final RegExpMatch? match = RegExp(
      r'charset\s*=\s*["\x27]?([a-zA-Z0-9._\-]+)',
      caseSensitive: false,
    ).firstMatch(header);
    return match?.group(1)?.trim();
  }

  static String? _sniffMetaCharset(List<int> bytes) {
    final int headLen = bytes.length < 4096 ? bytes.length : 4096;
    final String asciiHead = latin1.decode(
      bytes.sublist(0, headLen),
      allowInvalid: true,
    );
    final RegExpMatch? directMatch = RegExp(
      r'<meta[^>]+charset\s*=\s*["\x27]?\s*([a-zA-Z0-9._\-]+)',
      caseSensitive: false,
    ).firstMatch(asciiHead);
    return directMatch?.group(1)?.trim();
  }

  /// Decodes ISO-8859-9 / Windows-1254 bytes into Unicode code units.
  ///
  /// Maps Turkish-specific code points (`Ğ, İ, Ş, ğ, ı, ş`) and
  /// Windows-1254 `0x80..0x9F` punctuation cleanly.
  static String _decodeWindows1254(List<int> bytes) {
    final Uint16List codeUnits = Uint16List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      final int b = bytes[i] & 0xFF;
      codeUnits[i] = switch (b) {
        0xD0 => 0x011E, // Ğ
        0xDD => 0x0130, // İ
        0xDE => 0x015E, // Ş
        0xF0 => 0x011F, // ğ
        0xFD => 0x0131, // ı
        0xFE => 0x015F, // ş
        0x80 => 0x20AC, // €
        0x85 => 0x2026, // …
        0x91 => 0x2018, // ‘
        0x92 => 0x2019, // ’
        0x93 => 0x201C, // “
        0x94 => 0x201D, // ”
        0x95 => 0x2022, // •
        0x96 => 0x2013, // –
        0x97 => 0x2014, // —
        _ => b,
      };
    }
    return String.fromCharCodes(codeUnits);
  }

  // ─── Multi-Tier Extraction Pipeline (Isolate-safe) ─────────────

  static MetadataResult _extractMetadata(String url, String body) {
    final Document doc = html_parser.parse(body);
    final Uri baseUri = Uri.tryParse(url) ?? Uri();

    // Tier 1: JSON-LD & Schema.org structured data
    final _JsonLdData jsonLd = _extractJsonLdMetadata(doc);

    // Tier 3: DOM Readability & Heuristic Scoring
    final _ReadabilityData readability = _extractReadability(
      doc,
      jsonLdWordCount: jsonLd.wordCount,
      jsonLdBody: jsonLd.articleBody,
    );

    // Tier 2 + Tier 1 + Tier 3 merged field resolution
    final String? title = _extractTitle(doc, jsonLd);
    final String? description = _extractDescription(doc, jsonLd, readability);
    final String? canonicalRaw = _extractCanonical(doc, jsonLd);
    final String? canonicalUrl = _resolveUrl(baseUri, canonicalRaw);
    final String? author = _extractAuthor(doc, jsonLd);
    final String? siteName = _extractSiteName(doc, jsonLd);
    final String? publisher = _extractPublisher(doc, jsonLd);
    final DateTime? publishDate = _extractPublishDate(doc, jsonLd);
    final String? languageCode = _extractLanguage(doc, jsonLd);
    final String? heroImageUrl = _resolveUrl(
      baseUri,
      _extractHeroImage(doc, jsonLd, readability),
    );
    final String? faviconUrl = _resolveUrl(
      baseUri,
      _extractFavicon(doc, baseUri),
    );

    return MetadataResult(
      title: title,
      description: description,
      canonicalUrl: canonicalUrl,
      author: author,
      siteName: siteName,
      publisher: publisher,
      publishDate: publishDate,
      languageCode: languageCode,
      heroImageUrl: heroImageUrl,
      faviconUrl: faviconUrl,
      readingTimeMinutes: readability.readingTimeMinutes,
      snippet: readability.snippet,
    );
  }

  // ─── HTTP & Redirect Handling ──────────────────────────────────

  Future<_FetchResponse> _fetchHtmlResponse(
    String url, {
    CancelToken? cancelToken,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
          headers: browserNavigationHeaders(),
          validateStatus: (int? status) =>
              status != null && status >= 200 && status < 600,
        ),
      );
      final String effectiveUrl = _resolveRedirectUrl(url, response.realUri);
      final String? contentType =
          response.headers.value(Headers.contentTypeHeader);
      final Object? data = response.data;
      if (data is List<int>) {
        return _FetchResponse(
          effectiveUrl: effectiveUrl,
          statusCode: response.statusCode,
          bytes: data,
          contentTypeHeader: contentType,
        );
      }
      if (data is String) {
        return _FetchResponse(
          effectiveUrl: effectiveUrl,
          statusCode: response.statusCode,
          body: data,
          contentTypeHeader: contentType,
        );
      }
      return _FetchResponse(
        effectiveUrl: effectiveUrl,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final int? statusCode = e.response?.statusCode;
      final String effectiveUrl =
          _resolveRedirectUrl(url, e.response?.realUri);
      return _FetchResponse(
        effectiveUrl: effectiveUrl,
        statusCode: statusCode,
      );
    } catch (_) {
      return _FetchResponse(effectiveUrl: url);
    }
  }

  static String _resolveRedirectUrl(String originalUrl, Uri? realUri) {
    if (realUri == null) return originalUrl;
    if (realUri.hasScheme && realUri.host.isNotEmpty) {
      return realUri.toString();
    }
    final Uri? base = Uri.tryParse(originalUrl);
    if (base == null) return originalUrl;
    return base.resolveUri(realUri).toString();
  }

  // ─── Tier 4: Public oEmbed & URL Slug Fallback ─────────────────

  Future<MetadataResult> _tryOEmbed(
    String url, {
    CancelToken? cancelToken,
  }) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return const MetadataResult();
    final String host = uri.host.toLowerCase();
    final String encodedUrl = Uri.encodeComponent(url);

    String? endpoint;
    if (host.contains('substack.com')) {
      endpoint = '${uri.scheme}://${uri.host}/api/v1/oembed?url=$encodedUrl';
    } else if (host.contains('medium.com')) {
      endpoint = 'https://medium.com/oembed?url=$encodedUrl&format=json';
    } else if (host.contains('wordpress.com')) {
      endpoint =
          'https://public-api.wordpress.com/oembed/?url=$encodedUrl&format=json';
    }

    if (endpoint == null) return const MetadataResult();

    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        endpoint,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.json,
          headers: <String, String>{
            'User-Agent': kBrowserUserAgents.first,
            'Accept': 'application/json',
          },
        ),
      );
      final Object? raw = response.data;
      final Map<String, dynamic>? map = switch (raw) {
        final Map<String, dynamic> m => m,
        final String s => jsonDecode(s) as Map<String, dynamic>?,
        _ => null,
      };
      if (map == null) return const MetadataResult();
      return MetadataResult(
        title: _cleanMetadataText(map['title'] as String?),
        author: _cleanMetadataText(map['author_name'] as String?),
        siteName: _cleanMetadataText(map['provider_name'] as String?),
        heroImageUrl: (map['thumbnail_url'] as String?)?.trim(),
      );
    } catch (_) {
      return const MetadataResult();
    }
  }

  /// Synthesizes clean fallback metadata from the URL path slug and domain
  /// when a site blocks scraping (`403`/`503`) or is unreachable.
  static MetadataResult synthesizeFallbackMetadata(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return const MetadataResult();

    final String? slugTitle = humanizeUrlSlug(uri);
    final String siteName = _humanizeHost(uri.host);
    final String faviconUrl = '${uri.scheme}://${uri.host}/favicon.ico';

    return MetadataResult(
      title: slugTitle,
      siteName: siteName,
      faviconUrl: faviconUrl,
    );
  }

  /// Extracts a human-readable title from a URL path slug
  /// (e.g. `/2026/05/my-article-title-slug` -> `'My Article Title Slug'`).
  static String? humanizeUrlSlug(Uri uri) {
    final List<String> segments = uri.pathSegments
        .map((String s) => Uri.decodeComponent(s).trim())
        .where((String s) => s.isNotEmpty && !s.startsWith('@'))
        .toList();
    if (segments.isEmpty) return null;

    // Pick the last non-numeric segment
    String? candidate;
    for (int i = segments.length - 1; i >= 0; i--) {
      final String seg = segments[i];
      if (RegExp(r'^\d+$').hasMatch(seg)) continue;
      if (const <String>{'p', 's', 'articles', 'posts', 'news', 'story'}
          .contains(seg.toLowerCase())) {
        continue;
      }
      candidate = seg;
      break;
    }
    if (candidate == null || candidate.isEmpty) return null;

    // Strip common file extensions
    candidate = candidate.replaceAll(
      RegExp(r'\.(html?|php|aspx?|jsp|md)$', caseSensitive: false),
      '',
    );

    // Strip trailing Medium/Substack/CMS hex hash suffix (e.g. -a1b2c3d4e5f6)
    candidate = candidate.replaceAll(
      RegExp(r'-[0-9a-f]{8,16}$', caseSensitive: false),
      '',
    );

    final List<String> words = candidate
        .split(RegExp(r'[\-_+\s]+'))
        .map((String w) => w.trim())
        .where((String w) => w.isNotEmpty)
        .toList();

    if (words.isEmpty) return null;
    // Require either multiple words or a meaningful slug
    if (words.length == 1 && words.first.length < 4) return null;

    const Set<String> lowercaseParticles = <String>{
      'a',
      'an',
      'and',
      'as',
      'at',
      'by',
      'for',
      'from',
      'in',
      'of',
      'on',
      'or',
      'the',
      'to',
      'vs',
      'with',
    };

    final List<String> formatted = <String>[];
    for (int i = 0; i < words.length; i++) {
      final String word = words[i];
      final String lower = word.toLowerCase();
      if (i > 0 && i < words.length - 1 && lowercaseParticles.contains(lower)) {
        formatted.add(lower);
      } else {
        formatted.add(
          word[0].toUpperCase() +
              (word.length > 1 ? word.substring(1).toLowerCase() : ''),
        );
      }
    }
    return formatted.join(' ');
  }

  static String _humanizeHost(String host) {
    final String cleaned =
        host.toLowerCase().replaceFirst(RegExp(r'^(www|m|mobile)\.'), '');
    final List<String> parts = cleaned.split('.');
    if (parts.isEmpty) return host;
    if (cleaned.endsWith('substack.com')) return 'Substack';
    if (cleaned == 'medium.com' || cleaned.endsWith('.medium.com')) {
      return 'Medium';
    }
    final String name = parts.first;
    if (name.isEmpty) return cleaned;
    return name[0].toUpperCase() + name.substring(1);
  }

  // ─── Tier 1: JSON-LD Extraction ────────────────────────────────

  static _JsonLdData _extractJsonLdMetadata(Document doc) {
    String? title;
    String? description;
    String? articleBody;
    String? author;
    String? publisher;
    DateTime? publishDate;
    String? image;
    String? canonicalUrl;
    String? language;
    int? wordCount;

    final List<Element> scripts =
        doc.querySelectorAll('script[type="application/ld+json"]');

    void inspectNode(Object? node) {
      if (node is List) {
        for (final Object? item in node) {
          inspectNode(item);
        }
        return;
      }
      if (node is! Map) return;

      title ??= _cleanMetadataText(
        _asString(node['headline']) ?? _asString(node['name']),
      );
      description ??= _cleanMetadataText(_asString(node['description']));
      articleBody ??= _cleanMetadataText(_asString(node['articleBody']));
      author ??= _cleanMetadataText(_extractJsonLdAuthor(node['author']));
      publisher ??= _cleanMetadataText(
        _extractJsonLdPublisher(node['publisher']),
      );
      publishDate ??= _parseJsonLdDate(
        node['datePublished'] ?? node['dateCreated'] ?? node['uploadDate'],
      );
      image ??= _extractImageValue(node['image'] ?? node['thumbnailUrl']);
      canonicalUrl ??= _asString(node['mainEntityOfPage']) ??
          (node['mainEntityOfPage'] is Map
              ? _asString((node['mainEntityOfPage'] as Map)['@id'] ??
                  (node['mainEntityOfPage'] as Map)['url'])
              : null);
      language ??= _asString(node['inLanguage']);
      wordCount ??= _parseJsonLdInt(node['wordCount']);

      final Object? graph = node['@graph'];
      if (graph is List) {
        for (final Object? item in graph) {
          inspectNode(item);
        }
      }
    }

    for (final Element script in scripts) {
      final String raw = script.text.trim();
      if (raw.isEmpty) continue;
      try {
        final Object? decoded = jsonDecode(raw);
        inspectNode(decoded);
      } catch (_) {
        continue;
      }
    }

    return _JsonLdData(
      title: title,
      description: description,
      articleBody: articleBody,
      author: author,
      publisher: publisher,
      publishDate: publishDate,
      image: image,
      canonicalUrl: canonicalUrl,
      language: language,
      wordCount: wordCount,
    );
  }

  static String? _asString(Object? value) {
    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    }
    return null;
  }

  static String? _extractJsonLdAuthor(Object? authorNode) {
    if (authorNode is String) {
      final String trimmed = authorNode.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    }
    if (authorNode is Map) {
      return _asString(authorNode['name']);
    }
    if (authorNode is List) {
      final List<String> names = authorNode
          .map(_extractJsonLdAuthor)
          .whereType<String>()
          .where((String s) => s.isNotEmpty)
          .toList();
      if (names.isNotEmpty) return names.join(', ');
    }
    return null;
  }

  static String? _extractJsonLdPublisher(Object? publisherNode) {
    if (publisherNode is String) return _asString(publisherNode);
    if (publisherNode is Map) return _asString(publisherNode['name']);
    return null;
  }

  static DateTime? _parseJsonLdDate(Object? raw) {
    final String? str = _asString(raw);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  static int? _parseJsonLdInt(Object? raw) {
    if (raw is int && raw > 0) return raw;
    if (raw is String) {
      final int? parsed = int.tryParse(raw.trim());
      if (parsed != null && parsed > 0) return parsed;
    }
    return null;
  }

  static String? _extractImageValue(Object? value) {
    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    }
    if (value is Map) {
      final Object? url = value['url'] ?? value['contentUrl'];
      if (url is String && url.trim().isNotEmpty) {
        return url.trim();
      }
    }
    if (value is List) {
      for (final Object? item in value) {
        final String? nested = _extractImageValue(item);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  // ─── Tier 3: DOM Readability & Heuristic Scoring ───────────────

  static final RegExp _noiseTokensPattern = RegExp(
    r'(cookie|banner|popup|modal|sidebar|footer|header|navbar|nav-|menu|breadcrumb|social|share|comment|promo|advert|sponsor|newsletter|related|outbrain|taboola)',
    caseSensitive: false,
  );

  static final RegExp _positiveTokensPattern = RegExp(
    r'(article|content|post|entry|story|main|body|text|prose|read)',
    caseSensitive: false,
  );

  static _ReadabilityData _extractReadability(
    Document doc, {
    int? jsonLdWordCount,
    String? jsonLdBody,
  }) {
    final Element? bodyClone = doc.body?.clone(true);
    if (bodyClone == null) {
      return const _ReadabilityData();
    }

    // 1. Strip non-content and layout boilerplate tags
    for (final Element el in bodyClone.querySelectorAll(
      'script, style, noscript, iframe, svg, nav, footer, header, aside, form, button, dialog',
    )) {
      el.remove();
    }

    // 2. Strip elements with noise class/id attributes (unless they wrap <article>/<main>)
    final List<Element> allElements = bodyClone.querySelectorAll('*').toList();
    for (final Element el in allElements) {
      final String tag = el.localName?.toLowerCase() ?? '';
      if (tag == 'article' || tag == 'main' || tag == 'body') continue;
      final String classAndId =
          '${el.attributes['class'] ?? ''} ${el.attributes['id'] ?? ''}';
      if (classAndId.trim().isEmpty) continue;
      if (_noiseTokensPattern.hasMatch(classAndId) &&
          !_positiveTokensPattern.hasMatch(classAndId)) {
        if (el.querySelector('article, main') == null) {
          el.remove();
        }
      }
    }

    // 3. Score candidate containers by paragraph text length and punctuation density
    final Map<Element, double> scores = <Element, double>{};
    final List<Element> paragraphs = bodyClone.querySelectorAll('p');

    for (final Element p in paragraphs) {
      final String text = _collapseWhitespace(p.text);
      if (text.length < 25) continue;

      final Element? parent = p.parent;
      if (parent == null) continue;

      final int punctuationCount =
          RegExp(r'[,.;:!?]').allMatches(text).length;
      final double paragraphScore =
          10.0 + (text.length / 40.0).clamp(0.0, 20.0) + punctuationCount * 1.5;

      scores[parent] = (scores[parent] ?? _containerBonus(parent)) +
          paragraphScore;

      final Element? grandParent = parent.parent;
      if (grandParent != null && grandParent != bodyClone) {
        scores[grandParent] =
            (scores[grandParent] ?? _containerBonus(grandParent)) +
                (paragraphScore * 0.5);
      }
    }

    Element? bestContainer;
    double bestScore = -1;
    scores.forEach((Element container, double score) {
      if (score > bestScore) {
        bestScore = score;
        bestContainer = container;
      }
    });

    final Element rootForExtraction = bestContainer ??
        bodyClone.querySelector('article, main, [role="main"]') ??
        bodyClone;

    // 4. Extract snippet from the winning container (or fallback to stripped body)
    String? snippet;
    for (final Element p in <Element>[
      ...rootForExtraction.querySelectorAll('p'),
      ...bodyClone.querySelectorAll('p'),
    ]) {
      final String text = _collapseWhitespace(p.text);
      if (text.length > 40) {
        snippet = text.length > 300 ? '${text.substring(0, 300)}…' : text;
        break;
      }
    }
    if (snippet == null && jsonLdBody != null && jsonLdBody.length > 40) {
      final String cleanBody = _collapseWhitespace(jsonLdBody);
      snippet =
          cleanBody.length > 300 ? '${cleanBody.substring(0, 300)}…' : cleanBody;
    }

    // 5. Compute word count and readingTimeMinutes
    final String articleText = _collapseWhitespace(rootForExtraction.text);
    final int domWords = articleText.isEmpty
        ? 0
        : articleText.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length;
    final int jsonWords = jsonLdWordCount ??
        (jsonLdBody != null && jsonLdBody.isNotEmpty
            ? jsonLdBody.split(RegExp(r'\s+')).length
            : 0);
    final int totalWords = domWords >= jsonWords ? domWords : jsonWords;
    final int? readingTimeMinutes = totalWords >= 60
        ? (totalWords / 200.0).ceil().clamp(1, 120)
        : null;

    // 6. Extract first valid content image from cleaned root
    final String? contentImage =
        _extractFirstContentImageFromElement(rootForExtraction) ??
            _extractFirstContentImageFromElement(bodyClone);

    return _ReadabilityData(
      snippet: snippet,
      readingTimeMinutes: readingTimeMinutes,
      contentImageUrl: contentImage,
    );
  }

  static double _containerBonus(Element element) {
    double bonus = 0;
    final String tag = element.localName?.toLowerCase() ?? '';
    if (tag == 'article' || tag == 'main') bonus += 50;
    if (element.attributes['role'] == 'main') bonus += 40;
    final String classAndId =
        '${element.attributes['class'] ?? ''} ${element.attributes['id'] ?? ''}';
    if (_positiveTokensPattern.hasMatch(classAndId)) bonus += 25;
    if (_noiseTokensPattern.hasMatch(classAndId)) bonus -= 40;
    return bonus;
  }

  static String _collapseWhitespace(String input) =>
      input.replaceAll(RegExp(r'\s+'), ' ').trim();

  static String? _extractFirstContentImageFromElement(Element root) {
    final List<Element> images = <Element>[
      ...root.querySelectorAll('figure img'),
      ...root.querySelectorAll('img'),
    ];
    for (final Element img in images) {
      final String? src = (img.attributes['src'] ??
              img.attributes['data-src'] ??
              img.attributes['data-lazy-src'] ??
              _firstSrcFromSrcset(img.attributes['srcset']))
          ?.trim();
      if (src == null || src.isEmpty || src.startsWith('data:')) continue;
      final int? width = int.tryParse(img.attributes['width'] ?? '');
      final int? height = int.tryParse(img.attributes['height'] ?? '');
      if ((width != null && width < 64) || (height != null && height < 64)) {
        continue;
      }
      final String lower = src.toLowerCase();
      if (lower.contains('avatar') ||
          lower.contains('icon') ||
          lower.contains('logo') ||
          lower.contains('pixel') ||
          lower.contains('spacer') ||
          lower.contains('1x1') ||
          lower.endsWith('.svg')) {
        continue;
      }
      return src;
    }
    return null;
  }

  static String? _firstSrcFromSrcset(String? srcset) {
    if (srcset == null || srcset.trim().isEmpty) return null;
    final String firstCandidate = srcset.split(',').first.trim();
    if (firstCandidate.isEmpty) return null;
    return firstCandidate.split(RegExp(r'\s+')).first.trim();
  }

  // ─── Field Resolution Helpers ──────────────────────────────────

  static String? _extractTitle(Document doc, _JsonLdData jsonLd) {
    final String? title = _extractOg(doc, 'og:title') ??
        jsonLd.title ??
        _extractMeta(doc, 'twitter:title') ??
        _extractMeta(doc, 'twitter:title', attribute: 'property') ??
        doc.querySelector('title')?.text.trim() ??
        doc.querySelector('article h1, main h1, h1')?.text.trim();
    return _cleanMetadataText(title);
  }

  static String? _extractDescription(
    Document doc,
    _JsonLdData jsonLd,
    _ReadabilityData readability,
  ) {
    final String? description = _extractOg(doc, 'og:description') ??
        jsonLd.description ??
        _extractMeta(doc, 'twitter:description') ??
        _extractMeta(doc, 'twitter:description', attribute: 'property') ??
        _extractMeta(doc, 'description');
    return _cleanMetadataText(description);
  }

  static String? _extractCanonical(Document doc, _JsonLdData jsonLd) {
    final Element? link = doc.querySelector('link[rel="canonical"]');
    final String? href = link?.attributes['href']?.trim();
    if (href != null && href.isNotEmpty) return href;

    return _extractOg(doc, 'og:url') ?? jsonLd.canonicalUrl;
  }

  static String? _extractAuthor(Document doc, _JsonLdData jsonLd) {
    return _cleanMetadataText(
      _extractMeta(doc, 'author') ??
          _extractMeta(doc, 'article:author', attribute: 'property') ??
          _extractMeta(doc, 'byl') ??
          jsonLd.author,
    );
  }

  static String? _extractSiteName(Document doc, _JsonLdData jsonLd) {
    return _cleanMetadataText(
      _extractOg(doc, 'og:site_name') ??
          jsonLd.publisher ??
          _extractMeta(doc, 'application-name'),
    );
  }

  static String? _extractPublisher(Document doc, _JsonLdData jsonLd) {
    return _cleanMetadataText(
      _extractMeta(doc, 'publisher') ??
          _extractMeta(doc, 'article:publisher', attribute: 'property') ??
          jsonLd.publisher,
    );
  }

  static DateTime? _extractPublishDate(Document doc, _JsonLdData jsonLd) {
    final String? raw =
        _extractMeta(doc, 'article:published_time', attribute: 'property') ??
            _extractMeta(doc, 'og:published_time', attribute: 'property') ??
            _extractMeta(doc, 'date') ??
            _extractMeta(doc, 'pubdate') ??
            doc.querySelector('time[datetime]')?.attributes['datetime']?.trim();
    if (raw != null) {
      final DateTime? parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return jsonLd.publishDate;
  }

  static String? _extractLanguage(Document doc, _JsonLdData jsonLd) {
    final String? lang =
        doc.querySelector('html')?.attributes['lang'] ?? jsonLd.language;
    if (lang == null || lang.isEmpty) return null;
    return lang.split(RegExp(r'[-_]')).first.toLowerCase();
  }

  static String? _extractHeroImage(
    Document doc,
    _JsonLdData jsonLd,
    _ReadabilityData readability,
  ) {
    return _extractOg(doc, 'og:image') ??
        _extractOg(doc, 'og:image:url') ??
        _extractOg(doc, 'og:image:secure_url') ??
        _extractMeta(doc, 'twitter:image') ??
        _extractMeta(doc, 'twitter:image', attribute: 'property') ??
        _extractMeta(doc, 'twitter:image:src') ??
        _extractMeta(doc, 'twitter:image:src', attribute: 'property') ??
        _extractMeta(doc, 'image', attribute: 'itemprop') ??
        _extractMeta(doc, 'thumbnail') ??
        _extractMeta(doc, 'thumbnail', attribute: 'property') ??
        _extractLinkRel(doc, 'image_src') ??
        jsonLd.image ??
        readability.contentImageUrl ??
        _extractLinkRel(doc, 'apple-touch-icon') ??
        _extractLinkRel(doc, 'apple-touch-icon-precomposed');
  }

  static String? _extractLinkRel(Document doc, String rel) {
    final Element? link = doc.querySelector('link[rel="$rel"]');
    final String? href = link?.attributes['href']?.trim();
    return (href != null && href.isNotEmpty) ? href : null;
  }

  static String? _extractFavicon(Document doc, Uri baseUri) {
    final Element? icon = doc.querySelector('link[rel="icon"]') ??
        doc.querySelector('link[rel="shortcut icon"]') ??
        doc.querySelector('link[rel="apple-touch-icon"]');
    final String? href = icon?.attributes['href']?.trim();
    if (href != null && href.isNotEmpty) return href;

    if (baseUri.scheme.isNotEmpty && baseUri.host.isNotEmpty) {
      return '${baseUri.scheme}://${baseUri.host}/favicon.ico';
    }
    return null;
  }

  // ─── Meta tag helpers ──────────────────────────────────────────

  static String? _extractOg(Document doc, String property) {
    final Element? meta = doc.querySelector('meta[property="$property"]');
    final String? content = meta?.attributes['content']?.trim();
    return (content != null && content.isNotEmpty) ? content : null;
  }

  static String? _extractMeta(
    Document doc,
    String name, {
    String attribute = 'name',
  }) {
    final Element? meta = doc.querySelector('meta[$attribute="$name"]');
    final String? content = meta?.attributes['content']?.trim();
    return (content != null && content.isNotEmpty) ? content : null;
  }

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
    const List<String> blocked = <String>[
      'please wait for verification',
      'just a moment',
      'attention required',
      'checking your browser',
      'verify you are human',
      'are you a robot',
      'cloudflare',
      'access denied',
    ];
    if (blocked.any(normalized.contains)) return null;
    return trimmed;
  }
}

class _FetchResponse {
  const _FetchResponse({
    required this.effectiveUrl,
    this.statusCode,
    this.bytes,
    this.body,
    this.contentTypeHeader,
  });

  final String effectiveUrl;
  final int? statusCode;
  final List<int>? bytes;
  final String? body;
  final String? contentTypeHeader;
}

class _JsonLdData {
  const _JsonLdData({
    this.title,
    this.description,
    this.articleBody,
    this.author,
    this.publisher,
    this.publishDate,
    this.image,
    this.canonicalUrl,
    this.language,
    this.wordCount,
  });

  final String? title;
  final String? description;
  final String? articleBody;
  final String? author;
  final String? publisher;
  final DateTime? publishDate;
  final String? image;
  final String? canonicalUrl;
  final String? language;
  final int? wordCount;
}

class _ReadabilityData {
  const _ReadabilityData({
    this.snippet,
    this.readingTimeMinutes,
    this.contentImageUrl,
  });

  final String? snippet;
  final int? readingTimeMinutes;
  final String? contentImageUrl;
}
