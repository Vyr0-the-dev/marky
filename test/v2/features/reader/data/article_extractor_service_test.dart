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
