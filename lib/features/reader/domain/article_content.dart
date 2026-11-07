import 'package:flutter/foundation.dart';

enum ArticleBlockType {
  paragraph,
  heading,
  blockquote,
  code,
  list,
  image,
}

@immutable
class ArticleBlock {
  const ArticleBlock({
    required this.type,
    required this.text,
    this.level = 1,
    this.imageUrl,
    this.caption,
    this.isOrdered = false,
    this.listItems = const <String>[],
    this.language,
  });

  factory ArticleBlock.fromJson(Map<String, dynamic> json) {
    return ArticleBlock(
      type: ArticleBlockType.values.firstWhere(
        (ArticleBlockType t) => t.name == json['type'],
        orElse: () => ArticleBlockType.paragraph,
      ),
      text: json['text'] as String? ?? '',
      level: json['level'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String?,
      caption: json['caption'] as String?,
      isOrdered: json['isOrdered'] as bool? ?? false,
      listItems: (json['listItems'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      language: json['language'] as String?,
    );
  }

  final ArticleBlockType type;
  final String text;
  final int level;
  final String? imageUrl;
  final String? caption;
  final bool isOrdered;
  final List<String> listItems;
  final String? language;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'text': text,
        'level': level,
        'imageUrl': imageUrl,
        'caption': caption,
        'isOrdered': isOrdered,
        'listItems': listItems,
        'language': language,
      };
}

@immutable
class ArticleContent {
  const ArticleContent({
    required this.title,
    this.author,
    this.siteName,
    this.publishDate,
    this.heroImageUrl,
    required this.blocks,
    required this.readingTimeMinutes,
    this.isFallback = false,
    required this.cachedAt,
  });

  factory ArticleContent.fromJson(Map<String, dynamic> json) {
    return ArticleContent(
      title: json['title'] as String? ?? '',
      author: json['author'] as String?,
      siteName: json['siteName'] as String?,
      publishDate: json['publishDate'] != null
          ? DateTime.tryParse(json['publishDate'] as String)
          : null,
      heroImageUrl: json['heroImageUrl'] as String?,
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((dynamic b) =>
                  ArticleBlock.fromJson(b as Map<String, dynamic>))
              .toList() ??
          const <ArticleBlock>[],
      readingTimeMinutes: json['readingTimeMinutes'] as int? ?? 1,
      isFallback: json['isFallback'] as bool? ?? false,
      cachedAt: DateTime.tryParse(json['cachedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String title;
  final String? author;
  final String? siteName;
  final DateTime? publishDate;
  final String? heroImageUrl;
  final List<ArticleBlock> blocks;
  final int readingTimeMinutes;
  final bool isFallback;
  final DateTime cachedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'author': author,
        'siteName': siteName,
        'publishDate': publishDate?.toIso8601String(),
        'heroImageUrl': heroImageUrl,
        'blocks': blocks.map((ArticleBlock b) => b.toJson()).toList(),
        'readingTimeMinutes': readingTimeMinutes,
        'isFallback': isFallback,
        'cachedAt': cachedAt.toIso8601String(),
      };

  int get wordCount {
    int count = 0;
    for (final ArticleBlock block in blocks) {
      if (block.text.isNotEmpty) {
        count += block.text
            .split(RegExp(r'\s+'))
            .where((String w) => w.isNotEmpty)
            .length;
      }
      for (final String item in block.listItems) {
        count +=
            item.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length;
      }
    }
    return count;
  }
}
