import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/collection_entity.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';

abstract final class BookmarkCollectionMapper {
  static BookmarkCollection toDomain(CollectionEntity e) => BookmarkCollection(
        id: e.id == Isar.autoIncrement ? null : e.id,
        title: e.title,
        slug: e.slug,
        description: e.description,
        icon: e.icon,
        accentColorArgb: e.accentColorArgb,
        isPinned: e.isPinned,
        isArchived: e.isArchived,
        itemCount: e.itemCount,
        sortMode: e.sortMode,
        orderIndex: e.orderIndex,
        isSmart: e.isSmart,
        smartRuleJson: e.smartRuleJson,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  static CollectionEntity toEntity(BookmarkCollection c) {
    final CollectionEntity entity = CollectionEntity(
      title: c.title,
      slug: c.slug,
      description: c.description,
      icon: c.icon,
      accentColorArgb: c.accentColorArgb,
      isPinned: c.isPinned,
      isArchived: c.isArchived,
      itemCount: c.itemCount,
      sortMode: c.sortMode,
      orderIndex: c.orderIndex,
      isSmart: c.isSmart,
      smartRuleJson: c.smartRuleJson,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
    );
    if (c.id != null) entity.id = c.id!;
    return entity;
  }
}
