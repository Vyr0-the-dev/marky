/// Per-collection default sort order for the bookmarks inside it.
///
/// The feed screen has its own global sort picker (Faz 5), but
/// collections can override that default so "Research Papers" can
/// stay alphabetical while "Videos to Watch" stays newest-first.
enum CollectionSortMode {
  newestFirst,
  oldestFirst,
  recentlyOpened,
  titleAscending,
  manual,
}
