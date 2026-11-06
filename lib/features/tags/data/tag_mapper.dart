import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/tag_entity.dart';
import 'package:marky/features/tags/domain/tag.dart';

abstract final class TagMapper {
  static Tag toDomain(TagEntity e) => Tag(
        id: e.id == Isar.autoIncrement ? null : e.id,
        name: e.name,
        slug: e.slug,
        colorArgb: e.colorArgb,
        icon: e.icon,
        description: e.description,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        usageCount: e.usageCount,
        isPinned: e.isPinned,
        orderIndex: e.orderIndex,
      );

  static TagEntity toEntity(Tag t) {
    final TagEntity entity = TagEntity(
      name: t.name,
      slug: t.slug,
      colorArgb: t.colorArgb,
      icon: t.icon,
      description: t.description,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
      usageCount: t.usageCount,
      isPinned: t.isPinned,
      orderIndex: t.orderIndex,
    );
    if (t.id != null) entity.id = t.id!;
    return entity;
  }
}
