import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/services/duplicate_detection_service.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart';
import 'package:marky/features/capture/presentation/providers/capture_providers.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// In-memory fake implementation of [BookmarkItemRepository] for testing.
class FakeBookmarkItemRepository implements BookmarkItemRepository {
  final Map<int, BookmarkItem> _items = <int, BookmarkItem>{};
  int _nextId = 1;

  @override
  Future<BookmarkItem?> getById(Id id) async => _items[id];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => _items.values.toList();

  @override
  Future<Id> insert(BookmarkItem entity) async {
    final int id = _nextId++;
    entity.id = id;
    _items[id] = entity;
    return id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    _items[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _items.remove(id);
  }

  @override
  Future<void> clear() async {
    _items.clear();
    _nextId = 1;
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async {
    for (final BookmarkItem item in _items.values) {
      if (item.urlHash == urlHash) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async {
    for (final BookmarkItem item in _items.values) {
      if (item.canonicalUrl == canonicalUrl) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async {
    for (final BookmarkItem item in _items.values) {
      if (item.externalContentId == externalContentId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async {
    return _items.values
        .where((BookmarkItem item) => item.duplicateGroupId == groupId)
        .toList();
  }

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

void main() {
  group('CaptureFormNotifier', () {
    late FakeBookmarkItemRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeBookmarkItemRepository();
      DuplicateDetectionService.initialize(
        repository: fakeRepository,
        normalizationService: UrlNormalizationService.instance,
      );
      container = ProviderContainer(
        overrides: <Override>[
          bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      DuplicateDetectionService.reset();
    });

    test('initial state has empty url and null submission', () {
      final CaptureFormState state = container.read(captureFormProvider);

      expect(state.url, '');
      expect(state.submission, isA<AsyncData<SaveResult?>>());
      expect(state.submission.value, isNull);
    });

    test('setUrl updates the url in state', () {
      final CaptureFormNotifier notifier = container.read(captureFormProvider.notifier);

      notifier.setUrl('https://example.com');

      final CaptureFormState state = container.read(captureFormProvider);
      expect(state.url, 'https://example.com');
    });

    test('save() with valid URL emits success state and item is in fake repo',
        () async {
      final CaptureFormNotifier notifier = container.read(captureFormProvider.notifier);

      notifier.setUrl('https://example.com/article');
      await notifier.save();

      final CaptureFormState state = container.read(captureFormProvider);
      expect(state.submission, isA<AsyncData<SaveResult?>>());

      final SaveResult? result = state.submission.value;
      expect(result, isA<SaveSuccess>());

      final SaveSuccess success = result! as SaveSuccess;
      expect(success.bookmarkId, greaterThan(0));

      final BookmarkItem? saved = await fakeRepository.getById(success.bookmarkId);
      expect(saved, isNotNull);
      expect(saved!.originalUrl, 'https://example.com/article');
    });

    test('save() with duplicate URL emits duplicate state', () async {
      final CaptureFormNotifier notifier = container.read(captureFormProvider.notifier);

      // First save.
      notifier.setUrl('https://example.com/article');
      await notifier.save();

      final CaptureFormState firstState = container.read(captureFormProvider);
      expect(firstState.submission.value, isA<SaveSuccess>());

      // Second save with same URL.
      notifier.setUrl('https://example.com/article');
      await notifier.save();

      final CaptureFormState secondState = container.read(captureFormProvider);
      expect(secondState.submission.value, isA<SaveDuplicate>());
    });

    test('save() with empty URL emits invalid state', () async {
      final CaptureFormNotifier notifier = container.read(captureFormProvider.notifier);

      notifier.setUrl('');
      await notifier.save();

      final CaptureFormState state = container.read(captureFormProvider);
      expect(state.submission.value, isA<SaveInvalid>());
    });

    test('save() with whitespace-only URL emits invalid state', () async {
      final CaptureFormNotifier notifier = container.read(captureFormProvider.notifier);

      notifier.setUrl('   ');
      await notifier.save();

      final CaptureFormState state = container.read(captureFormProvider);
      expect(state.submission.value, isA<SaveInvalid>());
    });

    test('clear() resets state to initial', () async {
      final CaptureFormNotifier notifier = container.read(captureFormProvider.notifier);

      notifier.setUrl('https://example.com');
      await notifier.save();

      CaptureFormState state = container.read(captureFormProvider);
      expect(state.url, isNotEmpty);
      expect(state.submission.value, isA<SaveSuccess>());

      notifier.clear();

      state = container.read(captureFormProvider);
      expect(state.url, '');
      expect(state.submission.value, isNull);
    });
  });
}
