import 'package:flutter/foundation.dart';

/// Immutable domain model for a user-authored tag.
///
/// Counterpart to [TagEntity]; the repository's mapper is the only
/// place both halves co-exist (same boundary discipline as
/// [Bookmark]).
@immutable
class Tag {
  const Tag({
    this.id,
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

  /// `null` until persisted.
  final int? id;

  final String name;

  /// URL-safe lowercased slug. Always derived from [name] via
  /// [Tag.slugify] when callers don't supply one.
  final String slug;

  /// 32-bit ARGB int (Flutter's `Color.toARGB32()`). Null = use the
  /// Reading Room default tint.
  final int? colorArgb;

  final String? icon;
  final String? description;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Cached count of bookmarks referencing this tag. Maintained by
  /// [TagRepository.incrementUsageCount] / `decrementUsageCount`,
  /// authoritatively re-derived by `recomputeUsageCount`.
  final int usageCount;

  final bool isPinned;
  final int orderIndex;

  Tag copyWith({
    int? id,
    String? name,
    String? slug,
    int? colorArgb,
    String? icon,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? usageCount,
    bool? isPinned,
    int? orderIndex,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      colorArgb: colorArgb ?? this.colorArgb,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
      isPinned: isPinned ?? this.isPinned,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag &&
        other.id == id &&
        other.name == name &&
        other.slug == slug &&
        other.colorArgb == colorArgb &&
        other.icon == icon &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.usageCount == usageCount &&
        other.isPinned == isPinned &&
        other.orderIndex == orderIndex;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        slug,
        colorArgb,
        icon,
        description,
        createdAt,
        updatedAt,
        usageCount,
        isPinned,
        orderIndex,
      );

  @override
  String toString() =>
      'Tag(id: $id, name: $name, slug: $slug, usageCount: $usageCount)';

  /// Derives a URL-safe slug from a free-form name.
  ///
  /// - Lowercases.
  /// - Replaces any non-`[a-z0-9]` run with `-`.
  /// - Strips leading/trailing dashes.
  /// - Falls back to `'tag'` if nothing alphanumeric remains
  ///   (caller will likely append a numeric suffix to dedupe).
  ///
  /// Note: this intentionally does **not** transliterate non-Latin
  /// scripts. Turkish ı/ğ/ü etc. are dropped to dashes — Marky's
  /// users get a deterministic slug regardless of script, and the
  /// display name preserves the original characters anyway.
  static String slugify(String input) {
    final String lowered = input.toLowerCase();
    final String swept = lowered.replaceAll(RegExp('[^a-z0-9]+'), '-');
    final String trimmed = swept.replaceAll(RegExp(r'^-+|-+$'), '');
    return trimmed.isEmpty ? 'tag' : trimmed;
  }
}
