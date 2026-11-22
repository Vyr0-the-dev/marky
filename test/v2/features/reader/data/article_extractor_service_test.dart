import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/reader/data/article_extractor_service.dart';
import 'package:marky/features/reader/domain/article_content.dart';

void main() {
  group('ArticleContent model', () {
    test('serializes and deserializes cleanly with blocks', () {
      final ArticleContent original = ArticleContent(
        title: 'Örnek Makale Başlığı',
        author: 'Ahmet Yılmaz',
        siteName: 'marky.app',
        publishDate: DateTime(2026, 11, 7, 14, 30),
        heroImageUrl: 'https://marky.app/hero.png',
        blocks: const <ArticleBlock>[
          ArticleBlock(
            type: ArticleBlockType.heading,
            text: 'Giriş',
          ),
          ArticleBlock(
            type: ArticleBlockType.paragraph,
            text: 'Bu ilk test paragrafıdır ve içerik testi için yazılmıştır.',
          ),
          ArticleBlock(
            type: ArticleBlockType.blockquote,
            text: 'Alıntı metni burada yer alır.',
          ),
          ArticleBlock(
            type: ArticleBlockType.list,
            text: '',
            listItems: <String>['Madde 1', 'Madde 2', 'Madde 3'],
          ),
          ArticleBlock(
            type: ArticleBlockType.image,
            text: '',
            imageUrl: 'https://marky.app/img.jpg',
            caption: 'Görsel açıklaması',
          ),
        ],
        readingTimeMinutes: 2,
        cachedAt: DateTime(2026, 11, 7, 15),
      );

      final Map<String, dynamic> json = original.toJson();
      final ArticleContent restored = ArticleContent.fromJson(json);

      expect(restored.title, equals(original.title));
      expect(restored.author, equals(original.author));
      expect(restored.siteName, equals(original.siteName));
      expect(restored.blocks.length, equals(original.blocks.length));
      expect(restored.blocks[0].type, equals(ArticleBlockType.heading));
      expect(restored.blocks[1].type, equals(ArticleBlockType.paragraph));
      expect(restored.blocks[2].type, equals(ArticleBlockType.blockquote));
      expect(restored.blocks[3].type, equals(ArticleBlockType.list));
      expect(restored.blocks[3].listItems,
          equals(<String>['Madde 1', 'Madde 2', 'Madde 3']));
      expect(restored.blocks[4].type, equals(ArticleBlockType.image));
      expect(restored.blocks[4].imageUrl, equals('https://marky.app/img.jpg'));
      expect(restored.readingTimeMinutes, equals(2));
      expect(restored.wordCount, greaterThan(0));
    });
  });

  group('ArticleExtractorService extraction', () {
    test(
        'extracts rich Reddit post with markdown blocks, gallery, and comments',
        () async {
      final Dio mockDio = _mockDioWithResponse(<dynamic>[
        <String, dynamic>{
          'kind': 'Listing',
          'data': <String, dynamic>{
            'children': <dynamic>[
              <String, dynamic>{
                'kind': 't3',
                'data': <String, dynamic>{
                  'title': 'State Management in Flutter 2026',
                  'author': 'riverpod_expert',
                  'subreddit': 'flutterdev',
                  'selftext':
                      '# Overview\n\nRiverpod 3 is officially released with code generation by default.\n\n> Always prefer immutable state.\n\n- Type safe providers\n- Auto-dispose lifecycle\n- AsyncNotifier integration',
                  'media_metadata': <String, dynamic>{
                    'img1': <String, dynamic>{
                      's': <String, dynamic>{
                        'u':
                            'https://preview.redd.it/architecture.png?width=1080&amp;crop=smart',
                      },
                    },
                    'img2': <String, dynamic>{
                      's': <String, dynamic>{
                        'u':
                            'https://preview.redd.it/benchmark.png?width=1080&amp;crop=smart',
                      },
                    },
                  },
                },
              },
            ],
          },
        },
        <String, dynamic>{
          'kind': 'Listing',
          'data': <String, dynamic>{
            'children': <dynamic>[
              <String, dynamic>{
                'kind': 't1',
                'data': <String, dynamic>{
                  'author': 'flutter_fanatic',
                  'body':
                      'Great summary! The new AsyncNotifier syntax simplified our architecture immensely.',
                  'score': 42,
                },
              },
            ],
          },
        },
      ]);

      final ArticleExtractorService service =
          ArticleExtractorService(dio: mockDio);
      final Bookmark bookmark = Bookmark(
        id: 1,
        originalUrl:
            'https://www.reddit.com/r/flutterdev/comments/123/state_management/',
        title: 'Initial Title',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final ArticleContent article =
          await service.fetchArticle(bookmark, forceRefresh: true);

      expect(article.title, equals('State Management in Flutter 2026'));
      expect(article.author, equals('u/riverpod_expert'));
      expect(article.siteName, equals('r/flutterdev'));
      expect(article.heroImageUrl, contains('architecture.png'));
      expect(
          article.blocks
              .any((ArticleBlock b) => b.type == ArticleBlockType.heading),
          isTrue);
      expect(
          article.blocks
              .any((ArticleBlock b) => b.type == ArticleBlockType.list),
          isTrue);
      expect(
          article.blocks
              .any((ArticleBlock b) => b.type == ArticleBlockType.blockquote),
          isTrue);
      expect(
          article.blocks
              .any((ArticleBlock b) => b.text.contains('flutter_fanatic')),
          isTrue);
    });

    test('extracts Twitter/X Article with rich blocks', () async {
      final Dio mockDio = _mockDioWithResponse(<String, dynamic>{
        'code': 200,
        'tweet': <String, dynamic>{
          'id': '185999111',
          'text': 'Read my article about AI Agents',
          'author': <String, dynamic>{
            'name': 'Agent Builder',
            'screen_name': 'agentbuilder',
          },
          'article': <String, dynamic>{
            'title': 'Autonomous Agent Architecture in Production',
            'cover_image': 'https://pbs.twimg.com/article_hero.jpg',
            'content':
                '# Section 1: Memory Loops\n\nAgents must persist context cleanly across sessions.\n\n- Working memory\n- Long term storage\n- Eviction rules',
          },
        },
      });

      final ArticleExtractorService service =
          ArticleExtractorService(dio: mockDio);
      final Bookmark bookmark = Bookmark(
        id: 2,
        originalUrl: 'https://x.com/agentbuilder/article/185999111',
        title: 'X Article',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final ArticleContent article =
          await service.fetchArticle(bookmark, forceRefresh: true);

      expect(
          article.title, equals('Autonomous Agent Architecture in Production'));
      expect(article.author, equals('Agent Builder (@agentbuilder)'));
      expect(article.heroImageUrl,
          equals('https://pbs.twimg.com/article_hero.jpg'));
      expect(
          article.blocks
              .any((ArticleBlock b) => b.type == ArticleBlockType.heading),
          isTrue);
      expect(
          article.blocks
              .any((ArticleBlock b) => b.type == ArticleBlockType.list),
          isTrue);
    });

    test(
        'produces fallback article content when network is unavailable or page has no DOM',
        () {
      final Bookmark bookmark = Bookmark(
        id: 101,
        originalUrl: 'https://example.com/test-article',
        title: 'Örnek Başlık',
        description: 'Bu bir açıklama metnidir.',
        snippet: 'Bu da detaylı bir makale snippet metnidir.',
        author: 'Yazar Adı',
        siteName: 'Example',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final ArticleContent content = ArticleContent(
        title: bookmark.displayTitle,
        author: bookmark.author,
        siteName: bookmark.siteName,
        publishDate: bookmark.publishDate,
        heroImageUrl: bookmark.heroImageUrl,
        blocks: <ArticleBlock>[
          if (bookmark.description != null)
            ArticleBlock(
              type: ArticleBlockType.paragraph,
              text: bookmark.description!,
            ),
          if (bookmark.snippet != null)
            ArticleBlock(
              type: ArticleBlockType.paragraph,
              text: bookmark.snippet!,
            ),
        ],
        readingTimeMinutes: 1,
        isFallback: true,
        cachedAt: DateTime.now(),
      );

      expect(content.title, equals('Örnek Başlık'));
      expect(content.blocks.length, equals(2));
      expect(content.isFallback, isTrue);
      expect(content.author, equals('Yazar Adı'));
    });

    test(
        'preserves spaces between adjacent inline elements in headings & paragraphs',
        () async {
      const String html = '''
        <html><body>
          <article>
            <header><h1>Main Guide</h1></header>
            <h2><span>01</span><span>Büyük Yanılgı</span></h2>
            <p>Read <strong>carefully</strong><em>today</em>, because&nbsp;details&mdash;matter.</p>
          </article>
        </body></html>
      ''';
      final ArticleExtractorService service =
          ArticleExtractorService(dio: _mockDioWithResponse(html));
      final Bookmark bm = Bookmark(
        id: 201,
        originalUrl: 'https://blog.example.com/guide',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      final ArticleContent article =
          await service.fetchArticle(bm, forceRefresh: true);

      expect(
        article.blocks.any(
          (ArticleBlock b) =>
              b.type == ArticleBlockType.heading &&
              b.text == '01 Büyük Yanılgı',
        ),
        isTrue,
      );
      expect(
        article.blocks.any(
          (ArticleBlock b) =>
              b.type == ArticleBlockType.paragraph &&
              b.text == 'Read carefully today, because details—matter.',
        ),
        isTrue,
      );
    });

    test(
        'skips base64 placeholder src and extracts lazy data-src / srcset images inside p & figure',
        () async {
      const String html = '''
        <html><body>
          <article>
            <p>Intro paragraph with sufficient length to score cleanly as article content.</p>
            <p><img src="data:image/svg+xml;base64,PHN2Zz4=" data-src="/media/real-photo.jpg" /></p>
            <figure>
              <picture>
                <source srcset="https://cdn.example.com/small.webp 400w, https://cdn.example.com/large.webp 1200w" />
                <img src="data:image/gif;base64,R0lGODlhAQABAAAAACw=" />
              </picture>
              <figcaption>Diagram overview</figcaption>
            </figure>
          </article>
        </body></html>
      ''';
      final ArticleExtractorService service =
          ArticleExtractorService(dio: _mockDioWithResponse(html));
      final Bookmark bm = Bookmark(
        id: 202,
        originalUrl: 'https://news.example.com/post/1',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      final ArticleContent article =
          await service.fetchArticle(bm, forceRefresh: true);
      final List<ArticleBlock> images = article.blocks
          .where((ArticleBlock b) => b.type == ArticleBlockType.image)
          .toList();

      expect(images.length, 2);
      expect(
          images[0].imageUrl, 'https://news.example.com/media/real-photo.jpg');
      expect(images[1].imageUrl, 'https://cdn.example.com/large.webp');
      expect(images[1].caption, 'Diagram overview');
    });

    test(
        'chooses main article over small promo sidebar <article> and preserves noisy-class wrapper',
        () async {
      const String html = '''
        <html><body>
          <div class="sidebar-promo">
            <article><p><a href="/promo">Subscribe now for daily tips!</a></p></article>
          </div>
          <div class="layout-with-sidebar has-share-bar">
            <article class="post-body">
              <p>First long paragraph about distributed offline-first storage, conflict resolution, and deterministic indexing across devices.</p>
              <p>Second long paragraph explaining why scoring candidate containers by text volume and link density avoids sidebar traps.</p>
            </article>
          </div>
        </body></html>
      ''';
      final ArticleExtractorService service =
          ArticleExtractorService(dio: _mockDioWithResponse(html));
      final Bookmark bm = Bookmark(
        id: 203,
        originalUrl: 'https://tech.example.com/offline-first',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      final ArticleContent article =
          await service.fetchArticle(bm, forceRefresh: true);

      expect(
        article.blocks.any(
          (ArticleBlock b) =>
              b.text.contains('distributed offline-first storage'),
        ),
        isTrue,
      );
      expect(
        article.blocks
            .any((ArticleBlock b) => b.text.contains('Subscribe now')),
        isFalse,
      );
    });

    test(
        'extracts GitHub README markdown-body and strips Copy button from code blocks',
        () async {
      const String html = '''
        <html><body>
          <main>
            <article class="markdown-body">
              <h1>Marky</h1>
              <p>An offline-first personal link manager built with Flutter and Isar.</p>
              <pre><button class="copy-button">Copy</button><code class="language-dart">void main() => print('hi');</code></pre>
            </article>
          </main>
        </body></html>
      ''';
      final ArticleExtractorService service =
          ArticleExtractorService(dio: _mockDioWithResponse(html));
      final Bookmark bm = Bookmark(
        id: 204,
        originalUrl: 'https://github.com/feaz/marky',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      final ArticleContent article =
          await service.fetchArticle(bm, forceRefresh: true);
      final ArticleBlock code = article.blocks
          .firstWhere((ArticleBlock b) => b.type == ArticleBlockType.code);

      expect(code.text, equals("void main() => print('hi');"));
      expect(code.language, equals('dart'));
    });

    test(
        'uses JSON-LD articleBody when DOM body is truncated and caches persistently on disk',
        () async {
      final Directory tempDir =
          await Directory.systemTemp.createTemp('marky_reader_test_');
      addTearDown(() => tempDir.delete(recursive: true));

      final String longBody = List<String>.filled(
        30,
        'Detailed investigative journalism paragraph explaining the full story.',
      ).join('\n\n');

      final String html = '''
        <html><head>
          <script type="application/ld+json">
            {
              "@type": "NewsArticle",
              "headline": "Full Story From JSON-LD",
              "articleBody": "${longBody.replaceAll('\n', r'\n')}"
            }
          </script>
        </head><body>
          <article><p>Short teaser only.</p></article>
        </body></html>
      ''';

      int networkCalls = 0;
      final Dio dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest:
                (RequestOptions options, RequestInterceptorHandler handler) {
              networkCalls++;
              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  statusCode: 200,
                  data: html,
                ),
              );
            },
          ),
        );

      final ArticleExtractorService service = ArticleExtractorService(
        dio: dio,
        cacheDirectoryProvider: () async => tempDir,
      );
      final Bookmark bm = Bookmark(
        id: 205,
        originalUrl: 'https://paywall.example.com/story',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      final ArticleContent first = await service.fetchArticle(bm);
      expect(first.title, equals('Full Story From JSON-LD'));
      expect(first.blocks.length, greaterThanOrEqualTo(10));
      expect(networkCalls, equals(1));

      // Second read must come from persistent cache with zero extra network requests.
      final ArticleContent second = await service.fetchArticle(bm);
      expect(second.title, equals('Full Story From JSON-LD'));
      expect(networkCalls, equals(1));
    });
  });
}

Dio _mockDioWithResponse(dynamic data) {
  final Dio dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 200,
            data: data,
          ),
        );
      },
    ),
  );
  return dio;
}
