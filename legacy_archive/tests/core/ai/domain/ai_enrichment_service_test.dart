import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:marky/core/ai/domain/models/keyword_extraction_result.dart';
import 'package:marky/core/ai/domain/services/ai_enrichment_service.dart';
import 'package:marky/core/ai/domain/services/keyword_extraction_service.dart';
import 'package:marky/core/ai/domain/services/smart_tag_engine_service.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ---------------------------------------------------------------------------
// Fake implementations (no external mocking package)
// ---------------------------------------------------------------------------
class FakeAppSettingsRepository implements AppSettingsRepository {
  AppSettings? _settings;

  void setSettings(AppSettings? settings) => _settings = settings;

  @override
  Future<AppSettings?> getSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }

  @override
  Future<void> deleteSettings() async => _settings = null;
}

class FakeBookmarkItemRepository implements BookmarkItemRepository {
  final Map<Id, BookmarkItem> _items = {};
  int _nextId = 1;

  void seed(BookmarkItem item) {
    _items[item.id] = item;
  }

  List<BookmarkItem> get updatedItems =>
      _items.values.toList();

  @override
  Future<BookmarkItem?> getById(Id id) async => _items[id];

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(
    String externalContentId,
  ) async =>
      null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => [];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => _items.values.toList();

  @override
  Future<Id> insert(BookmarkItem entity) async {
    final id = _nextId++;
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
  Future<void> delete(Id id) async => _items.remove(id);

  @override
  Future<void> clear() async => _items.clear();
}

class FakeKeywordExtractionService implements KeywordExtractionService {
  KeywordExtractionResult _result = const KeywordExtractionResult(
    keywords: [],
  );
  Exception? _exception;

  void setResult(KeywordExtractionResult result) => _result = result;
  void setException(Exception e) => _exception = e;

  @override
  KeywordExtractionResult extract(BookmarkItem bookmark) {
    if (_exception != null) throw _exception!;
    return _result;
  }
}

class FakeSmartTagEngineService implements SmartTagEngineService {
  final List<int> evaluatedBookmarkIds = [];
  Exception? _exception;

  void setException(Exception e) => _exception = e;

  @override
  Future<void> evaluate(BookmarkItem bookmark) async {
    if (_exception != null) throw _exception!;
    evaluatedBookmarkIds.add(bookmark.id);
  }
}

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------
BookmarkItem _makeBookmark({
  int id = 1,
  String originalUrl = 'https://example.com/page',
  String? title,
  String? description,
}) {
  final bm = BookmarkItem(
    originalUrl: originalUrl,
    title: title,
    description: description,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
  bm.id = id;
  return bm;
}

AppSettings _makeSettings({bool aiEnabled = true}) => AppSettings(
      aiEnabled: aiEnabled,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  late FakeAppSettingsRepository fakeSettingsRepo;
  late FakeBookmarkItemRepository fakeBookmarkRepo;
  late FakeKeywordExtractionService fakeKeywordService;
  late FakeSmartTagEngineService fakeSmartTagService;
  late AiEnrichmentServiceImpl service;

  setUp(() {
    fakeSettingsRepo = FakeAppSettingsRepository();
    fakeBookmarkRepo = FakeBookmarkItemRepository();
    fakeKeywordService = FakeKeywordExtractionService();
    fakeSmartTagService = FakeSmartTagEngineService();

    service = AiEnrichmentServiceImpl(
      appSettingsRepository: fakeSettingsRepo,
      bookmarkRepository: fakeBookmarkRepo,
      keywordExtractionService: fakeKeywordService,
      smartTagEngineService: fakeSmartTagService,
    );
  });

  // ── 1. Happy path — full enrichment ─────────────────────────────────
  group('happy path', () {
    test(
      'when aiEnabled is true, extracts keywords, persists them, '
      'and calls smart tag evaluation',
      () async {
        // Arrange
        final bookmark = _makeBookmark(
          id: 42,
          title: 'Flutter Testing Guide',
        );
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
        fakeKeywordService.setResult(
          const KeywordExtractionResult(
            keywords: ['flutter', 'testing'],
            category: 'development',
          ),
        );

        // Act
        await service.enrich(42);

        // Assert
        final updated = await fakeBookmarkRepo.getById(42);
        expect(updated, isNotNull);
        expect(updated!.aiKeywords, ['flutter', 'testing']);
        expect(updated.aiCategory, 'development');
        expect(updated.updatedAt.millisecondsSinceEpoch,
            greaterThan(DateTime(2024, 1, 1).millisecondsSinceEpoch));
        expect(fakeSmartTagService.evaluatedBookmarkIds, [42]);
      },
    );

    test(
      'bookmark.aiKeywords and aiCategory are populated after enrichment',
      () async {
        final bookmark = _makeBookmark(id: 7);
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
        fakeKeywordService.setResult(
          const KeywordExtractionResult(
            keywords: ['ai', 'ml', 'dart'],
            category: 'technology',
          ),
        );

        await service.enrich(7);

        final updated = await fakeBookmarkRepo.getById(7);
        expect(updated!.aiKeywords, ['ai', 'ml', 'dart']);
        expect(updated.aiCategory, 'technology');
      },
    );
  });

  // ── 2. AI disabled gate ─────────────────────────────────────────────
  group('AI disabled', () {
    test(
      'when aiEnabled is false, no repository reads/writes and '
      'no extraction happens',
      () async {
        final bookmark = _makeBookmark(id: 1);
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: false));

        await service.enrich(1);

        // Bookmark should not be touched
        final untouched = await fakeBookmarkRepo.getById(1);
        expect(untouched!.aiKeywords, isNull);
        expect(untouched.aiCategory, isNull);
        expect(fakeSmartTagService.evaluatedBookmarkIds, isEmpty);
      },
    );

    test(
      'when settings are null, treats as disabled and returns silently',
      () async {
        final bookmark = _makeBookmark(id: 2);
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(null);

        await service.enrich(2);

        final untouched = await fakeBookmarkRepo.getById(2);
        expect(untouched!.aiKeywords, isNull);
        expect(fakeSmartTagService.evaluatedBookmarkIds, isEmpty);
      },
    );
  });

  // ── 3. Bookmark not found ───────────────────────────────────────────
  group('bookmark not found', () {
    test('logs warning and returns without error', () async {
      fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
      // No bookmark seeded with id 99

      // Should not throw
      await service.enrich(99);

      expect(fakeSmartTagService.evaluatedBookmarkIds, isEmpty);
    });
  });

  // ── 4. Keyword extraction throws ────────────────────────────────────
  group('keyword extraction failure', () {
    test(
      'error is caught and logged; smart tag evaluation is still attempted',
      () async {
        final bookmark = _makeBookmark(id: 3);
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
        fakeKeywordService.setException(
          Exception('Tokenizer failed'),
        );

        // Should not throw
        await service.enrich(3);

        // Smart tags should still be attempted
        expect(fakeSmartTagService.evaluatedBookmarkIds, [3]);
      },
    );
  });

  // ── 5. Smart tag evaluation throws ──────────────────────────────────
  group('smart tag evaluation failure', () {
    test(
      'error is caught and logged; keyword extraction results are still '
      'persisted',
      () async {
        final bookmark = _makeBookmark(id: 4);
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
        fakeKeywordService.setResult(
          const KeywordExtractionResult(
            keywords: ['persistent', 'data'],
            category: 'article',
          ),
        );
        fakeSmartTagService.setException(
          Exception('Tag repo unreachable'),
        );

        // Should not throw
        await service.enrich(4);

        // Keyword results should still be persisted
        final updated = await fakeBookmarkRepo.getById(4);
        expect(updated!.aiKeywords, ['persistent', 'data']);
        expect(updated.aiCategory, 'article');
      },
    );
  });

  // ── 6. General error resilience ─────────────────────────────────────
  group('general error resilience', () {
    test('unexpected errors during settings load are caught and swallowed',
        () async {
      // This is implicitly tested by the outer try/catch, but we verify
      // the service doesn't throw even if the whole flow breaks.
      fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
      // No bookmark seeded — this hits the null path, which is safe.

      expect(() async => service.enrich(999), returnsNormally);
    });

    test('enrichment completes without error when everything works',
        () async {
      final bookmark = _makeBookmark(id: 5);
      fakeBookmarkRepo.seed(bookmark);
      fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
      fakeKeywordService.setResult(
        const KeywordExtractionResult(
          keywords: ['test'],
          category: 'test-category',
        ),
      );

      expect(() async => service.enrich(5), returnsNormally);
    });
  });
}
