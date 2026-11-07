import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/search/domain/search_operator_query.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

class BookmarkSearchService {
  BookmarkSearchService({
    required BookmarkRepository bookmarkRepository,
    required TagRepository tagRepository,
    BookmarkCollectionRepository? collectionRepository,
    SearchOperatorParser parser = const SearchOperatorParser(),
  })  : _bookmarkRepository = bookmarkRepository,
        _tagRepository = tagRepository,
        _collectionRepository = collectionRepository,
        _parser = parser;

  final BookmarkRepository _bookmarkRepository;
  final TagRepository _tagRepository;
  final BookmarkCollectionRepository? _collectionRepository;
  final SearchOperatorParser _parser;

  Future<List<Bookmark>> search(String rawQuery, {int limit = 50}) async {
    final SearchOperatorQuery parsed = _parser.parse(rawQuery);
    if (!parsed.hasText && !parsed.hasOperators) return const <Bookmark>[];

    final int? tagId = await _resolveTagId(parsed.tagSlug);
    if (parsed.tagSlug != null && tagId == null) return const <Bookmark>[];

    final int? collectionId = await _resolveCollectionId(parsed.collectionSlug);
    if (parsed.collectionSlug != null && collectionId == null) {
      return const <Bookmark>[];
    }

    if (parsed.hasText) {
      final List<Bookmark> candidates = await _bookmarkRepository.search(
        parsed.text,
        limit: limit * 4,
      );
      return candidates
          .where((Bookmark bookmark) => parsed.matches(bookmark,
              tagId: tagId, collectionId: collectionId))
          .take(limit)
          .toList(growable: false);
    }

    return _bookmarkRepository.feed(parsed.toFeedQuery(
      tagId: tagId,
      collectionId: collectionId,
      limit: limit,
    ));
  }

  Future<int?> _resolveTagId(String? tagSlug) async {
    if (tagSlug == null) return null;
    final Tag? tag = await _tagRepository.findBySlug(tagSlug);
    return tag?.id;
  }

  Future<int?> _resolveCollectionId(String? collectionSlug) async {
    if (collectionSlug == null || _collectionRepository == null) return null;
    final BookmarkCollection? collection =
        await _collectionRepository.findBySlug(collectionSlug);
    return collection?.id;
  }
}
