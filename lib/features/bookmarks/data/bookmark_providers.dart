import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/core/database/database_providers.dart';
import 'package:marky/features/bookmarks/data/isar_bookmark_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';

/// Riverpod-exposed [BookmarkRepository].
///
/// Wired to the live Isar via [markyIsarProvider]. Tests typically
/// override this provider directly with an in-memory or fake repo
/// instead of opening Isar — repository-level fakes keep widget
/// tests fast and deterministic.
final Provider<BookmarkRepository> bookmarkRepositoryProvider =
    Provider<BookmarkRepository>((Ref ref) {
  return IsarBookmarkRepository(ref.watch(markyIsarProvider));
});

/// Reactive feed for a given [BookmarkFeedQuery].
///
/// Auto-disposing because each filter combination is short-lived
/// (user toggles a chip, builds a new query) — keeping the stream
/// alive after the screen unmounts would leak Isar query handles.
final AutoDisposeStreamProviderFamily<List<Bookmark>, BookmarkFeedQuery>
    bookmarkFeedProvider =
    StreamProvider.autoDispose.family<List<Bookmark>, BookmarkFeedQuery>(
  (Ref ref, BookmarkFeedQuery query) {
    final BookmarkRepository repo = ref.watch(bookmarkRepositoryProvider);
    return repo.watchFeed(query);
  },
);

/// Reactive single-bookmark provider, parametrised by id. Used by
/// the detail screen so it can react to in-place edits and to
/// background-deletion events (the stream emits `null` after delete).
final AutoDisposeStreamProviderFamily<Bookmark?, int> bookmarkByIdProvider =
    StreamProvider.autoDispose.family<Bookmark?, int>((Ref ref, int id) {
  final BookmarkRepository repo = ref.watch(bookmarkRepositoryProvider);
  return repo.watchById(id);
});

/// One-shot total count of non-archived bookmarks. Powers the
/// app-bar counter in the Reading Room large-title shell.
final AutoDisposeFutureProvider<int> bookmarkCountProvider =
    FutureProvider.autoDispose<int>((Ref ref) async {
  final BookmarkRepository repo = ref.watch(bookmarkRepositoryProvider);
  return repo.countAll();
});
