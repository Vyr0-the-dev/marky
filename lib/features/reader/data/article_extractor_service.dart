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
  ArticleExtractorService({
    Dio? dio,
    Future<Directory> Function()? cacheDirectoryProvider,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 15),
                followRedirects: true,
                maxRedirects: 6,
                headers: GenericHtmlParser.browserNavigationHeaders(),
              ),
            ),
        _cacheDirectoryProvider = cacheDirectoryProvider;

  final Dio _dio;
  final Future<Directory> Function()? _cacheDirectoryProvider;

  /// Sentinel text emitted for the Reddit top-comments section heading so
  /// [ReaderScreen] can localize it cleanly at render time.
  static const String topCommentsHeadingMarker = '__marky_top_comments__';

  static final RegExp _noiseSelectors = RegExp(
    r'(^|[\s_-])(cookie|consent|banner|popup|modal|sidebar|footer|navbar|nav-menu|site-nav|main-nav|breadcrumb|social-share|share-bar|share-buttons|comments-section|comment-list|promo|advert|ad-slot|sponsor|newsletter|related-posts|outbrain|taboola|recommend|paywall-banner)([\s_-]|$)',
    caseSensitive: false,
  );

  static const Set<String> _blockElementTags = <String>{
    'p',
    'div',
    'section',
    'article',
    'main',
    'ul',
    'ol',
    'pre',
    'blockquote',
    'table',
    'figure',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
  };

  static const Set<String> _skippedTextTags = <String>{
    'script',
    'style',
    'noscript',
    'svg',
    'button',
    'template',
  };

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

    // 2. Clone body and clean noise safely
    final dom.Element? bodyClone = doc.body?.clone(true);
    if (bodyClone == null) {
      return _buildFallbackContent(bookmark);
    }

    // Remove unconditionally non-article elements (keep <header> for now so
    // <article><header><h1>...</h1><p class="subtitle">...</p></header> survives).
    for (final dom.Element el in bodyClone.querySelectorAll(
      'script, style, noscript, iframe, svg, nav, footer, aside, form, button, dialog, canvas, template',
    )) {
      el.remove();
    }

    // Remove site-level <header> elements that are NOT inside <article>/<main>
    // and do not hold substantial article paragraphs.
    for (final dom.Element header
        in bodyClone.querySelectorAll('header').toList()) {
      if (_hasAncestorTag(header, const <String>{'article', 'main'})) continue;
      final int pCount = header
          .querySelectorAll('p')
          .where((dom.Element p) => p.text.trim().length > 40)
          .length;
      if (pCount < 2) {
        header.remove();
      }
    }

    // Strip elements with noise class or ID only when they do not wrap the main
    // article body (protects wrappers like "post-with-sidebar" or "has-comments").
    for (final dom.Element el in bodyClone.querySelectorAll('*').toList()) {
      if (el.parent == null) continue;
      final String tag = el.localName?.toLowerCase() ?? '';
      if (tag == 'article' || tag == 'main' || tag == 'body') continue;
      final String classAndId =
          '${el.attributes['class'] ?? ''} ${el.attributes['id'] ?? ''}';
      if (!_noiseSelectors.hasMatch(classAndId)) continue;
      if (el.querySelector('article, main, .markdown-body') != null) continue;

      final String plain = el.text.trim();
      final int substantiveParagraphs = el
          .querySelectorAll('p')
          .where((dom.Element p) => p.text.trim().length > 40)
          .length;
      if (plain.length > 400 && substantiveParagraphs >= 2) continue;

      el.remove();
    }

    // 3. Find primary article container
    final String host = baseUri.host.toLowerCase();
    dom.Element? contentContainer;

    // Dedicated GitHub README / markdown rendering path.
    if (host == 'github.com' || host.endsWith('.github.com')) {
      contentContainer = bodyClone.querySelector('article.markdown-body') ??
          bodyClone.querySelector('.markdown-body');
    }

    // Evaluate all high-confidence semantic candidates AND scored paragraph
    // containers together so a small promo/sidebar <article> never beats the
    // real article body.
    contentContainer ??= _selectBestArticleContainer(bodyClone);

    // 4. Resolve article title before block extraction so duplicate H1s can be skipped.
    final String? rawDocH1 =
        _extractReadableTextOrNull(contentContainer?.querySelector('h1')) ??
            _extractReadableTextOrNull(doc.querySelector('h1'));
    final String title = _cleanText(
      jsonLdTitle ?? rawDocH1 ?? bookmark.displayTitle,
    );

    // 5. Extract structured blocks from container
    final List<ArticleBlock> blocks = <ArticleBlock>[];
    if (contentContainer != null) {
      _extractBlocksFromElement(
        contentContainer,
        blocks,
        baseUri,
        articleTitle: title,
      );
    }

    // 6. Smart JSON-LD fallback based on word count (handles paywalled/JS-hydrated pages)
    final int extractedWords = _countBlockWords(blocks);
    if (jsonLdBody != null && jsonLdBody.trim().isNotEmpty) {
      final int jsonLdWords = _countStringWords(jsonLdBody);
      if (blocks.isEmpty ||
          (extractedWords < 80 && jsonLdWords > extractedWords * 2)) {
        final List<ArticleBlock> jsonLdBlocks =
            _blocksFromJsonLdBody(jsonLdBody, baseUri);
        if (jsonLdBlocks.isNotEmpty) {
          blocks
            ..clear()
            ..addAll(jsonLdBlocks);
        }
      }
    }

    if (blocks.isEmpty) {
      return _buildFallbackContent(bookmark);
    }

    final int totalWords = _countBlockWords(blocks);
    final int readingTimeMinutes =
        totalWords >= 60 ? (totalWords / 200.0).ceil().clamp(1, 120) : 1;

    return ArticleContent(
      title: title.isNotEmpty ? title : bookmark.displayTitle,
      author: jsonLdAuthor ?? bookmark.author,
      siteName: bookmark.siteName ?? baseUri.host,
      publishDate: bookmark.publishDate,
      heroImageUrl: bookmark.heroImageUrl,
      blocks: blocks,
      readingTimeMinutes: readingTimeMinutes,
      cachedAt: DateTime.now(),
    );
  }

  dom.Element? _selectBestArticleContainer(dom.Element body) {
    const List<String> candidateSelectors = <String>[
      'article',
      '[role="article"]',
      'main',
      '[role="main"]',
      '.markdown-body',
      '.article-content',
      '.entry-content',
      '.post-content',
      '.article-body',
      '.story-body',
      '.content-body',
      '.post-body',
      '.article__body',
      '.rich-text',
      '.prose',
      '.available-content',
      '.body.markup',
      '#article-body',
      '#content-body',
    ];

    final Set<dom.Element> candidates = <dom.Element>{};
    for (final String selector in candidateSelectors) {
      candidates.addAll(body.querySelectorAll(selector));
    }

    // Also include parent containers of substantive paragraphs and text divs.
    for (final dom.Element p in body.querySelectorAll('p')) {
      if (p.text.trim().length < 30) continue;
      if (p.parent != null && p.parent != body) {
        candidates.add(p.parent!);
      }
      if (p.parent?.parent != null && p.parent!.parent != body) {
        candidates.add(p.parent!.parent!);
      }
    }

    if (candidates.isEmpty) {
      return _findBestContainerByScoring(body) ?? body;
    }

    dom.Element? best;
    double bestScore = 0;
    for (final dom.Element candidate in candidates) {
      final double score = _scoreCandidateElement(candidate);
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }

    return best ?? _findBestContainerByScoring(body);
  }

  double _scoreCandidateElement(dom.Element el) {
    double score = 0;
    int totalTextLen = 0;

    final List<dom.Element> textBlocks =
        el.querySelectorAll('p, li, blockquote, pre');
    for (final dom.Element block in textBlocks) {
      final String text = block.text.trim();
      if (text.length < 20) continue;
      totalTextLen += text.length;
      score += text.length;
      // Punctuation / sentence density bonus (favors real prose over nav lists)
      score += (text.split(RegExp('[,.;:!?]')).length - 1) * 18.0;
    }

    // Account for sites that use <div> for paragraphs directly.
    if (textBlocks.isEmpty) {
      final String direct = _directOwnText(el).trim();
      if (direct.length >= 40) {
        totalTextLen += direct.length;
        score += direct.length;
      } else {
        for (final dom.Element div in el.querySelectorAll('div')) {
          if (div.children.any(
            (dom.Element c) =>
                _blockElementTags.contains(c.localName?.toLowerCase()),
          )) {
            continue;
          }
          final String divText = div.text.trim();
          if (divText.length >= 40) {
            totalTextLen += divText.length;
            score += divText.length * 0.9;
          }
        }
      }
    }

    if (score <= 0 || totalTextLen <= 0) return 0;

    // Link density penalty: navigation menus and related-link blocks have high
    // anchor-to-text ratios.
    final int linkTextLen = el.querySelectorAll('a').fold<int>(
          0,
          (int acc, dom.Element a) => acc + a.text.trim().length,
        );
    final double linkDensity = (linkTextLen / totalTextLen).clamp(0.0, 1.0);
    if (linkDensity > 0.55) {
      score *= 0.12;
    } else {
      score *= 1.0 - (linkDensity * 0.65);
    }

    // Semantic boost for dedicated article tags / known content classes.
    final String tag = el.localName?.toLowerCase() ?? '';
    final String classAndId =
        '${el.attributes['class'] ?? ''} ${el.attributes['id'] ?? ''}'
            .toLowerCase();
    if (tag == 'article' ||
        el.attributes['role'] == 'article' ||
        classAndId.contains('markdown-body') ||
        classAndId.contains('article-body') ||
        classAndId.contains('article-content') ||
        classAndId.contains('entry-content') ||
        classAndId.contains('post-content') ||
        classAndId.contains('available-content') ||
        classAndId.contains('prose')) {
      score *= 1.25;
    } else if (tag == 'main' || el.attributes['role'] == 'main') {
      score *= 1.1;
    }

    return score;
  }

  void _extractBlocksFromElement(
    dom.Element container,
    List<ArticleBlock> blocks,
    Uri baseUri, {
    String? articleTitle,
  }) {
    final String normalizedTitle = (articleTitle ?? '').trim().toLowerCase();

    for (final dom.Element child in container.children) {
      final String tag = child.localName?.toLowerCase() ?? '';
      if (_skippedTextTags.contains(tag)) continue;

      if (RegExp(r'^h[1-6]$').hasMatch(tag)) {
        final int level = int.tryParse(tag.substring(1)) ?? 1;
        final String text = _extractReadableText(child);
        if (text.length > 1) {
          // Skip leading H1 that merely duplicates the header article title.
          if (level == 1 &&
              blocks.isEmpty &&
              normalizedTitle.isNotEmpty &&
              text.toLowerCase() == normalizedTitle) {
            continue;
          }
          blocks.add(ArticleBlock(
            type: ArticleBlockType.heading,
            text: text,
            level: level,
          ));
        }
      } else if (tag == 'p') {
        // Extract any valid images embedded inside <p> (common on WordPress/Medium).
        for (final dom.Element media
            in child.querySelectorAll('picture, img')) {
          if (media.localName == 'img' &&
              media.parent?.localName == 'picture') {
            continue;
          }
          _tryAddImageBlock(media, blocks, baseUri);
        }
        final String text = _extractReadableText(child);
        if (text.length > 1) {
          blocks
              .add(ArticleBlock(type: ArticleBlockType.paragraph, text: text));
        }
      } else if (tag == 'blockquote') {
        final String text = _extractReadableText(child);
        if (text.isNotEmpty) {
          blocks
              .add(ArticleBlock(type: ArticleBlockType.blockquote, text: text));
        }
      } else if (tag == 'pre') {
        final dom.Element preClone = child.clone(true);
        for (final dom.Element btn in preClone.querySelectorAll(
          'button, .copy-button, .copy-code, [aria-label]',
        )) {
          final String btnTag = btn.localName?.toLowerCase() ?? '';
          final String classes = (btn.attributes['class'] ?? '').toLowerCase();
          final String aria =
              (btn.attributes['aria-label'] ?? '').toLowerCase();
          if (btnTag == 'button' ||
              classes.contains('copy') ||
              aria.contains('copy') ||
              aria.contains('kopyala')) {
            btn.remove();
          }
        }
        final String code = preClone.text.trim();
        if (code.isNotEmpty) {
          final String? lang = _detectCodeLanguage(preClone);
          blocks.add(ArticleBlock(
            type: ArticleBlockType.code,
            text: code,
            language: lang,
          ));
        }
      } else if (tag == 'ul' || tag == 'ol') {
        final List<dom.Element> directLis = child.children
            .where((dom.Element e) => e.localName?.toLowerCase() == 'li')
            .toList();
        final List<dom.Element> listNodes =
            directLis.isNotEmpty ? directLis : child.querySelectorAll('li');
        final List<String> items = listNodes
            .map(_extractReadableText)
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
      } else if (tag == 'table') {
        final List<String> rows = <String>[];
        for (final dom.Element tr in child.querySelectorAll('tr')) {
          final List<String> cells = tr
              .querySelectorAll('th, td')
              .map(_extractReadableText)
              .where((String c) => c.isNotEmpty)
              .toList();
          if (cells.isNotEmpty) {
            rows.add(cells.join(' · '));
          }
        }
        if (rows.isNotEmpty) {
          blocks.add(ArticleBlock(
            type: ArticleBlockType.list,
            text: '',
            listItems: rows,
          ));
        }
      } else if (tag == 'figure' || tag == 'picture' || tag == 'img') {
        final String? caption =
            _extractReadableTextOrNull(child.querySelector('figcaption'));
        _tryAddImageBlock(child, blocks, baseUri, caption: caption);
      } else if (child.children.isNotEmpty) {
        // Recurse into wrapping divs, sections, headers, etc.
        final bool hasBlockChild = child.children.any(
          (dom.Element c) =>
              _blockElementTags.contains(c.localName?.toLowerCase()),
        );
        if (!hasBlockChild) {
          final String text = _extractReadableText(child);
          if (text.length >= 25) {
            blocks.add(
              ArticleBlock(type: ArticleBlockType.paragraph, text: text),
            );
            continue;
          }
        }
        _extractBlocksFromElement(
          child,
          blocks,
          baseUri,
          articleTitle: articleTitle,
        );
      } else {
        // Leaf div/section with direct text (e.g. React/Notion style paragraphs).
        final String text = _extractReadableText(child);
        if (text.length >= 30) {
          blocks
              .add(ArticleBlock(type: ArticleBlockType.paragraph, text: text));
        }
      }
    }
  }

  void _tryAddImageBlock(
    dom.Element element,
    List<ArticleBlock> blocks,
    Uri baseUri, {
    String? caption,
  }) {
    final String? rawSrc = _resolveBestImageSrc(element);
    if (rawSrc == null || rawSrc.isEmpty) return;
    final String resolved = _resolveUrl(baseUri, rawSrc);
    if (!resolved.startsWith('http://') && !resolved.startsWith('https://')) {
      return;
    }
    // Avoid duplicate consecutive identical images.
    if (blocks.isNotEmpty &&
        blocks.last.type == ArticleBlockType.image &&
        blocks.last.imageUrl == resolved) {
      return;
    }
    blocks.add(ArticleBlock(
      type: ArticleBlockType.image,
      text: '',
      imageUrl: resolved,
      caption: caption,
    ));
  }

  String? _resolveBestImageSrc(dom.Element element) {
    final dom.Element? img = element.localName?.toLowerCase() == 'img'
        ? element
        : element.querySelector('img');

    // Skip obvious tracking pixels or tiny avatar/icon decorations.
    if (img != null) {
      final int? w = int.tryParse(img.attributes['width'] ?? '');
      final int? h = int.tryParse(img.attributes['height'] ?? '');
      if ((w != null && w <= 2) || (h != null && h <= 2)) {
        return null;
      }
    }

    // Priority 1: explicit lazy-load attributes (always preferred over src
    // because sites put SVG/GIF base64 placeholders in src!).
    final List<String?> candidates = <String?>[
      if (img != null) ...<String?>[
        img.attributes['data-src'],
        img.attributes['data-lazy-src'],
        img.attributes['data-original'],
        img.attributes['data-actualsrc'],
        img.attributes['data-hi-res-src'],
        _bestSrcFromSrcset(img.attributes['data-srcset']),
        _bestSrcFromSrcset(img.attributes['srcset']),
      ],
      for (final dom.Element source
          in element.querySelectorAll('source')) ...<String?>[
        _bestSrcFromSrcset(source.attributes['data-srcset']),
        _bestSrcFromSrcset(source.attributes['srcset']),
      ],
      if (img != null) img.attributes['src'],
    ];

    for (final String? candidate in candidates) {
      final String? cleaned = _validImageCandidate(candidate);
      if (cleaned != null) return cleaned;
    }
    return null;
  }

  static String? _validImageCandidate(String? raw) {
    if (raw == null) return null;
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final String lower = trimmed.toLowerCase();
    if (lower.startsWith('data:') ||
        lower.startsWith('javascript:') ||
        lower == 'about:blank' ||
        lower.contains('spacer.gif') ||
        lower.contains('pixel.gif') ||
        lower.contains('1x1.')) {
      return null;
    }
    return trimmed;
  }

  static String? _bestSrcFromSrcset(String? srcset) {
    if (srcset == null || srcset.trim().isEmpty) return null;
    String? bestUrl;
    double bestWeight = -1;
    for (final String entry in srcset.split(',')) {
      final List<String> parts = entry
          .trim()
          .split(RegExp(r'\s+'))
          .where((String s) => s.isNotEmpty)
          .toList();
      if (parts.isEmpty) continue;
      final String? candidate = _validImageCandidate(parts.first);
      if (candidate == null) continue;
      double weight = 1;
      if (parts.length > 1) {
        final String descriptor = parts[1].toLowerCase();
        if (descriptor.endsWith('w')) {
          weight =
              double.tryParse(descriptor.substring(0, descriptor.length - 1)) ??
                  1;
        } else if (descriptor.endsWith('x')) {
          weight = (double.tryParse(
                      descriptor.substring(0, descriptor.length - 1)) ??
                  1) *
              1000;
        }
      }
      if (weight > bestWeight) {
        bestWeight = weight;
        bestUrl = candidate;
      }
    }
    return bestUrl;
  }

  static String? _detectCodeLanguage(dom.Element pre) {
    final dom.Element? codeEl = pre.querySelector('code');
    final String classes =
        '${pre.attributes['class'] ?? ''} ${codeEl?.attributes['class'] ?? ''}';
    final Match? match =
        RegExp('(?:language|lang)-([a-zA-Z0-9_+-]+)').firstMatch(classes);
    return match?.group(1);
  }

  static bool _hasAncestorTag(dom.Element el, Set<String> tags) {
    dom.Element? current = el.parent;
    while (current != null) {
      if (tags.contains(current.localName?.toLowerCase())) return true;
      current = current.parent;
    }
    return false;
  }

  static String _directOwnText(dom.Element el) {
    final StringBuffer buffer = StringBuffer();
    for (final dom.Node node in el.nodes) {
      if (node is dom.Text) {
        buffer.write(node.text);
      }
    }
    return buffer.toString();
  }

  /// Extracts readable text from [node] while preserving single-space boundaries
  /// between adjacent sibling inline/block elements (e.g.
  /// `<h2><span>01</span><span>Title</span></h2>` -> `"01 Title"`).
  String _extractReadableText(dom.Node node) {
    final StringBuffer buf = StringBuffer();
    _appendReadableText(node, buf);
    return _cleanText(buf.toString());
  }

  String? _extractReadableTextOrNull(dom.Node? node) {
    if (node == null) return null;
    final String text = _extractReadableText(node);
    return text.isEmpty ? null : text;
  }

  void _appendReadableText(dom.Node node, StringBuffer buf) {
    if (node is dom.Text) {
      _writeTextPiece(buf, node.text);
      return;
    }
    if (node is! dom.Element) return;
    final String tag = node.localName?.toLowerCase() ?? '';
    if (_skippedTextTags.contains(tag)) return;
    if (tag == 'br') {
      if (buf.isNotEmpty && !buf.toString().endsWith(' ')) {
        buf.write(' ');
      }
      return;
    }
    for (final dom.Node child in node.nodes) {
      _appendReadableText(child, buf);
    }
  }

  static final RegExp _noLeadingSpaceRegex = RegExp(r'''^[,.;:!?)\]}'"”’%]''');
  static final RegExp _noTrailingSpaceRegex = RegExp(r'''[(\[{"“‘/\-—]$''');

  static void _writeTextPiece(StringBuffer buf, String raw) {
    if (raw.isEmpty) return;
    if (buf.isNotEmpty) {
      final String existing = buf.toString();
      final bool endsWithSpace = RegExp(r'\s$').hasMatch(existing);
      final bool startsWithSpace = RegExp(r'^\s').hasMatch(raw);
      if (!endsWithSpace &&
          !startsWithSpace &&
          !_noLeadingSpaceRegex.hasMatch(raw) &&
          !_noTrailingSpaceRegex.hasMatch(existing)) {
        buf.write(' ');
      }
    }
    buf.write(raw);
  }

  List<ArticleBlock> _blocksFromJsonLdBody(String body, Uri baseUri) {
    final List<ArticleBlock> blocks = <ArticleBlock>[];
    if (body.contains('<p') || body.contains('<div') || body.contains('<br')) {
      final dom.DocumentFragment frag = html_parser.parseFragment(body);
      final dom.Element wrapper = dom.Element.tag('div')
        ..nodes.addAll(frag.nodes.toList());
      _extractBlocksFromElement(wrapper, blocks, baseUri);
      if (blocks.isNotEmpty) return blocks;
    }
    final List<String> paragraphs = body.split(RegExp(r'\n+'));
    for (final String p in paragraphs) {
      final String clean = _cleanText(p);
      if (clean.length > 15) {
        blocks.add(ArticleBlock(type: ArticleBlockType.paragraph, text: clean));
      }
    }
    return blocks;
  }

  static int _countBlockWords(List<ArticleBlock> blocks) {
    return blocks.fold<int>(
      0,
      (int acc, ArticleBlock b) {
        if (b.type == ArticleBlockType.list) {
          return acc +
              b.listItems.fold<int>(
                0,
                (int s, String item) => s + _countStringWords(item),
              );
        }
        return acc + _countStringWords(b.text);
      },
    );
  }

  static int _countStringWords(String text) {
    return text.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length;
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
      final double adjusted = _scoreCandidateElement(el);
      final double effective = adjusted > 0 ? adjusted : score;
      if (effective > maxScore) {
        maxScore = effective;
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
            caption: '${i + 1}/${galleryImages.length}',
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
            text: topCommentsHeadingMarker,
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
                  text: 'u/$cAuthor ($score pts):\n$cBody',
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

  Future<Directory> _resolveCacheDir() async {
    final Directory root = _cacheDirectoryProvider != null
        ? await _cacheDirectoryProvider()
        : await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${root.path}/reader_cache');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Future<ArticleContent?> _readFromCache(String key) async {
    try {
      final Directory dir = await _resolveCacheDir();
      final File cacheFile = File('${dir.path}/$key.json');
      if (cacheFile.existsSync()) {
        final String raw = await cacheFile.readAsString();
        final Map<String, dynamic> json =
            jsonDecode(raw) as Map<String, dynamic>;
        return ArticleContent.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveToCache(String key, ArticleContent content) async {
    try {
      final Directory dir = await _resolveCacheDir();
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
      final bool isArticleType = type == 'Article' ||
          type == 'NewsArticle' ||
          type == 'BlogPosting' ||
          type == 'TechArticle' ||
          (type is List &&
              type.any(
                (dynamic t) =>
                    t == 'Article' ||
                    t == 'NewsArticle' ||
                    t == 'BlogPosting' ||
                    t == 'TechArticle',
              ));
      if (isArticleType) {
        return json;
      }
      if (json['@graph'] != null) {
        return _findArticleInJsonLd(json['@graph']);
      }
    }
    return null;
  }

  String _cleanText(String input) {
    String decoded = input
        .replaceAll('&nbsp;', ' ')
        .replaceAll('\u00A0', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll('&hellip;', '…')
        .replaceAll('&rsquo;', '’')
        .replaceAll('&lsquo;', '‘')
        .replaceAll('&rdquo;', '”')
        .replaceAll('&ldquo;', '“');

    decoded = decoded.replaceAllMapped(
      RegExp('&#x([0-9a-fA-F]+);'),
      (Match m) {
        final int? code = int.tryParse(m.group(1)!, radix: 16);
        return code != null ? String.fromCharCode(code) : m.group(0)!;
      },
    );
    decoded = decoded.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (Match m) {
        final int? code = int.tryParse(m.group(1)!);
        return code != null ? String.fromCharCode(code) : m.group(0)!;
      },
    );

    return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _resolveUrl(Uri baseUri, String relative) {
    try {
      return baseUri.resolve(relative).toString();
    } catch (_) {
      return relative;
    }
  }
}
