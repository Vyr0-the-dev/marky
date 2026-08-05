import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/features/tags/presentation/providers/tag_providers.dart';
import 'package:marky/shared/models/tag.dart';

void main() {
  group('tagMapProvider', () {
    late ProviderContainer container;

    Tag _makeTag(int id, String name) {
      final tag = Tag(
        name: name,
        slug: name.toLowerCase().replaceAll(' ', '-'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      tag.id = id;
      return tag;
    }

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('builds map keyed by tag id from tagListProvider data', () async {
      final tags = <Tag>[
        _makeTag(1, 'Flutter'),
        _makeTag(2, 'Dart'),
        _makeTag(3, 'Riverpod'),
      ];

      container = ProviderContainer(
        overrides: <Override>[
          tagRepositoryProvider.overrideWith(
            (ref) => _FakeTagRepository(initialTags: tags),
          ),
        ],
      );

      // Wait for tagListProvider to resolve
      await container.read(tagListProvider.future);

      final mapAsync = container.read(tagMapProvider);
      final map = mapAsync.valueOrNull;

      expect(map, isNotNull);
      expect(map!.length, 3);
      expect(map[1]!.name, 'Flutter');
      expect(map[2]!.name, 'Dart');
      expect(map[3]!.name, 'Riverpod');
    });

    test('returns loading when tagListProvider is loading', () {
      container = ProviderContainer(
        overrides: <Override>[
          tagRepositoryProvider.overrideWith(
            (ref) => _SlowTagRepository(),
          ),
        ],
      );

      // Trigger the future but don't await it
      container.read(tagListProvider.future);

      final mapAsync = container.read(tagMapProvider);
      expect(mapAsync.isLoading, isTrue);
    });

    test('returns error when tagListProvider errors', () async {
      container = ProviderContainer(
        overrides: <Override>[
          tagRepositoryProvider.overrideWith(
            (ref) => _FailingTagRepository(),
          ),
        ],
      );

      // Trigger and await the future (will throw)
      try {
        await container.read(tagListProvider.future);
        fail('Expected error');
      } catch (_) {}

      final mapAsync = container.read(tagMapProvider);
      expect(mapAsync.hasError, isTrue);
    });

    test('empty list yields empty map', () async {
      container = ProviderContainer(
        overrides: <Override>[
          tagRepositoryProvider.overrideWith(
            (ref) => _FakeTagRepository(initialTags: <Tag>[]),
          ),
        ],
      );

      await container.read(tagListProvider.future);

      final mapAsync = container.read(tagMapProvider);
      final map = mapAsync.valueOrNull;

      expect(map, isNotNull);
      expect(map, isEmpty);
    });

    test('O(1) lookup — map access by id returns correct tag', () async {
      final tags = <Tag>[
        _makeTag(42, 'Performance'),
      ];

      container = ProviderContainer(
        overrides: <Override>[
          tagRepositoryProvider.overrideWith(
            (ref) => _FakeTagRepository(initialTags: tags),
          ),
        ],
      );

      await container.read(tagListProvider.future);

      final mapAsync = container.read(tagMapProvider);
      final map = mapAsync.valueOrNull!;

      // Direct key lookup (O(1)) instead of linear scan
      expect(map.containsKey(42), isTrue);
      expect(map[42]!.name, 'Performance');
      expect(map.containsKey(99), isFalse);
    });

    test('map does not rebuild on unrelated tag list mutation', () async {
      final repo = _FakeTagRepository(
        initialTags: <Tag>[_makeTag(1, 'Original')],
      );

      container = ProviderContainer(
        overrides: <Override>[
          tagRepositoryProvider.overrideWith((ref) => repo),
        ],
      );

      await container.read(tagListProvider.future);

      final before = container.read(tagMapProvider);
      expect(before.valueOrNull![1]!.name, 'Original');

      // Mutate the underlying repo data
      repo.tags = <Tag>[_makeTag(1, 'Renamed')];

      // Re-read — the provider should still return cached old value
      // because tagListProvider is a FutureProvider that caches its result
      final after = container.read(tagMapProvider);
      expect(after.valueOrNull![1]!.name, 'Original');
    });
  });
}

// ─── Fake implementations ─────────────────────────────────────────────────

class _FakeTagRepository implements TagRepository {
  _FakeTagRepository({required List<Tag> initialTags}) : tags = initialTags;

  List<Tag> tags;

  @override
  Future<List<Tag>> getAll() async => tags;

  @override
  Future<Tag?> getById(Id id) async {
    try {
      return tags.firstWhere((t) => t.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<Tag?> getBySlug(String slug) async {
    try {
      return tags.firstWhere((t) => t.slug == slug);
    } on StateError {
      return null;
    }
  }

  @override
  Future<Tag> create(String name, {String? color, String? icon}) =>
      throw UnimplementedError();

  @override
  Future<Id> update(Tag tag) => throw UnimplementedError();

  @override
  Future<void> delete(Id id) => throw UnimplementedError();

  @override
  Future<void> clear() => throw UnimplementedError();

  @override
  Future<Id> insert(Tag entity) => throw UnimplementedError();

  @override
  Future<List<Tag>> getByBookmarkId(int bookmarkId) =>
      throw UnimplementedError();

  @override
  Future<void> assignTagToBookmark(int tagId, int bookmarkId) =>
      throw UnimplementedError();

  @override
  Future<void> removeTagFromBookmark(int tagId, int bookmarkId) =>
      throw UnimplementedError();
}

class _SlowTagRepository implements TagRepository {
  @override
  Future<List<Tag>> getAll() async {
    await Future<void>.delayed(const Duration(seconds: 10));
    return <Tag>[];
  }

  @override
  Future<Tag?> getById(Id id) => throw UnimplementedError();

  @override
  Future<Tag?> getBySlug(String slug) => throw UnimplementedError();

  @override
  Future<Tag> create(String name, {String? color, String? icon}) =>
      throw UnimplementedError();

  @override
  Future<Id> update(Tag tag) => throw UnimplementedError();

  @override
  Future<void> delete(Id id) => throw UnimplementedError();

  @override
  Future<void> clear() => throw UnimplementedError();

  @override
  Future<Id> insert(Tag entity) => throw UnimplementedError();

  @override
  Future<List<Tag>> getByBookmarkId(int bookmarkId) =>
      throw UnimplementedError();

  @override
  Future<void> assignTagToBookmark(int tagId, int bookmarkId) =>
      throw UnimplementedError();

  @override
  Future<void> removeTagFromBookmark(int tagId, int bookmarkId) =>
      throw UnimplementedError();
}

class _FailingTagRepository implements TagRepository {
  @override
  Future<List<Tag>> getAll() async => throw Exception('Database error');

  @override
  Future<Tag?> getById(Id id) => throw UnimplementedError();

  @override
  Future<Tag?> getBySlug(String slug) => throw UnimplementedError();

  @override
  Future<Tag> create(String name, {String? color, String? icon}) =>
      throw UnimplementedError();

  @override
  Future<Id> update(Tag tag) => throw UnimplementedError();

  @override
  Future<void> delete(Id id) => throw UnimplementedError();

  @override
  Future<void> clear() => throw UnimplementedError();

  @override
  Future<Id> insert(Tag entity) => throw UnimplementedError();

  @override
  Future<List<Tag>> getByBookmarkId(int bookmarkId) =>
      throw UnimplementedError();

  @override
  Future<void> assignTagToBookmark(int tagId, int bookmarkId) =>
      throw UnimplementedError();

  @override
  Future<void> removeTagFromBookmark(int tagId, int bookmarkId) =>
      throw UnimplementedError();
}
