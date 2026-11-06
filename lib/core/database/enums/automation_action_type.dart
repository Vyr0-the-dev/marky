/// What a rule does when its trigger fires.
///
/// Actions are stored as parallel lists on [AutomationRuleEntity]:
/// `actionTypes[i]` is paired with `actionArgs[i]`. The `arg` format
/// is per-type (tag/collection id for `addTag`/`addToCollection`, the
/// string `"true"` / `"false"` for booleans). This keeps the schema
/// scalar and avoids a separate `Action` collection at MVP scale.
enum AutomationActionType {
  /// Attach tag with id = int.parse(arg) to the captured bookmark.
  addTag,

  /// Add bookmark to collection with id = int.parse(arg).
  addToCollection,

  /// Set [BookmarkEntity.isFavorite] to `arg == 'true'`.
  setFavorite,

  /// Set [BookmarkEntity.isArchived] to `arg == 'true'` — auto-
  /// archive the bookmark on capture (useful for "read later" flow).
  setArchived,

  /// Set [BookmarkEntity.isPinned] to `arg == 'true'`.
  setPinned,
  addReminder,
}
