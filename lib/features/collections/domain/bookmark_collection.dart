import 'package:flutter/foundation.dart';

import 'package:marky/core/database/enums/collection_sort_mode.dart';

/// Immutable domain model for a bookmark collection (folder).
///
/// Named `BookmarkCollection` — not `Collection` — to avoid a name
/// clash with Isar's [Collection] annotation class. The Isar entity
/// is named `CollectionEntity` for the same reason; the asymmetry is
/// deliberate so feature code reads `BookmarkCollection` everywhere.
@immutable
class BookmarkCollection {
  const BookmarkCollection({
    this.id,
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

  final int? id;

  final String title;
  final String slug;
  final String? description;
  final String? icon;
  final int? accentColorArgb;

  final bool isPinned;
  final bool isArchived;

  /// Cached count of bookmarks. Maintained by the repository's
  /// increment/decrement/recompute methods.
  final int itemCount;

  final CollectionSortMode sortMode;
  final int orderIndex;

  final bool isSmart;
  final String? smartRuleJson;

  final DateTime createdAt;
  final DateTime updatedAt;

  BookmarkCollection copyWith({
    int? id,
    String? title,
    String? slug,
    String? description,
    String? icon,
    int? accentColorArgb,
    bool? isPinned,
    bool? isArchived,
    int? itemCount,
    CollectionSortMode? sortMode,
    int? orderIndex,
    bool? isSmart,
    String? smartRuleJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookmarkCollection(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      accentColorArgb: accentColorArgb ?? this.accentColorArgb,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      itemCount: itemCount ?? this.itemCount,
      sortMode: sortMode ?? this.sortMode,
      orderIndex: orderIndex ?? this.orderIndex,
      isSmart: isSmart ?? this.isSmart,
      smartRuleJson: smartRuleJson ?? this.smartRuleJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookmarkCollection &&
        other.id == id &&
        other.title == title &&
        other.slug == slug &&
        other.description == description &&
        other.icon == icon &&
        other.accentColorArgb == accentColorArgb &&
        other.isPinned == isPinned &&
        other.isArchived == isArchived &&
        other.itemCount == itemCount &&
        other.sortMode == sortMode &&
        other.orderIndex == orderIndex &&
        other.isSmart == isSmart &&
        other.smartRuleJson == smartRuleJson &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        slug,
        description,
        icon,
        accentColorArgb,
        isPinned,
        isArchived,
        itemCount,
        sortMode,
        orderIndex,
        isSmart,
        smartRuleJson,
        createdAt,
        updatedAt,
      );

  @override
  String toString() => 'BookmarkCollection(id: $id, title: $title, '
      'items: $itemCount, sort: $sortMode, smart: $isSmart)';

  /// Same slugify rules as [Tag.slugify]; collections share the
  /// concept and we want consistent URLs across both. Re-implemented
  /// (not extracted into a shared util) because the rule is two
  /// lines and the duplication keeps the domain modules
  /// independently swappable.
  static String slugify(String input) {
    final String swept = input
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return swept.isEmpty ? 'collection' : swept;
  }
}
