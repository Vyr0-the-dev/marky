import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/models/duplicate_check_result.dart';
import 'package:marky/features/capture/domain/models/save_bookmark_params.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/canonical_extraction_result.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/html_canonical_extractor.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/platform_canonical_extractor.dart';
import 'package:marky/features/capture/domain/services/canonical_url_service.dart';
import 'package:marky/features/capture/domain/services/duplicate_detection_service.dart';
import 'package:marky/features/capture/domain/services/redirect_resolver_service.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// In-memory fake implementation of [BookmarkItemRepository] for testing.
class _FakeBookmarkItemRepository implements BookmarkItemRepository {
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

/// Fake [RedirectResolverService] that returns a predetermined result.
class _FakeRedirectResolverService extends RedirectResolverService {
  _FakeRedirectResolverService({required this.resolveResult})
      : super(dio: Dio());

  final String? resolveResult;

  @override
  Future<String?> resolve(String? url) async => resolveResult;
}

/// Fake [CanonicalUrlService] that returns a predetermined result.
class _FakeCanonicalUrlService extends CanonicalUrlService {
  _FakeCanonicalUrlService({this.result})
      : super(
          platformExtractor: PlatformCanonicalExtractor.instance,
          htmlExtractor: HtmlCanonicalExtractor.instance,
        );

  final CanonicalExtractionResult? result;

  @override
  Future<CanonicalExtractionResult?> extract(String? url) async => result;
}

/// Spy [DuplicateDetectionService] that records calls and delegates
/// to a real instance for consistent behavior.
class _SpyDuplicateDetectionService implements DuplicateDetectionService {
  _SpyDuplicateDetectionService({
    required BookmarkItemRepository repository,
    required UrlNormalizationService normalizationService,
  }) : _delegate = DuplicateDetectionService(
          repository: repository,
          normalizationService: normalizationService,
        );

  final DuplicateDetectionService _delegate;

  final List<Map<String, dynamic>> calls = <Map<String, dynamic>>[];

  @override
  Future<DuplicateCheckResult> checkDuplicate({
    required String canonicalUrl,
    String? resolvedUrl,
    String? originalUrl,
    String? externalContentId,
  }) async {
    calls.add(<String, dynamic>{
      'canonicalUrl': canonicalUrl,
      'resolvedUrl': resolvedUrl,
      'originalUrl': originalUrl,
      'externalContentId': externalContentId,
    });
    return _delegate.checkDuplicate(
      canonicalUrl: canonicalUrl,
      resolvedUrl: resolvedUrl,
      originalUrl: originalUrl,
      externalContentId: externalContentId,
    );
  }
}

void main() {
  group('SaveBookmarkUseCase', () {
    late _FakeBookmarkItemRepository fakeRepository;
    late SaveBookmarkUseCase useCase;
    late UrlNormalizationService normalizationService;

    setUp(() {
      fakeRepository = _FakeBookmarkItemRepository();
      normalizationService = UrlNormalizationService.instance;
      DuplicateDetectionService.initialize(
        repository: fakeRepository,
        normalizationService: normalizationService,
      );
      useCase = SaveBookmarkUseCase(repository: fakeRepository);
    });

    tearDown(DuplicateDetectionService.reset);

    test('valid URL returns SaveSuccess and item is in repo', () async {
      const String rawUrl = 'https://example.com/article';

      final SaveResult result = await useCase.execute(rawUrl);

      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;
      expect(success.bookmarkId, greaterThan(0));

      final BookmarkItem? saved =
          await fakeRepository.getById(success.bookmarkId);
      expect(saved, isNotNull);
      expect(saved!.originalUrl, rawUrl);
      expect(saved.canonicalUrl, 'https://example.com/article');
      expect(saved.urlHash, isNotNull);
      expect(saved.sourceType, 'manual');
      expect(saved.createdAt, isNotNull);
      expect(saved.updatedAt, isNotNull);
    });

    test('duplicate URL returns SaveDuplicate', () async {
      const String rawUrl = 'https://example.com/article';

      // First save.
      final SaveResult first = await useCase.execute(rawUrl);
      expect(first, isA<SaveSuccess>());

      // Second save with same canonical URL.
      final SaveResult second = await useCase.execute(rawUrl);
      expect(second, isA<SaveDuplicate>());

      final SaveDuplicate duplicate = second as SaveDuplicate;
      expect(duplicate.existing.originalUrl, rawUrl);
    });

    test('duplicate detected even with different tracking params', () async {
      const String rawUrl1 =
          'https://example.com/article?utm_source=email';
      const String rawUrl2 =
          'https://example.com/article?utm_campaign=spring';

      // First save.
      final SaveResult first = await useCase.execute(rawUrl1);
      expect(first, isA<SaveSuccess>());

      // Second save — same canonical URL, different raw.
      final SaveResult second = await useCase.execute(rawUrl2);
      expect(second, isA<SaveDuplicate>());
    });

    test('empty string returns SaveInvalid', () async {
      final SaveResult result = await useCase.execute('');

      expect(result, isA<SaveInvalid>());
      final SaveInvalid invalid = result as SaveInvalid;
      expect(invalid.reason, 'URL is empty or malformed');
    });

    test('whitespace-only string returns SaveInvalid', () async {
      final SaveResult result = await useCase.execute('   ');

      expect(result, isA<SaveInvalid>());
      final SaveInvalid invalid = result as SaveInvalid;
      expect(invalid.reason, 'URL is empty or malformed');
    });

    test('malformed URL returns SaveInvalid', () async {
      final SaveResult result = await useCase.execute('ht!tp://[::1');

      expect(result, isA<SaveInvalid>());
      final SaveInvalid invalid = result as SaveInvalid;
      expect(invalid.reason, 'URL is empty or malformed');
    });

    test('URL without scheme gets https prepended', () async {
      const String rawUrl = 'example.com/page';

      final SaveResult result = await useCase.execute(rawUrl);

      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;

      final BookmarkItem? saved =
          await fakeRepository.getById(success.bookmarkId);
      expect(saved!.canonicalUrl, 'https://example.com/page');
      expect(saved.normalizedHost, 'example.com');
    });

    test('sets normalizedHost from canonical URL', () async {
      const String rawUrl = 'https://www.example.com/path';

      final SaveResult result = await useCase.execute(rawUrl);

      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;

      final BookmarkItem? saved =
          await fakeRepository.getById(success.bookmarkId);
      expect(saved!.normalizedHost, 'www.example.com');
    });

    test('repository has exactly one item after single save', () async {
      await useCase.execute('https://example.com/a');

      final List<BookmarkItem> all = await fakeRepository.getAll();
      expect(all.length, 1);
    });

    test('repository has exactly one item after duplicate save', () async {
      await useCase.execute('https://example.com/a');
      await useCase.execute('https://example.com/a');

      final List<BookmarkItem> all = await fakeRepository.getAll();
      expect(all.length, 1);
    });

    group('with redirect resolver', () {
      test('short URL gets resolved and resolvedUrl is populated', () async {
        const String rawUrl = 'https://bit.ly/abc123';
        const String finalUrl = 'https://example.com/final-article';

        final useCaseWithResolver = SaveBookmarkUseCase(
          repository: fakeRepository,
          redirectResolverService:
              _FakeRedirectResolverService(resolveResult: finalUrl),
        );

        final SaveResult result =
            await useCaseWithResolver.execute(rawUrl);

        expect(result, isA<SaveSuccess>());
        final SaveSuccess success = result as SaveSuccess;

        final BookmarkItem? saved =
            await fakeRepository.getById(success.bookmarkId);
        expect(saved, isNotNull);
        expect(saved!.resolvedUrl, finalUrl);
        expect(saved.canonicalUrl, rawUrl);
        expect(saved.urlHash, isNotNull);
      });

      test('non-redirect URL leaves resolvedUrl as null', () async {
        const String rawUrl = 'https://example.com/no-redirect';

        final useCaseWithResolver = SaveBookmarkUseCase(
          repository: fakeRepository,
          redirectResolverService:
              _FakeRedirectResolverService(resolveResult: rawUrl),
        );

        final SaveResult result =
            await useCaseWithResolver.execute(rawUrl);

        expect(result, isA<SaveSuccess>());
        final SaveSuccess success = result as SaveSuccess;

        final BookmarkItem? saved =
            await fakeRepository.getById(success.bookmarkId);
        expect(saved, isNotNull);
        expect(saved!.resolvedUrl, isNull);
      });

      test('works when resolver returns null', () async {
        const String rawUrl = 'https://example.com/article';

        final useCaseWithNullResolver = SaveBookmarkUseCase(
          repository: fakeRepository,
          redirectResolverService:
              _FakeRedirectResolverService(resolveResult: null),
        );

        final SaveResult result =
            await useCaseWithNullResolver.execute(rawUrl);

        expect(result, isA<SaveSuccess>());
        final SaveSuccess success = result as SaveSuccess;

        final BookmarkItem? saved =
            await fakeRepository.getById(success.bookmarkId);
        expect(saved, isNotNull);
        expect(saved!.resolvedUrl, isNull);
        expect(saved.canonicalUrl, rawUrl);
      });
    });

    test('works when resolver is not injected (null)', () async {
      const String rawUrl = 'https://example.com/article';

      final useCaseWithoutResolver = SaveBookmarkUseCase(
        repository: fakeRepository,
      );

      final SaveResult result =
          await useCaseWithoutResolver.execute(rawUrl);

      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;

      final BookmarkItem? saved =
          await fakeRepository.getById(success.bookmarkId);
      expect(saved, isNotNull);
      expect(saved!.resolvedUrl, isNull);
      expect(saved.canonicalUrl, rawUrl);
    });

    group('with canonical url service', () {
      test('YouTube short link gets extracted canonical and contentId',
          () async {
        const String rawUrl = 'https://youtu.be/dQw4w9WgXcQ';
        const String extractedCanonical =
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        const String contentId = 'dQw4w9WgXcQ';

        final useCaseWithService = SaveBookmarkUseCase(
          repository: fakeRepository,
          canonicalUrlService: _FakeCanonicalUrlService(
            result: const CanonicalExtractionResult(
              canonicalUrl: extractedCanonical,
              externalContentId: contentId,
            ),
          ),
        );

        final SaveResult result = await useCaseWithService.execute(rawUrl);
        expect(result, isA<SaveSuccess>());
        final SaveSuccess success = result as SaveSuccess;

        final BookmarkItem? saved =
            await fakeRepository.getById(success.bookmarkId);
        expect(saved, isNotNull);
        expect(saved!.canonicalUrl, extractedCanonical);
        expect(saved.externalContentId, contentId);
        expect(saved.urlHash, isNotNull);
      });

      test(
          'non-platform URL falls back to normalized when extractor returns null',
          () async {
        const String rawUrl = 'https://example.com/article';

        final useCaseWithNullService = SaveBookmarkUseCase(
          repository: fakeRepository,
          canonicalUrlService: _FakeCanonicalUrlService(),
        );

        final SaveResult result =
            await useCaseWithNullService.execute(rawUrl);
        expect(result, isA<SaveSuccess>());
        final SaveSuccess success = result as SaveSuccess;

        final BookmarkItem? saved =
            await fakeRepository.getById(success.bookmarkId);
        expect(saved, isNotNull);
        expect(saved!.canonicalUrl, 'https://example.com/article');
        expect(saved.externalContentId, isNull);
      });

      test('works when canonicalUrlService is not injected', () async {
        const String rawUrl = 'https://example.com/article';

        final useCaseWithoutService = SaveBookmarkUseCase(
          repository: fakeRepository,
        );

        final SaveResult result =
            await useCaseWithoutService.execute(rawUrl);
        expect(result, isA<SaveSuccess>());
        final SaveSuccess success = result as SaveSuccess;

        final BookmarkItem? saved =
            await fakeRepository.getById(success.bookmarkId);
        expect(saved, isNotNull);
        expect(saved!.canonicalUrl, rawUrl);
        expect(saved.externalContentId, isNull);
      });

      test('duplicate detected using final canonicalUrl hash', () async {
        const String rawUrl1 = 'https://youtu.be/dQw4w9WgXcQ';
        const String rawUrl2 =
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        const String extractedCanonical =
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

        final useCaseWithService = SaveBookmarkUseCase(
          repository: fakeRepository,
          canonicalUrlService: _FakeCanonicalUrlService(
            result: const CanonicalExtractionResult(
              canonicalUrl: extractedCanonical,
              externalContentId: 'dQw4w9WgXcQ',
            ),
          ),
        );

        // First save with short URL.
        final SaveResult first = await useCaseWithService.execute(rawUrl1);
        expect(first, isA<SaveSuccess>());

        // Second save with full URL — same extracted canonical.
        final SaveResult second = await useCaseWithService.execute(rawUrl2);
        expect(second, isA<SaveDuplicate>());
      });
    });

    group('with DuplicateDetectionService integration', () {
      test('service is called during execute', () async {
        const String rawUrl = 'https://example.com/article';

        final _SpyDuplicateDetectionService spyService =
            _SpyDuplicateDetectionService(
          repository: fakeRepository,
          normalizationService: normalizationService,
        );

        final useCaseWithSpy = SaveBookmarkUseCase(
          repository: fakeRepository,
          duplicateDetectionService: spyService,
        );

        await useCaseWithSpy.execute(rawUrl);

        expect(spyService.calls, hasLength(1));
        expect(spyService.calls.first['canonicalUrl'],
            'https://example.com/article');
        expect(spyService.calls.first['originalUrl'], rawUrl);
      });

      test('group ID is assigned to existing item on first duplicate encounter',
          () async {
        const String rawUrl = 'https://example.com/article';

        // First save — no duplicate, item gets no group ID.
        final SaveResult first = await useCase.execute(rawUrl);
        expect(first, isA<SaveSuccess>());
        final SaveSuccess success = first as SaveSuccess;

        final BookmarkItem? firstItem =
            await fakeRepository.getById(success.bookmarkId);
        expect(firstItem!.duplicateGroupId, isNull);

        // Second save — duplicate detected, group ID assigned to existing.
        final SaveResult second = await useCase.execute(rawUrl);
        expect(second, isA<SaveDuplicate>());

        final BookmarkItem? updatedItem =
            await fakeRepository.getById(success.bookmarkId);
        expect(updatedItem!.duplicateGroupId, isNotNull);
        expect(updatedItem.duplicateGroupId, isNotEmpty);
      });

      test('existing group ID is reused on subsequent duplicate', () async {
        const String rawUrl1 = 'https://example.com/article';
        const String rawUrl2 =
            'https://example.com/article?utm_source=email';

        // First save.
        final SaveResult first = await useCase.execute(rawUrl1);
        expect(first, isA<SaveSuccess>());

        // Second save — triggers group ID assignment.
        final SaveResult second = await useCase.execute(rawUrl2);
        expect(second, isA<SaveDuplicate>());
        final SaveDuplicate dup2 = second as SaveDuplicate;

        final String? groupId = dup2.existing.duplicateGroupId;
        expect(groupId, isNotNull);
        expect(groupId, isNotEmpty);

        // Third save — group ID should be reused, not regenerated.
        final SaveResult third = await useCase.execute(rawUrl1);
        expect(third, isA<SaveDuplicate>());
        final SaveDuplicate dup3 = third as SaveDuplicate;

        expect(dup3.existing.duplicateGroupId, groupId);
      });

      test(
          'cross-variant duplicate detected via externalContentId '
          '(youtu.be vs youtube.com)', () async {
        const String rawUrlShort = 'https://youtu.be/dQw4w9WgXcQ';
        const String rawUrlFull =
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        const String extractedCanonical =
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        const String contentId = 'dQw4w9WgXcQ';

        final useCaseWithService = SaveBookmarkUseCase(
          repository: fakeRepository,
          canonicalUrlService: _FakeCanonicalUrlService(
            result: const CanonicalExtractionResult(
              canonicalUrl: extractedCanonical,
              externalContentId: contentId,
            ),
          ),
        );

        // Save short URL first.
        final SaveResult first =
            await useCaseWithService.execute(rawUrlShort);
        expect(first, isA<SaveSuccess>());
        final SaveSuccess success = first as SaveSuccess;

        // Save full URL — different raw/canonical but same content ID.
        final SaveResult second =
            await useCaseWithService.execute(rawUrlFull);
        expect(second, isA<SaveDuplicate>());
        final SaveDuplicate dup = second as SaveDuplicate;

        expect(dup.existing.id, success.bookmarkId);
      });

      test('group ID persists across saves in repository', () async {
        const String rawUrl = 'https://example.com/article';

        // First save.
        final SaveResult first = await useCase.execute(rawUrl);
        expect(first, isA<SaveSuccess>());
        final SaveSuccess success = first as SaveSuccess;

        // Second save triggers group ID assignment.
        await useCase.execute(rawUrl);

        final BookmarkItem? itemAfterDup =
            await fakeRepository.getById(success.bookmarkId);
        final String? groupId = itemAfterDup!.duplicateGroupId;
        expect(groupId, isNotNull);

        // Third save — verify the group ID from repo is reused.
        final SaveResult third = await useCase.execute(rawUrl);
        expect(third, isA<SaveDuplicate>());
        final SaveDuplicate dup3 = third as SaveDuplicate;

        expect(dup3.existing.duplicateGroupId, groupId);

        // Verify repo still has the same group ID.
        final BookmarkItem? finalItem =
            await fakeRepository.getById(success.bookmarkId);
        expect(finalItem!.duplicateGroupId, groupId);
      });
    });

    group('with UpsertMergeService integration', () {
      test('duplicate with incoming tags unions into existing tags', () async {
        const String rawUrl = 'https://example.com/article';

        // First save: existing item with tags [1, 2].
        final SaveResult first = await useCase.execute(rawUrl);
        expect(first, isA<SaveSuccess>());
        final SaveSuccess success = first as SaveSuccess;

        final BookmarkItem? existing =
            await fakeRepository.getById(success.bookmarkId);
        existing!.tagIds = <int>[1, 2];
        await fakeRepository.update(existing);

        // Second save with incoming tags [2, 3] → union should be [1, 2, 3].
        final SaveResult second = await useCase.execute(
          rawUrl,
          params: const SaveBookmarkParams(tagIds: <int>[2, 3]),
        );
        expect(second, isA<SaveDuplicate>());

        final BookmarkItem? updated =
            await fakeRepository.getById(success.bookmarkId);
        expect(updated!.tagIds, unorderedEquals(<int>[1, 2, 3]));
      });

      test('duplicate with incoming collections unions into existing collections',
          () async {
        const String rawUrl = 'https://example.com/article';

        // First save: existing item with collections [10].
        final SaveResult first = await useCase.execute(rawUrl);
        expect(first, isA<SaveSuccess>());
        final SaveSuccess success = first as SaveSuccess;

        final BookmarkItem? existing =
            await fakeRepository.getById(success.bookmarkId);
        existing!.collectionIds = <int>[10];
        await fakeRepository.update(existing);

        // Second save with incoming collections [20, 10] → union [10, 20].
        final SaveResult second = await useCase.execute(
          rawUrl,
          params: const SaveBookmarkParams(collectionIds: <int>[20, 10]),
        );
        expect(second, isA<SaveDuplicate>());

        final BookmarkItem? updated =
            await fakeRepository.getById(success.bookmarkId);
        expect(updated!.collectionIds, unorderedEquals(<int>[10, 20]));
      });

      test(
          'duplicate with sharedText when existing has none populates sharedText',
          () async {
        const String rawUrl = 'https://example.com/article';
        const String sharedText = 'Check out this great article!';

        // First save: no sharedText.
        final SaveResult first = await useCase.execute(rawUrl);
        expect(first, isA<SaveSuccess>());
        final SaveSuccess success = first as SaveSuccess;

        final BookmarkItem? existing =
            await fakeRepository.getById(success.bookmarkId);
        expect(existing!.sharedText, isNull);

        // Second save with sharedText.
        final SaveResult second = await useCase.execute(
          rawUrl,
          params: const SaveBookmarkParams(sharedText: sharedText),
        );
        expect(second, isA<SaveDuplicate>());

        final BookmarkItem? updated =
            await fakeRepository.getById(success.bookmarkId);
        expect(updated!.sharedText, sharedText);
      });

      test('duplicate preserves user flags (favorite, archived, read, pinned)',
          () async {
        const String rawUrl = 'https://example.com/article';

        // First save: set all user flags.
        final SaveResult first = await useCase.execute(rawUrl);
        expect(first, isA<SaveSuccess>());
        final SaveSuccess success = first as SaveSuccess;

        final BookmarkItem? existing =
            await fakeRepository.getById(success.bookmarkId);
        existing!
          ..isFavorite = true
          ..isArchived = true
          ..isRead = true
          ..isPinned = true;
        await fakeRepository.update(existing);

        // Second save with incoming params should not flip flags.
        final SaveResult second = await useCase.execute(
          rawUrl,
          params: const SaveBookmarkParams(
            tagIds: <int>[1],
            sharedText: 'incoming text',
          ),
        );
        expect(second, isA<SaveDuplicate>());

        final BookmarkItem? updated =
            await fakeRepository.getById(success.bookmarkId);
        expect(updated!.isFavorite, isTrue);
        expect(updated.isArchived, isTrue);
        expect(updated.isRead, isTrue);
        expect(updated.isPinned, isTrue);
      });

      test('duplicate with null params only updates timestamps and groupId',
          () async {
        const String rawUrl = 'https://example.com/article';

        // First save.
        final SaveResult first = await useCase.execute(rawUrl);
        expect(first, isA<SaveSuccess>());
        final SaveSuccess success = first as SaveSuccess;

        final BookmarkItem? existingBefore =
            await fakeRepository.getById(success.bookmarkId);
        final DateTime originalUpdatedAt = existingBefore!.updatedAt;

        // Wait a tick to ensure timestamp changes.
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Second save with no params.
        final SaveResult second = await useCase.execute(rawUrl);
        expect(second, isA<SaveDuplicate>());

        final BookmarkItem? updated =
            await fakeRepository.getById(success.bookmarkId);
        expect(updated!.duplicateGroupId, isNotNull);
        expect(updated.updatedAt.isAfter(originalUpdatedAt), isTrue);
        expect(updated.lastInteractionAt, isNotNull);
        // tagIds, collectionIds, sharedText should remain null/unchanged.
        expect(updated.tagIds, isNull);
        expect(updated.collectionIds, isNull);
        expect(updated.sharedText, isNull);
      });

      test('no duplicate with params → new bookmark gets params metadata',
          () async {
        const String rawUrl = 'https://example.com/new-article';
        const String sharedText = 'Shared from Twitter';

        final SaveResult result = await useCase.execute(
          rawUrl,
          params: const SaveBookmarkParams(
            tagIds: <int>[5, 6],
            collectionIds: <int>[100],
            sharedText: sharedText,
            sourceType: 'share_sheet',
          ),
        );
        expect(result, isA<SaveSuccess>());
        final SaveSuccess success = result as SaveSuccess;

        final BookmarkItem? saved =
            await fakeRepository.getById(success.bookmarkId);
        expect(saved, isNotNull);
        expect(saved!.tagIds, unorderedEquals(<int>[5, 6]));
        expect(saved.collectionIds, unorderedEquals(<int>[100]));
        expect(saved.sharedText, sharedText);
        expect(saved.sourceType, 'share_sheet');
      });
    });
  });
}
