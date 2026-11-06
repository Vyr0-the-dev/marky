import 'package:isar/isar.dart';

import 'package:marky/core/database/enums/collection_sort_mode.dart';

part 'collection_entity.g.dart';

/// A user-authored grouping of bookmarks — the "folder" concept.
///
/// Distinct from tags in two ways:
/// 1. A bookmark belongs to **at most a few** collections, but can
///    have **many** tags. Collections are about hierarchy / context
///    ("Research Papers", "Trip Planning"); tags are about themes.
/// 2. Collections carry a sort mode preference and a feature-rich
///    accent palette — they're surfaces in the UI, not just labels.
///
/// Trimmed from legacy `BookmarkCollection`:
/// - Cover image / cover mode / cover local path → forbidden by the
///   product brief (no collection cover images at MVP).
/// - `accentColor` as hex string → upgraded to `accentColorArgb`
///   `int`, same rationale as [TagEntity.colorArgb].
///
/// Smart-collection support **is** in scope per `build_order.md`
/// Faz 9.4 ("Smart Collections Baseline"): rule-based collections
/// that auto-materialise from a `BookmarkFeedQuery`-shaped rule.
/// Stored here as a flag + JSON blob to keep the schema flat —
/// rule evaluation happens in `SmartCollectionEvaluator`.
@Collection(accessor: 'collections')
class CollectionEntity {
  CollectionEntity({
    required this.title,
    required this.slug,
    this.description,
    this.icon,
    this.accentColorArgb,
    this.isPinned = false,
    this.isArchived = false,
    this.itemCount = 0,
    this.sortMode = CollectionSortMode.newestFirst,
    this.orderIndex = 0,
    this.isSmart = false,
    this.smartRuleJson,
    required this.createdAt,
    required this.updatedAt,
  });

  Id id = Isar.autoIncrement;

  String title;

  @Index(unique: true, caseSensitive: false)
  String slug;

  String? description;

  /// Material Icon name. Null shows the default
  /// `Icons.collections_bookmark_outlined` glyph.
  String? icon;

  /// Accent colour for the collection card and detail header. Same
  /// 32-bit ARGB packing as [TagEntity.colorArgb].
  int? accentColorArgb;

  /// User-pinned collections surface at the top of Library.
  bool isPinned;

  /// Hidden from Library / pickers when archived. Items remain in
  /// the collection — archiving the *collection* doesn't archive
  /// its bookmarks.
  bool isArchived;

  /// Cached count of bookmarks in this collection. Kept in sync by
  /// the collection repository on attach/detach (same pattern as
  /// [TagEntity.usageCount]).
  int itemCount;

  /// Default sort applied when the user opens this collection. Not
  /// the global feed sort (that's a separate setting in Faz 5).
  @Enumerated(EnumType.name)
  CollectionSortMode sortMode;

  /// Drag-reorder index, low to high.
  int orderIndex;

  /// Indexed so the library query can split smart vs. manual lists
  /// without a full scan once the user has many collections.
  @Index()
  bool isSmart;

  /// JSON-encoded `SmartCollectionRule` describing the auto-filter.
  /// `null` for manual collections; non-null only when [isSmart] is
  /// true. The repository never inspects this field — evaluation
  /// happens in `SmartCollectionEvaluator`.
  String? smartRuleJson;

  DateTime createdAt;
  DateTime updatedAt;
}
