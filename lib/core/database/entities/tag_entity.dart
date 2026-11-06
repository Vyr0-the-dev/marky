import 'package:isar/isar.dart';

part 'tag_entity.g.dart';

/// A user-authored label attached to any number of bookmarks.
///
/// Simpler than the legacy `Tag`: we dropped `isSystemTag`
/// (there are no built-in tags at MVP), `isSmartTag` + `ruleJson`
/// (AI-adjacent, excluded by design), and `color` as a hex string
/// in favour of a raw ARGB `int` — cheaper to compare, no parse
/// errors, and round-trips directly with Flutter's `Color`.
///
/// The `slug` stays unique because it's used as the URL-safe
/// identifier in backups and imports; if two tags collide on
/// slug, the second capture wins deterministically.
@Collection(accessor: 'tags')
class TagEntity {
  TagEntity({
    required this.name,
    required this.slug,
    this.colorArgb,
    this.icon,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.usageCount = 0,
    this.isPinned = false,
    this.orderIndex = 0,
  });

  Id id = Isar.autoIncrement;

  /// Display name exactly as the user typed it ("Machine Learning",
  /// "to-read", "日本語").
  String name;

  /// URL-safe unique slug derived from [name]. Used by:
  /// - Backup / import (so tags survive an export/re-import cycle
  ///   with ids intact).
  /// - Deep links (Faz 7 search / collection sharing).
  @Index(unique: true, caseSensitive: false)
  String slug;

  /// Tag colour as a full 32-bit ARGB integer (same format as
  /// Flutter's `Color.toARGB32()`). Null means "use the default
  /// Reading Room tint" — new tags default to null so the picker
  /// can nudge the user without forcing a choice.
  int? colorArgb;

  /// Material Icon name or custom icon key. Null renders as a simple
  /// circle dot using [colorArgb] in the chip / list.
  String? icon;

  /// Optional longer-form description shown in the tag editor.
  String? description;

  DateTime createdAt;
  DateTime updatedAt;

  /// Cached count of bookmarks referencing this tag. Kept in sync by
  /// the tag repository on attach/detach — cheaper than running a
  /// `bookmarks.where.tagIdsContains(id).count()` every time Library
  /// renders.
  int usageCount;

  /// User-pinned tags surface at the top of the Library tag list.
  /// Dropped the legacy `isSystemTag` concept — pinning replaces it.
  bool isPinned;

  /// Manual sort index for drag-reorder in the tag editor. Lower
  /// comes first; ties broken by name ASC.
  int orderIndex;
}
