import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/reader/data/article_extractor_service.dart';
import 'package:marky/features/reader/domain/article_content.dart';

final Provider<ArticleExtractorService> articleExtractorServiceProvider =
    Provider<ArticleExtractorService>((Ref ref) {
  return ArticleExtractorService();
});

class ReaderArticleNotifier
    extends AutoDisposeFamilyAsyncNotifier<ArticleContent, Bookmark> {
  @override
  Future<ArticleContent> build(Bookmark arg) async {
    final ArticleExtractorService service =
        ref.watch(articleExtractorServiceProvider);
    return service.fetchArticle(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<ArticleContent>();
    state = await AsyncValue.guard(() async {
      final ArticleExtractorService service =
          ref.read(articleExtractorServiceProvider);
      return service.fetchArticle(arg, forceRefresh: true);
    });
  }
}

final AutoDisposeAsyncNotifierProviderFamily<ReaderArticleNotifier,
        ArticleContent, Bookmark> readerArticleProvider =
    AsyncNotifierProvider.autoDispose
        .family<ReaderArticleNotifier, ArticleContent, Bookmark>(
  ReaderArticleNotifier.new,
);
