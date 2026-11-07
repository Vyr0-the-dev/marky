import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
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
      expect(restored.blocks[3].listItems, equals(<String>['Madde 1', 'Madde 2', 'Madde 3']));
      expect(restored.blocks[4].type, equals(ArticleBlockType.image));
      expect(restored.blocks[4].imageUrl, equals('https://marky.app/img.jpg'));
      expect(restored.readingTimeMinutes, equals(2));
      expect(restored.wordCount, greaterThan(0));
    });
  });

  group('ArticleExtractorService fallback', () {
    test('produces fallback article content when network is unavailable or page has no DOM', () {
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
