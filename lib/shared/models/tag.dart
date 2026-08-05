import 'package:isar/isar.dart';

part 'tag.g.dart';

/// A tag that can be attached to bookmarks for organization and filtering.
@collection
class Tag {
  Tag({
    required this.name,
    required this.slug,
    this.color,
    this.icon,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.usageCount = 0,
    this.isSystemTag = false,
    this.isSmartTag = false,
    this.ruleJson,
    this.orderIndex = 0,
  });

  /// Auto-increment primary key.
  Id id = Isar.autoIncrement;

  /// Display name of the tag.
  String name;

  /// URL-safe unique slug for the tag (e.g. 'flutter-tips').
  @Index(unique: true)
  String slug;

  /// Hex color code for tag visualization (e.g. '#FF5722').
  String? color;

  /// Icon identifier (e.g. Material Icons name).
  String? icon;

  /// Optional longer description of the tag.
  String? description;

  /// When the tag was created.
  DateTime createdAt;

  /// When the tag was last modified.
  DateTime updatedAt;

  /// How many bookmarks currently use this tag.
  int usageCount;

  /// Whether this is a built-in system tag that cannot be deleted.
  bool isSystemTag;

  /// Whether this is a smart tag with auto-assignment rules.
  bool isSmartTag;

  /// JSON-encoded rules for smart tag auto-assignment.
  String? ruleJson;

  /// Manual sort order index for custom tag ordering.
  int orderIndex;
}
