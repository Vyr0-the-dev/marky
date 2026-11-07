import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:marky/core/scraping/parsers/generic_html_parser.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/reader/domain/article_content.dart';
import 'package:path_provider/path_provider.dart';

/// Service responsible for extracting distraction-free, rich article content
/// from web pages, Reddit posts, Twitter/X links, and cached snapshots.
class ArticleExtractorService {
  ArticleExtractorService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 15),
                followRedirects: true,
                maxRedirects: 6,
                headers: GenericHtmlParser.browserNavigationHeaders(),
              ),
            );

  final Dio _dio;

  static final RegExp _noiseSelectors = RegExp(
    '(cookie|banner|popup|modal|sidebar|footer|header|navbar|nav-|menu|breadcrumb|social|share|comment|promo|advert|sponsor|newsletter|related|outbrain|taboola|recommend)',
    caseSensitive: false,
  );

  /// Fetches distraction-free article content for [bookmark].
  ///
  /// Checks local disk cache first unless [forceRefresh] is true.
  Future<ArticleContent> fetchArticle(
    Bookmark bookmark, {
    bool forceRefresh = false,
  }) async {
    final String targetUrl =
        (bookmark.canonicalUrl?.trim().isNotEmpty ?? false)
            ? bookmark.canonicalUrl!
            : bookmark.originalUrl;

    final String cacheKey = md5.convert(utf8.encode(targetUrl)).toString();

    if (!forceRefresh) {
      final ArticleContent? cached = await _readFromCache(cacheKey);
      if (cached != null) return cached;
    }

    try {
      ArticleContent? content;
      final Uri? uri = Uri.tryParse(targetUrl);
      final String host = uri?.host.toLowerCase() ?? '';

      if (host.contains('reddit.com') || host.contains('redd.it')) {
        content = await _extractRedditArticle(targetUrl, bookmark);
      } else if (host.contains('twitter.com') || host.contains('x.com')) {
        content = await _extractTwitterArticle(targetUrl, bookmark);
      }

      content ??= await _extractGenericWebArticle(targetUrl, bookmark);

      if (content.blocks.isNotEmpty) {
        await _saveToCache(cacheKey, content);
        return content;
      }
    } catch (e) {
      debugPrint('[ArticleExtractorService] Extraction error: $e');
    }

    // Fallback: build from existing bookmark metadata
    final ArticleContent fallback = _buildFallbackContent(bookmark);
    return fallback;
  }

  // ─── Generic Web Article Extraction ─────────────────────────────

  Future<ArticleContent> _extractGenericWebArticle(
    String targetUrl,
    Bookmark bookmark,
  ) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      targetUrl,
      options: Options(
        responseType: ResponseType.plain,
        headers: GenericHtmlParser.browserNavigationHeaders(url: targetUrl),
      ),
    );

    final String html = response.data?.toString() ?? '';
    if (html.trim().isEmpty) {
      return _buildFallbackContent(bookmark);
    }

    final dom.Document doc = html_parser.parse(html);
    final Uri baseUri = Uri.parse(targetUrl);

    // 1. Check for JSON-LD articleBody first
    String? jsonLdBody;
    String? jsonLdTitle;
    String? jsonLdAuthor;
    for (final dom.Element script in doc.querySelectorAll('script[type="application/ld+json"]')) {
      final String raw = script.text.trim();
      if (raw.isEmpty) continue;
      try {
        final dynamic parsed = jsonDecode(raw);
        final Map<String, dynamic>? articleMap = _findArticleInJsonLd(parsed);
        if (articleMap != null) {
          jsonLdBody = articleMap['articleBody'] as String?;
          jsonLdTitle = articleMap['headline'] as String? ?? articleMap['name'] as String?;
          if (articleMap['author'] is Map) {
            jsonLdAuthor = (articleMap['author'] as Map)['name'] as String?;
          } else if (articleMap['author'] is List && (articleMap['author'] as List).isNotEmpty) {
            final dynamic first = (articleMap['author'] as List).first;
            if (first is Map) jsonLdAuthor = first['name'] as String?;
          }
          if (jsonLdBody != null && jsonLdBody.length > 250) break;
        }
      } catch (_) {}
    }

    // 2. Clone body and clean noise
    final dom.Element? bodyClone = doc.body?.clone(true);
    if (bodyClone == null) {
      return _buildFallbackContent(bookmark);
    }

    for (final dom.Element el in bodyClone.querySelectorAll(
      'script, style, noscript, iframe, svg, nav, footer, header, aside, form, button, dialog, canvas',
    )) {
      el.remove();
    }

    // Strip elements with noise class or ID
    for (final dom.Element el in bodyClone.querySelectorAll('*').toList()) {
      final String tag = el.localName?.toLowerCase() ?? '';
      if (tag == 'article' || tag == 'main' || tag == 'body') continue;
      final String classAndId = '${el.attributes['class'] ?? ''} ${el.attributes['id'] ?? ''}';
      if (_noiseSelectors.hasMatch(classAndId) && el.querySelector('article, main') == null) {
        el.remove();
      }
    }

    // 3. Find primary article container
    dom.Element? contentContainer;
    final List<String> highConfidenceSelectors = <String>[
      'article',
      '[role="article"]',
      'main',
      '[role="main"]',
      '.article-content',
      '.entry-content',
      '.post-content',
      '.article-body',
      '.story-body',
      '.content-body',
      '.post-body',
      '.article__body',
      '.rich-text',
      '#article-body',
      '#content-body',
    ];

    for (final String selector in highConfidenceSelectors) {
      final dom.Element? el = bodyClone.querySelector(selector);
      if (el != null && el.querySelectorAll('p').isNotEmpty) {
        contentContainer = el;
        break;
      }
    }

    // If still null, score containers by paragraph text density
    contentContainer ??= _findBestContainerByScoring(bodyClone);

    // 4. Extract blocks from container
    final List<ArticleBlock> blocks = <ArticleBlock>[];
    if (contentContainer != null) {
      _extractBlocksFromElement(contentContainer, blocks, baseUri);
    }

    // If blocks too short or empty, try JSON-LD articleBody fallback
    if (blocks.length < 2 && jsonLdBody != null && jsonLdBody.length > 200) {
      blocks.clear();
      final List<String> paragraphs = jsonLdBody.split(RegExp(r'\n+'));
      for (final String p in paragraphs) {
        final String clean = _cleanText(p);
        if (clean.length > 25) {
          blocks.add(ArticleBlock(type: ArticleBlockType.paragraph, text: clean));
        }
      }
    }

    if (blocks.isEmpty) {
      return _buildFallbackContent(bookmark);
    }

    final String title = jsonLdTitle ??
        doc.querySelector('h1')?.text.trim() ??
        bookmark.displayTitle;

    final int totalWords = blocks.fold<int>(
      0,
      (int acc, ArticleBlock b) =>
          acc + b.text.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length,
    );

    final int readingTimeMinutes =
        totalWords >= 60 ? (totalWords / 200.0).ceil().clamp(1, 120) : 1;

    return ArticleContent(
      title: title,
      author: jsonLdAuthor ?? bookmark.author,
      siteName: bookmark.siteName ?? baseUri.host,
      publishDate: bookmark.publishDate,
      heroImageUrl: bookmark.heroImageUrl,
      blocks: blocks,
      readingTimeMinutes: readingTimeMinutes,
      cachedAt: DateTime.now(),
    );
  }

  void _extractBlocksFromElement(
    dom.Element container,
    List<ArticleBlock> blocks,
    Uri baseUri,
  ) {
    for (final dom.Element child in container.children) {
      final String tag = child.localName?.toLowerCase() ?? '';

      if (RegExp(r'^h[1-6]$').hasMatch(tag)) {
        final int level = int.tryParse(tag.substring(1)) ?? 1;
        final String text = _cleanText(child.text);
        if (text.length > 3) {
          blocks.add(ArticleBlock(
            type: ArticleBlockType.heading,
            text: text,
            level: level,
          ));
        }
      } else if (tag == 'p') {
        final String text = _cleanText(child.text);
        if (text.length > 20) {
          blocks.add(ArticleBlock(type: ArticleBlockType.paragraph, text: text));
        }
      } else if (tag == 'blockquote') {
        final String text = _cleanText(child.text);
        if (text.isNotEmpty) {
          blocks.add(ArticleBlock(type: ArticleBlockType.blockquote, text: text));
        }
      } else if (tag == 'pre') {
        final String code = child.text.trim();
        if (code.isNotEmpty) {
          blocks.add(ArticleBlock(type: ArticleBlockType.code, text: code));
        }
      } else if (tag == 'ul' || tag == 'ol') {
        final List<String> items = child
            .querySelectorAll('li')
            .map((dom.Element li) => _cleanText(li.text))
            .where((String t) => t.isNotEmpty)
            .toList();
        if (items.isNotEmpty) {
          blocks.add(ArticleBlock(
            type: ArticleBlockType.list,
            text: '',
            isOrdered: tag == 'ol',
            listItems: items,
          ));
        }
      } else if (tag == 'figure' || tag == 'img') {
        final dom.Element img = tag == 'img' ? child : (child.querySelector('img') ?? child);
        final String? rawSrc = img.attributes['src'] ??
            img.attributes['data-src'] ??
            img.attributes['data-original'];
        final String? caption = child.querySelector('figcaption')?.text.trim();
        if (rawSrc != null && rawSrc.isNotEmpty) {
          final String resolved = _resolveUrl(baseUri, rawSrc);
          if (resolved.startsWith('http')) {
            blocks.add(ArticleBlock(
              type: ArticleBlockType.image,
              text: '',
              imageUrl: resolved,
              caption: caption,
            ));
          }
        }
      } else if (child.children.isNotEmpty) {
        // Recurse into wrapping divs or sections
        _extractBlocksFromElement(child, blocks, baseUri);
      }
    }
  }

  dom.Element? _findBestContainerByScoring(dom.Element body) {
    final Map<dom.Element, double> scores = <dom.Element, double>{};
    for (final dom.Element p in body.querySelectorAll('p')) {
      final String text = p.text.trim();
      if (text.length < 30) continue;
      final dom.Element? parent = p.parent;
      if (parent == null) continue;

      scores[parent] = (scores[parent] ?? 0.0) + text.length;
      final dom.Element? grandParent = parent.parent;
      if (grandParent != null && grandParent != body) {
        scores[grandParent] = (scores[grandParent] ?? 0.0) + (text.length * 0.5);
      }
    }

    dom.Element? best;
    double maxScore = -1;
    scores.forEach((dom.Element el, double score) {
      if (score > maxScore) {
        maxScore = score;
        best = el;
      }
    });
    return best;
  }

  // ─── Reddit Extraction ──────────────────────────────────────────

  Future<ArticleContent?> _extractRedditArticle(
    String targetUrl,
    Bookmark bookmark,
  ) async {
    try {
      final Uri uri = Uri.parse(targetUrl);
      String jsonPath = uri.path;
      if (!jsonPath.endsWith('.json')) {
        jsonPath = jsonPath.endsWith('/') ? '${jsonPath.substring(0, jsonPath.length - 1)}.json' : '$jsonPath.json';
      }

      final Uri jsonUri = uri.replace(
        path: jsonPath,
        queryParameters: <String, String>{'raw_json': '1'},
      );

      final Response<dynamic> response = await _dio.get<dynamic>(
        jsonUri.toString(),
        options: Options(
          responseType: ResponseType.json,
          headers: <String, String>{
            'User-Agent': 'marky:v1.0.0 (by /u/marky_app)',
          },
        ),
      );

      final dynamic data = response.data;
      if (data is! List || data.isEmpty) return null;

      final dynamic root0 = data[0];
      if (root0 is! Map) return null;
      final dynamic root0Data = root0['data'];
      if (root0Data is! Map) return null;
      final dynamic children = root0Data['children'];
      if (children is! List || children.isEmpty) return null;
      final dynamic firstChild = children[0];
      if (firstChild is! Map) return null;
      final dynamic postData = firstChild['data'];
      if (postData is! Map) return null;

      final String title = postData['title'] as String? ?? bookmark.displayTitle;
      final String author = 'u/${postData['author'] ?? ''}';
      final String subreddit = 'r/${postData['subreddit'] ?? ''}';
      final String selftext = postData['selftext'] as String? ?? '';
      final dynamic preview = postData['preview'];
      String? previewImage;
      if (preview is Map && preview['images'] is List && (preview['images'] as List).isNotEmpty) {
        final dynamic firstImg = (preview['images'] as List)[0];
        if (firstImg is Map && firstImg['source'] is Map) {
          previewImage = (firstImg['source'] as Map)['url'] as String?;
        }
      }

      final List<ArticleBlock> blocks = <ArticleBlock>[];

      // Parse markdown selftext
      if (selftext.trim().isNotEmpty) {
        final List<String> rawBlocks = selftext.split(RegExp(r'\n{2,}'));
        for (final String b in rawBlocks) {
          final String trimmed = b.trim();
          if (trimmed.isEmpty) continue;
          if (trimmed.startsWith('#')) {
            final int level = trimmed.indexOf(' ');
            final String text = level != -1 ? trimmed.substring(level).trim() : trimmed;
            blocks.add(ArticleBlock(
              type: ArticleBlockType.heading,
              text: text,
              level: level > 0 && level <= 3 ? level : 2,
            ));
          } else if (trimmed.startsWith('>')) {
            blocks.add(ArticleBlock(
              type: ArticleBlockType.blockquote,
              text: trimmed.replaceFirst(RegExp(r'^>\s*'), ''),
            ));
          } else if (trimmed.startsWith('```')) {
            blocks.add(ArticleBlock(
              type: ArticleBlockType.code,
              text: trimmed.replaceAll('```', '').trim(),
            ));
          } else {
            blocks.add(ArticleBlock(
              type: ArticleBlockType.paragraph,
              text: trimmed,
            ));
          }
        }
      }

      // Add top comments for discussion context if available
      if (data.length > 1) {
        final dynamic commentRoot = data[1];
        final dynamic commentsData = commentRoot is Map && commentRoot['data'] is Map
            ? (commentRoot['data'] as Map)['children']
            : null;
        if (commentsData is List && commentsData.isNotEmpty) {
          blocks.add(const ArticleBlock(
            type: ArticleBlockType.heading,
            text: 'Öne Çıkan Yorumlar',
            level: 2,
          ));

          int commentCount = 0;
          for (final dynamic c in commentsData) {
            if (commentCount >= 4) break;
            if (c is Map && c['data'] is Map) {
              final Map<dynamic, dynamic> cData = c['data'] as Map;
              final String cAuthor = cData['author'] as String? ?? '';
              final String cBody = cData['body'] as String? ?? '';
              final int score = cData['score'] as int? ?? 0;
              if (cBody.isNotEmpty && cAuthor != '[deleted]') {
                blocks.add(ArticleBlock(
                  type: ArticleBlockType.blockquote,
                  text: 'u/$cAuthor ($score oy):\n$cBody',
                ));
                commentCount++;
              }
            }
          }
        }
      }

      final int wordCount = blocks.fold<int>(
        0,
        (int acc, ArticleBlock b) =>
            acc + b.text.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length,
      );

      return ArticleContent(
        title: title,
        author: author,
        siteName: subreddit,
        publishDate: bookmark.publishDate,
        heroImageUrl: previewImage ?? bookmark.heroImageUrl,
        blocks: blocks,
        readingTimeMinutes: (wordCount / 200.0).ceil().clamp(1, 120),
        cachedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  // ─── Twitter Extraction ─────────────────────────────────────────

  Future<ArticleContent?> _extractTwitterArticle(
    String targetUrl,
    Bookmark bookmark,
  ) async {
    try {
      final Uri uri = Uri.parse(targetUrl);
      final List<String> segments = uri.pathSegments;
      final int statusIdx = segments.indexOf('status');
      if (statusIdx == -1 || statusIdx + 1 >= segments.length) return null;

      final String tweetId = segments[statusIdx + 1];
      final String user = segments[0];

      final Response<dynamic> response = await _dio.get<dynamic>(
        'https://api.fxtwitter.com/$user/status/$tweetId',
      );

      final dynamic root = response.data;
      if (root is! Map) return null;
      final dynamic tweet = root['tweet'];
      if (tweet is! Map) return null;

      final String text = tweet['text'] as String? ?? '';
      final dynamic tweetAuthor = tweet['author'];
      final String author = (tweetAuthor is Map ? tweetAuthor['name'] as String? : null) ?? user;
      final String handle = '@${(tweetAuthor is Map ? tweetAuthor['screen_name'] as String? : null) ?? user}';

      final List<ArticleBlock> blocks = <ArticleBlock>[];
      blocks.add(ArticleBlock(type: ArticleBlockType.paragraph, text: text));

      // Photos
      final dynamic media = tweet['media'];
      if (media is Map && media['photos'] is List) {
        for (final dynamic photo in media['photos'] as List) {
          if (photo is Map) {
            final String? url = photo['url'] as String?;
            if (url != null) {
              blocks.add(ArticleBlock(type: ArticleBlockType.image, text: '', imageUrl: url));
            }
          }
        }
      }

      return ArticleContent(
        title: '$author ($handle)',
        author: author,
        siteName: 'Twitter / X',
        publishDate: bookmark.publishDate,
        heroImageUrl: bookmark.heroImageUrl,
        blocks: blocks,
        readingTimeMinutes: 1,
        cachedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  // ─── Fallback & Caching Helpers ─────────────────────────────────

  ArticleContent _buildFallbackContent(Bookmark bookmark) {
    final List<ArticleBlock> blocks = <ArticleBlock>[];

    if (bookmark.description != null && bookmark.description!.trim().isNotEmpty) {
      blocks.add(ArticleBlock(
        type: ArticleBlockType.paragraph,
        text: bookmark.description!.trim(),
      ));
    }

    if (bookmark.snippet != null &&
        bookmark.snippet!.trim().isNotEmpty &&
        bookmark.snippet!.trim() != bookmark.description?.trim()) {
      blocks.add(ArticleBlock(
        type: ArticleBlockType.paragraph,
        text: bookmark.snippet!.trim(),
      ));
    }

    if (blocks.isEmpty) {
      blocks.add(const ArticleBlock(
        type: ArticleBlockType.paragraph,
        text:
            'Bu web sayfası için ayrıştırılmış makale metni bulunamadı. Orijinal sayfayı tarayıcıda açarak tam içeriği görüntüleyebilirsiniz.',
      ));
    }

    return ArticleContent(
      title: bookmark.displayTitle,
      author: bookmark.author,
      siteName: bookmark.siteName ?? bookmark.normalizedHost,
      publishDate: bookmark.publishDate,
      heroImageUrl: bookmark.heroImageUrl,
      blocks: blocks,
      readingTimeMinutes: bookmark.readingTimeMinutes ?? 1,
      isFallback: true,
      cachedAt: DateTime.now(),
    );
  }

  Future<ArticleContent?> _readFromCache(String key) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final File cacheFile = File('${tempDir.path}/reader_cache/$key.json');
      if (cacheFile.existsSync()) {
        final String raw = await cacheFile.readAsString();
        final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
        final ArticleContent content = ArticleContent.fromJson(json);
        // Expire cache after 7 days
        if (DateTime.now().difference(content.cachedAt).inDays < 7) {
          return content;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveToCache(String key, ArticleContent content) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final Directory dir = Directory('${tempDir.path}/reader_cache');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final File cacheFile = File('${dir.path}/$key.json');
      await cacheFile.writeAsString(jsonEncode(content.toJson()));
    } catch (_) {}
  }

  Map<String, dynamic>? _findArticleInJsonLd(dynamic json) {
    if (json is List) {
      for (final dynamic item in json) {
        final Map<String, dynamic>? res = _findArticleInJsonLd(item);
        if (res != null) return res;
      }
    } else if (json is Map<String, dynamic>) {
      final dynamic type = json['@type'];
      if (type == 'Article' || type == 'NewsArticle' || type == 'BlogPosting') {
        return json;
      }
      if (json['@graph'] != null) {
        return _findArticleInJsonLd(json['@graph']);
      }
    }
    return null;
  }

  String _cleanText(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _resolveUrl(Uri baseUri, String relative) {
    try {
      return baseUri.resolve(relative).toString();
    } catch (_) {
      return relative;
    }
  }
}
