import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';

abstract interface class SmartCollectionEvaluator {
  SmartCollectionRule? ruleFor(BookmarkCollection collection);
  BookmarkFeedQuery? queryFor(BookmarkCollection collection, {DateTime? now});
  bool matches(BookmarkCollection collection, Bookmark bookmark,
      {DateTime? now});
  List<Bookmark> filter(
    BookmarkCollection collection,
    Iterable<Bookmark> bookmarks, {
    DateTime? now,
  });
}

class DefaultSmartCollectionEvaluator implements SmartCollectionEvaluator {
  const DefaultSmartCollectionEvaluator();

  @override
  SmartCollectionRule? ruleFor(BookmarkCollection collection) {
    if (!collection.isSmart) return null;
    final String? json = collection.smartRuleJson;
    if (json == null || json.trim().isEmpty) return null;
    return SmartCollectionRule.decode(json);
  }

  @override
  BookmarkFeedQuery? queryFor(
    BookmarkCollection collection, {
    DateTime? now,
  }) {
    return ruleFor(collection)?.toFeedQuery(now: now);
  }

  @override
  bool matches(
    BookmarkCollection collection,
    Bookmark bookmark, {
    DateTime? now,
  }) {
    final SmartCollectionRule? rule = ruleFor(collection);
    if (rule == null) return false;
    return rule.matches(bookmark, now: now);
  }

  @override
  List<Bookmark> filter(
    BookmarkCollection collection,
    Iterable<Bookmark> bookmarks, {
    DateTime? now,
  }) {
    final SmartCollectionRule? rule = ruleFor(collection);
    if (rule == null) return const <Bookmark>[];
    return bookmarks
        .where((Bookmark bookmark) => rule.matches(bookmark, now: now))
        .toList(growable: false);
  }
}
