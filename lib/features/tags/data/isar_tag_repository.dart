import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/bookmark_entity.dart';
import 'package:marky/core/database/entities/tag_entity.dart';
import 'package:marky/features/tags/data/tag_mapper.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

/// Isar-backed [TagRepository].
///
/// Touchstones:
/// - **Slug uniqueness** is enforced by the Isar `@Index(unique:
///   true, caseSensitive: false)` on the entity. We surface a
///   typed [TagSlugConflictException] from `save` and
///   `createFromName` so callers can disambiguate "name is already
///   taken" from generic storage failures.
/// - **`createFromName`** appends a numeric suffix to dedupe
///   colliding slugs (`design`, `design-2`, `design-3`...). Bounded
///   to 100 attempts; throws if it can't find a free slot.
/// - **Usage counts** are maintained inline by `increment` /
///   `decrement` on the hot path, with a `recompute` escape hatch.
class IsarTagRepository implements TagRepository {
  IsarTagRepository(this._isar);

  final Isar _isar;

  @override
  Future<Tag> save(Tag tag) async {
    final Tag stamped = tag.copyWith(updatedAt: DateTime.now());
    final TagEntity entity = TagMapper.toEntity(stamped);

    final int id = await _isar.writeTxn<int>(() async {
      try {
        return await _isar.tags.put(entity);
      } on IsarError catch (e) {
        if (_isUniqueViolation(e)) {
          throw TagSlugConflictException(stamped.slug);
        }
        rethrow;
      }
    });
    return stamped.copyWith(id: id);
  }

  @override
  Future<Tag> createFromName(
    String name, {
    int? colorArgb,
    String? icon,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Tag name must not be blank');
    }

    final String baseSlug = Tag.slugify(trimmed);
    final DateTime now = DateTime.now();

    // Try the base slug first; on collision append `-2`, `-3`, ...
    // up to 100 attempts. Bounded so we never spin forever.
    for (int attempt = 0; attempt < 100; attempt++) {
      final String candidate =
          attempt == 0 ? baseSlug : '$baseSlug-${attempt + 1}';
      try {
        final Tag tag = Tag(
          name: trimmed,
          slug: candidate,
          colorArgb: colorArgb,
          icon: icon,
          createdAt: now,
          updatedAt: now,
        );
        return await save(tag);
      } on TagSlugConflictException {
        // try next suffix
      }
    }
    throw StateError(
      'Could not allocate a unique slug for "$name" after 100 attempts.',
    );
  }

  @override
  Future<Tag?> getById(int id) async {
    final TagEntity? e = await _isar.tags.get(id);
    return e == null ? null : TagMapper.toDomain(e);
  }

  @override
  Future<Tag?> findBySlug(String slug) async {
    final TagEntity? e = await _isar.tags.where().slugEqualTo(slug).findFirst();
    return e == null ? null : TagMapper.toDomain(e);
  }

  @override
  Future<List<Tag>> getAll() async {
    final List<TagEntity> rows = await _isar.tags
        .where()
        .sortByIsPinnedDesc()
        .thenByOrderIndex()
        .thenByName()
        .findAll();
    return rows.map(TagMapper.toDomain).toList(growable: false);
  }

  @override
  Future<List<Tag>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return const <Tag>[];
    final List<TagEntity?> rows = await _isar.tags.getAll(ids);
    return rows
        .whereType<TagEntity>()
        .map(TagMapper.toDomain)
        .toList(growable: false);
  }

  @override
  Future<bool> delete(int id) {
    return _isar.writeTxn<bool>(() async => _isar.tags.delete(id));
  }

  // ─── Usage-count maintenance ────────────────────────────────────

  @override
  Future<void> incrementUsageCount(int tagId) async {
    await _isar.writeTxn<void>(() async {
      final TagEntity? e = await _isar.tags.get(tagId);
      if (e == null) return;
      e.usageCount += 1;
      e.updatedAt = DateTime.now();
      await _isar.tags.put(e);
    });
  }

  @override
  Future<void> decrementUsageCount(int tagId) async {
    await _isar.writeTxn<void>(() async {
      final TagEntity? e = await _isar.tags.get(tagId);
      if (e == null || e.usageCount <= 0) return;
      e.usageCount -= 1;
      e.updatedAt = DateTime.now();
      await _isar.tags.put(e);
    });
  }

  @override
  Future<int> recomputeUsageCount(int tagId) async {
    return _isar.writeTxn<int>(() async {
      final int actual =
          await _isar.bookmarks.filter().tagIdsElementEqualTo(tagId).count();
      final TagEntity? e = await _isar.tags.get(tagId);
      if (e != null && e.usageCount != actual) {
        e.usageCount = actual;
        e.updatedAt = DateTime.now();
        await _isar.tags.put(e);
      }
      return actual;
    });
  }

  @override
  Future<Map<int, int>> recomputeAllUsageCounts() async {
    return _isar.writeTxn<Map<int, int>>(() async {
      final List<TagEntity> tags = await _isar.tags.where().findAll();
      final Map<int, int> result = <int, int>{};
      final DateTime now = DateTime.now();
      final List<TagEntity> dirty = <TagEntity>[];

      for (final TagEntity tag in tags) {
        final int actual =
            await _isar.bookmarks.filter().tagIdsElementEqualTo(tag.id).count();
        result[tag.id] = actual;
        if (tag.usageCount != actual) {
          tag.usageCount = actual;
          tag.updatedAt = now;
          dirty.add(tag);
        }
      }
      if (dirty.isNotEmpty) {
        await _isar.tags.putAll(dirty);
      }
      return result;
    });
  }

  // ─── Streams ────────────────────────────────────────────────────

  @override
  Stream<List<Tag>> watchAll() {
    final Query<TagEntity> q = _isar.tags
        .where()
        .sortByIsPinnedDesc()
        .thenByOrderIndex()
        .thenByName()
        .build();
    return q.watch(fireImmediately: true).map(
          (List<TagEntity> rows) =>
              rows.map(TagMapper.toDomain).toList(growable: false),
        );
  }

  @override
  Stream<Tag?> watchById(int id) {
    return _isar.tags
        .watchObject(id, fireImmediately: true)
        .map((TagEntity? e) => e == null ? null : TagMapper.toDomain(e));
  }

  // ─── Helpers ────────────────────────────────────────────────────

  /// Isar 3.x reports unique-index violations as IsarError with a
  /// message containing "unique" — the lib doesn't expose a typed
  /// error code, so we string-match. Localised IsarError messages
  /// would break this; in practice Isar's errors are English-only.
  bool _isUniqueViolation(IsarError e) {
    final String lower = e.message.toLowerCase();
    return lower.contains('unique') || lower.contains('duplicate');
  }
}

/// Thrown when a save would violate the unique-slug constraint.
///
/// UI should surface a localised "name is already taken" toast and
/// keep the editor open so the user can rename without losing
/// other field edits.
class TagSlugConflictException implements Exception {
  const TagSlugConflictException(this.slug);
  final String slug;

  @override
  String toString() => 'TagSlugConflictException: slug "$slug" already exists';
}
