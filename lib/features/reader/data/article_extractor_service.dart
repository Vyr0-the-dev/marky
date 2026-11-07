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

  static final RegExp _redditShortlinkPattern = RegExp(
    r'(redd\.it|\/s\/)',
    caseSensitive: false,
  );

  static final RegExp _twitterIdPattern = RegExp(
    r'\/(?:status|statuses|article)\/(\d+)',
    caseSensitive: false,
  );

  /// Fetches distraction-free article content for [bookmark].
  ///
  /// Checks local disk cache first unless [forceRefresh] is true.
  Future<ArticleContent> fetchArticle(
    Bookmark bookmark, {
    bool forceRefresh = false,
  }) async {
    final String targetUrl = (bookmark.canonicalUrl?.trim().isNotEmpty ?? false)
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
    for (final dom.Element script
        in doc.querySelectorAll('script[type="application/ld+json"]')) {
      final String raw = script.text.trim();
      if (raw.isEmpty) continue;
      try {
        final dynamic parsed = jsonDecode(raw);
        final Map<String, dynamic>? articleMap = _findArticleInJsonLd(parsed);
        if (articleMap != null) {
          jsonLdBody = articleMap['articleBody'] as String?;
          jsonLdTitle = articleMap['headline'] as String? ??
              articleMap['name'] as String?;
          if (articleMap['author'] is Map) {
            jsonLdAuthor = (articleMap['author'] as Map)['name'] as String?;
          } else if (articleMap['author'] is List &&
              (articleMap['author'] as List).isNotEmpty) {
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
      final String classAndId =
          '${el.attributes['class'] ?? ''} ${el.attributes['id'] ?? ''}';
      if (_noiseSelectors.hasMatch(classAndId) &&
          el.querySelector('article, main') == null) {
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
          blocks
              .add(ArticleBlock(type: ArticleBlockType.paragraph, text: clean));
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
          acc +
          b.text.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length,
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
          blocks
              .add(ArticleBlock(type: ArticleBlockType.paragraph, text: text));
        }
      } else if (tag == 'blockquote') {
        final String text = _cleanText(child.text);
        if (text.isNotEmpty) {
          blocks
              .add(ArticleBlock(type: ArticleBlockType.blockquote, text: text));
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
        final dom.Element img =
            tag == 'img' ? child : (child.querySelector('img') ?? child);
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
        scores[grandParent] =
            (scores[grandParent] ?? 0.0) + (text.length * 0.5);
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

  Future<String> _resolveRedirectUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (!_redditShortlinkPattern.hasMatch(url)) return url;

    try {
      final Response<dynamic> res = await _dio.get<dynamic>(
        url,
        options: Options(
          followRedirects: true,
          maxRedirects: 6,
          headers: <String, dynamic>{
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          },
          validateStatus: (int? s) => s != null && s < 400,
        ),
      );
      final String resolved = res.realUri.toString();
      if (resolved.isNotEmpty && resolved != url) return resolved;
    } catch (_) {}
    return url;
  }

  Future<ArticleContent?> _extractRedditArticle(
    String targetUrl,
    Bookmark bookmark,
  ) async {
    try {
      final String resolvedUrl = await _resolveRedirectUrl(targetUrl);
      final Uri uri = Uri.parse(resolvedUrl);
      String jsonPath = uri.path;
      if (!jsonPath.endsWith('.json')) {
        jsonPath = jsonPath.endsWith('/')
            ? '${jsonPath.substring(0, jsonPath.length - 1)}.json'
            : '$jsonPath.json';
      }

      final Uri jsonUri = uri.replace(
        path: jsonPath,
        queryParameters: <String, String>{'raw_json': '1'},
      );

      Response<dynamic>? response;
      try {
        response = await _dio.get<dynamic>(
          jsonUri.toString(),
          options: Options(
            responseType: ResponseType.json,
            headers: <String, String>{
              'User-Agent': 'android:com.marky.app:v1.0.0 (by /u/marky_reader)',
              'Accept': 'application/json',
            },
          ),
        );
      } catch (_) {
        return await _extractRedditFromHtml(resolvedUrl, bookmark);
      }

      final dynamic data = response.data;
      if (data is! List || data.isEmpty) {
        return await _extractRedditFromHtml(resolvedUrl, bookmark);
      }

      final dynamic root0 = data[0];
      if (root0 is! Map) {
        return await _extractRedditFromHtml(resolvedUrl, bookmark);
      }
      final dynamic root0Data = root0['data'];
      if (root0Data is! Map) {
        return await _extractRedditFromHtml(resolvedUrl, bookmark);
      }
      final dynamic children = root0Data['children'];
      if (children is! List || children.isEmpty) {
        return await _extractRedditFromHtml(resolvedUrl, bookmark);
      }
      final dynamic firstChild = children[0];
      if (firstChild is! Map) {
        return await _extractRedditFromHtml(resolvedUrl, bookmark);
      }
      final dynamic postData = firstChild['data'];
      if (postData is! Map) {
        return await _extractRedditFromHtml(resolvedUrl, bookmark);
      }

      final String title =
          postData['title'] as String? ?? bookmark.displayTitle;
      final String author = 'u/${postData['author'] ?? ''}';
      final String subreddit = 'r/${postData['subreddit'] ?? ''}';
      final String selftext = postData['selftext'] as String? ?? '';

      // Gallery extraction
      final List<String> galleryImages = <String>[];
      final dynamic mediaMetadata = postData['media_metadata'];
      if (mediaMetadata is Map) {
        for (final dynamic item in mediaMetadata.values) {
          if (item is Map) {
            final dynamic s = item['s'];
            if (s is Map && s['u'] is String) {
              galleryImages.add((s['u'] as String).replaceAll('&amp;', '&'));
            } else {
              final dynamic p = item['p'];
              if (p is List && p.isNotEmpty) {
                final dynamic lastP = p.last;
                if (lastP is Map && lastP['u'] is String) {
                  galleryImages
                      .add((lastP['u'] as String).replaceAll('&amp;', '&'));
                }
              }
            }
          }
        }
      }

      // Preview image
      String? previewImage;
      final dynamic preview = postData['preview'];
      if (preview is Map &&
          preview['images'] is List &&
          (preview['images'] as List).isNotEmpty) {
        final dynamic firstImg = (preview['images'] as List)[0];
        if (firstImg is Map && firstImg['source'] is Map) {
          final String? raw = (firstImg['source'] as Map)['url'] as String?;
          previewImage = raw?.replaceAll('&amp;', '&');
        }
      }

      // Direct outbound image
      final String? outboundUrl =
          (postData['url_overridden_by_dest'] as String?) ??
              (postData['url'] as String?);
      String? directImage;
      if (outboundUrl != null) {
        final String lower = outboundUrl.toLowerCase();
        if (lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.png') ||
            lower.endsWith('.gif') ||
            lower.endsWith('.webp')) {
          directImage = outboundUrl;
        }
      }

      final String? heroImage = galleryImages.firstOrNull ??
          directImage ??
          previewImage ??
          bookmark.heroImageUrl;

      final List<ArticleBlock> blocks = <ArticleBlock>[];

      // Parse rich markdown selftext
      if (selftext.trim().isNotEmpty) {
        _parseMarkdownBlocks(selftext, blocks);
      }

      // If gallery has multiple images, embed remaining gallery images as image blocks
      if (galleryImages.length > 1) {
        for (int i = 1; i < galleryImages.length; i++) {
          blocks.add(ArticleBlock(
            type: ArticleBlockType.image,
            text: '',
            imageUrl: galleryImages[i],
            caption: 'Görsel ${i + 1}/${galleryImages.length}',
          ));
        }
      }

      // Add top comments for discussion context if available
      if (data.length > 1) {
        final dynamic commentRoot = data[1];
        final dynamic commentsData =
            commentRoot is Map && commentRoot['data'] is Map
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
            if (commentCount >= 5) break;
            if (c is Map && c['data'] is Map) {
              final Map<dynamic, dynamic> cData = c['data'] as Map;
              final String cAuthor = cData['author'] as String? ?? '';
              final String cBody = cData['body'] as String? ?? '';
              final int score = cData['score'] as int? ?? 0;
              if (cBody.isNotEmpty &&
                  cAuthor != '[deleted]' &&
                  cAuthor != 'AutoModerator') {
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
            acc +
            b.text
                .split(RegExp(r'\s+'))
                .where((String w) => w.isNotEmpty)
                .length,
      );

      return ArticleContent(
        title: title,
        author: author,
        siteName: subreddit.isNotEmpty ? subreddit : 'Reddit',
        publishDate: bookmark.publishDate,
        heroImageUrl: heroImage,
        blocks: blocks.isNotEmpty
            ? blocks
            : <ArticleBlock>[
                ArticleBlock(
                  type: ArticleBlockType.paragraph,
                  text: title,
                ),
              ],
        readingTimeMinutes: (wordCount / 200.0).ceil().clamp(1, 120),
        cachedAt: DateTime.now(),
      );
    } catch (_) {
      return _extractRedditFromHtml(targetUrl, bookmark);
    }
  }

  Future<ArticleContent?> _extractRedditFromHtml(
    String targetUrl,
    Bookmark bookmark,
  ) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        targetUrl,
        options: Options(
          responseType: ResponseType.plain,
          headers: <String, String>{
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          },
        ),
      );
      final String html = response.data?.toString() ?? '';
      if (html.isEmpty) return null;

      final dom.Document doc = html_parser.parse(html);
      final dom.Element? shreddit = doc.querySelector('shreddit-post');
      final String title = shreddit?.attributes['post-title'] ??
          doc
              .querySelector('meta[property="og:title"]')
              ?.attributes['content'] ??
          bookmark.displayTitle;
      final String? author = shreddit?.attributes['author'];
      final String? subreddit = shreddit?.attributes['subreddit-prefixed-name'];
      final String? heroImage = shreddit?.attributes['content-href'] ??
          doc
              .querySelector('meta[property="og:image"]')
              ?.attributes['content'] ??
          bookmark.heroImageUrl;

      final List<ArticleBlock> blocks = <ArticleBlock>[];
      final dom.Element? textBody = doc.querySelector('div[slot="text-body"]');
      if (textBody != null) {
        for (final dom.Element p in textBody.querySelectorAll('p')) {
          final String t = _cleanText(p.text);
          if (t.isNotEmpty) {
            blocks.add(ArticleBlock(type: ArticleBlockType.paragraph, text: t));
          }
        }
      }

      if (blocks.isEmpty) {
        final String? ogDesc = doc
            .querySelector('meta[property="og:description"]')
            ?.attributes['content'];
        if (ogDesc != null && ogDesc.isNotEmpty) {
          blocks.add(
            ArticleBlock(type: ArticleBlockType.paragraph, text: ogDesc),
          );
        }
      }

      if (blocks.isEmpty) return null;

      return ArticleContent(
        title: title,
        author: author != null ? 'u/$author' : bookmark.author,
        siteName: subreddit ?? 'Reddit',
        publishDate: bookmark.publishDate,
        heroImageUrl: heroImage,
        blocks: blocks,
        readingTimeMinutes: (blocks.length * 30 / 200.0).ceil().clamp(1, 60),
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
      final Match? match = _twitterIdPattern.firstMatch(targetUrl);
      if (match == null) return null;

      final String tweetId = match.group(1)!;
      final List<String> segments = uri.pathSegments;
      String user = 'i';
      if (segments.isNotEmpty &&
          segments.first.isNotEmpty &&
          segments.first != 'i' &&
          segments.first != 'status' &&
          segments.first != 'article') {
        user = segments.first;
      }

      final List<String> endpoints = <String>[
        'https://api.fxtwitter.com/$user/status/$tweetId',
        'https://api.vxtwitter.com/$user/status/$tweetId',
      ];

      Map<String, dynamic>? tweetData;
      for (final String endpoint in endpoints) {
        try {
          final Response<dynamic> res = await _dio.get<dynamic>(endpoint);
          if (res.data is Map<String, dynamic>) {
            final Map<String, dynamic> root = res.data as Map<String, dynamic>;
            final dynamic tw = root['tweet'] ?? root;
            if (tw is Map<String, dynamic>) {
              tweetData = tw;
              break;
            }
          }
        } catch (_) {}
      }

      if (tweetData == null) {
        return await _extractTwitterFromOEmbed(targetUrl, bookmark);
      }

      final dynamic tweetAuthor = tweetData['author'];
      final String author =
          (tweetAuthor is Map ? tweetAuthor['name'] as String? : null) ?? user;
      final String handle =
          '@${(tweetAuthor is Map ? tweetAuthor['screen_name'] as String? : null) ?? user}';

      final List<ArticleBlock> blocks = <ArticleBlock>[];

      // Check for X Article / Long-form article
      final dynamic article = tweetData['article'];
      String articleTitle = '';
      String? articleCover;
      if (article is Map) {
        articleTitle = (article['title'] as String?) ?? '';
        articleCover = article['cover_image'] as String?;
        final dynamic content = article['content'] ?? article['preview_text'];
        if (content is String && content.isNotEmpty) {
          _parseMarkdownBlocks(content, blocks);
        }
      }

      // If not an X Article or blocks empty, use regular tweet text
      if (blocks.isEmpty) {
        final String text = (tweetData['text'] as String?) ?? '';
        if (text.isNotEmpty) {
          blocks
              .add(ArticleBlock(type: ArticleBlockType.paragraph, text: text));
        }
      }

      // Photos
      final dynamic media = tweetData['media'];
      if (media is Map && media['photos'] is List) {
        for (final dynamic photo in media['photos'] as List) {
          if (photo is Map) {
            final String? url = photo['url'] as String?;
            if (url != null && url.isNotEmpty) {
              blocks.add(ArticleBlock(
                type: ArticleBlockType.image,
                text: '',
                imageUrl: url,
              ));
            }
          }
        }
      }

      // Quote tweet
      final dynamic quote = tweetData['quote'];
      if (quote is Map) {
        final String? qText = quote['text'] as String?;
        final dynamic qAuthor = quote['author'];
        final String qName =
            (qAuthor is Map ? qAuthor['name'] as String? : null) ?? 'X';
        if (qText != null && qText.isNotEmpty) {
          blocks.add(ArticleBlock(
            type: ArticleBlockType.blockquote,
            text: '$qName:\n$qText',
          ));
        }
      }

      // Thread tweets
      final dynamic thread = tweetData['thread'];
      if (thread is List) {
        for (final dynamic t in thread) {
          if (t is Map) {
            final String? tText = t['text'] as String?;
            if (tText != null && tText.isNotEmpty) {
              blocks.add(ArticleBlock(
                type: ArticleBlockType.paragraph,
                text: tText,
              ));
            }
          }
        }
      }

      final String finalTitle =
          articleTitle.isNotEmpty ? articleTitle : '$author ($handle)';

      final int wordCount = blocks.fold<int>(
        0,
        (int acc, ArticleBlock b) =>
            acc +
            b.text
                .split(RegExp(r'\s+'))
                .where((String w) => w.isNotEmpty)
                .length,
      );

      return ArticleContent(
        title: finalTitle,
        author: '$author ($handle)',
        siteName: 'Twitter / X',
        publishDate: bookmark.publishDate,
        heroImageUrl: articleCover ?? bookmark.heroImageUrl,
        blocks: blocks.isNotEmpty
            ? blocks
            : <ArticleBlock>[
                ArticleBlock(
                  type: ArticleBlockType.paragraph,
                  text: bookmark.displayTitle,
                ),
              ],
        readingTimeMinutes: (wordCount / 200.0).ceil().clamp(1, 120),
        cachedAt: DateTime.now(),
      );
    } catch (_) {
      return _extractTwitterFromOEmbed(targetUrl, bookmark);
    }
  }

  Future<ArticleContent?> _extractTwitterFromOEmbed(
    String targetUrl,
    Bookmark bookmark,
  ) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        'https://publish.twitter.com/oembed',
        queryParameters: <String, dynamic>{
          'url': targetUrl,
          'omit_script': 'true',
        },
      );
      final dynamic data = response.data;
      if (data is! Map) return null;

      final String? authorName = data['author_name'] as String?;
      final String? htmlContent = data['html'] as String?;
      if (htmlContent == null || htmlContent.isEmpty) return null;

      final dom.Document doc = html_parser.parse(htmlContent);
      final String plainText = _cleanText(doc.body?.text ?? '');
      if (plainText.isEmpty) return null;

      return ArticleContent(
        title:
            authorName != null ? 'Post by $authorName' : bookmark.displayTitle,
        author: authorName ?? bookmark.author,
        siteName: 'Twitter / X',
        publishDate: bookmark.publishDate,
        heroImageUrl: bookmark.heroImageUrl,
        blocks: <ArticleBlock>[
          ArticleBlock(type: ArticleBlockType.paragraph, text: plainText),
        ],
        readingTimeMinutes: 1,
        cachedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  void _parseMarkdownBlocks(String rawMarkdown, List<ArticleBlock> blocks) {
    final List<String> rawBlocks = rawMarkdown.split(RegExp(r'\n{2,}'));
    for (final String b in rawBlocks) {
      final String trimmed = b.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('#')) {
        final int spaceIdx = trimmed.indexOf(' ');
        final String text =
            spaceIdx != -1 ? trimmed.substring(spaceIdx).trim() : trimmed;
        int level = spaceIdx > 0 ? spaceIdx : 2;
        if (level < 1 || level > 3) level = 2;
        blocks.add(ArticleBlock(
          type: ArticleBlockType.heading,
          text: text,
          level: level,
        ));
      } else if (trimmed.startsWith('>')) {
        blocks.add(ArticleBlock(
          type: ArticleBlockType.blockquote,
          text: trimmed.replaceAll(RegExp(r'^>\s*', multiLine: true), ''),
        ));
      } else if (trimmed.startsWith('```')) {
        blocks.add(ArticleBlock(
          type: ArticleBlockType.code,
          text: trimmed.replaceAll('```', '').trim(),
        ));
      } else if (trimmed.startsWith('- ') ||
          trimmed.startsWith('* ') ||
          RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
        final List<String> lines = trimmed.split('\n');
        final List<String> items = <String>[];
        bool isOrdered = false;
        for (final String line in lines) {
          final String lTrim = line.trim();
          if (lTrim.isEmpty) continue;
          if (RegExp(r'^\d+\.\s').hasMatch(lTrim)) {
            isOrdered = true;
            items.add(lTrim.replaceFirst(RegExp(r'^\d+\.\s*'), ''));
          } else if (lTrim.startsWith('- ') || lTrim.startsWith('* ')) {
            items.add(lTrim.substring(2).trim());
          } else {
            items.add(lTrim);
          }
        }
        if (items.isNotEmpty) {
          blocks.add(ArticleBlock(
            type: ArticleBlockType.list,
            text: '',
            isOrdered: isOrdered,
            listItems: items,
          ));
        }
      } else {
        blocks.add(ArticleBlock(
          type: ArticleBlockType.paragraph,
          text: trimmed,
        ));
      }
    }
  }

  // ─── Fallback & Caching Helpers ─────────────────────────────────

  ArticleContent _buildFallbackContent(Bookmark bookmark) {
    final List<ArticleBlock> blocks = <ArticleBlock>[];

    if (bookmark.description != null &&
        bookmark.description!.trim().isNotEmpty) {
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
        final Map<String, dynamic> json =
            jsonDecode(raw) as Map<String, dynamic>;
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
