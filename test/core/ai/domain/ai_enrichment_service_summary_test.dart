import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:marky/core/ai/domain/models/keyword_extraction_result.dart';
import 'package:marky/core/ai/domain/services/ai_enrichment_service.dart';
import 'package:marky/core/ai/domain/services/keyword_extraction_service.dart';
import 'package:marky/core/ai/domain/services/smart_tag_engine_service.dart';
import 'package:marky/core/ai/domain/services/summary_generation_service.dart';
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

  List<BookmarkItem> get updatedItems => _items.values.toList();

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

class FakeSummaryGenerationService implements SummaryGenerationService {
  String? _result;
  Exception? _exception;

  void setResult(String? result) => _result = result;
  void setException(Exception e) => _exception = e;

  @override
  String? generate(BookmarkItem bookmark) {
    if (_exception != null) throw _exception!;
    return _result;
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
  String? aiSummary,
}) {
  final bm = BookmarkItem(
    originalUrl: originalUrl,
    title: title,
    description: description,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
  bm.id = id;
  if (aiSummary != null) {
    bm.aiSummary = aiSummary;
  }
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
  late FakeSummaryGenerationService fakeSummaryService;
  late AiEnrichmentServiceImpl service;

  setUp(() {
    fakeSettingsRepo = FakeAppSettingsRepository();
    fakeBookmarkRepo = FakeBookmarkItemRepository();
    fakeKeywordService = FakeKeywordExtractionService();
    fakeSmartTagService = FakeSmartTagEngineService();
    fakeSummaryService = FakeSummaryGenerationService();

    service = AiEnrichmentServiceImpl(
      appSettingsRepository: fakeSettingsRepo,
      bookmarkRepository: fakeBookmarkRepo,
      keywordExtractionService: fakeKeywordService,
      smartTagEngineService: fakeSmartTagService,
      summaryGenerationService: fakeSummaryService,
    );
  });

  // ── 1. Summary stage runs when AI is enabled ──────────────────────
  group('summary stage', () {
    test(
      'when aiEnabled is true and bookmark has no summary, '
      'generates and persists summary',
      () async {
        // Arrange
        final bookmark = _makeBookmark(
          id: 42,
          title: 'Flutter Testing Guide',
          description: 'This is a test description. It has multiple sentences.',
        );
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
        fakeKeywordService.setResult(
          const KeywordExtractionResult(
            keywords: ['flutter', 'testing'],
            category: 'development',
          ),
        );
        fakeSummaryService.setResult('This is a test description.');

        // Act
        await service.enrich(42);

        // Assert
        final updated = await fakeBookmarkRepo.getById(42);
        expect(updated, isNotNull);
        expect(updated!.aiSummary, 'This is a test description.');
      },
    );

    test(
      'when bookmark already has a summary, existing summary is NOT overwritten',
      () async {
        // Arrange
        final bookmark = _makeBookmark(
          id: 43,
          title: 'Existing Summary Test',
          aiSummary: 'Pre-existing summary.',
        );
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
        fakeKeywordService.setResult(
          const KeywordExtractionResult(
            keywords: ['test'],
            category: 'test',
          ),
        );
        fakeSummaryService.setResult('New generated summary.');

        // Act
        await service.enrich(43);

        // Assert
        final updated = await fakeBookmarkRepo.getById(43);
        expect(updated, isNotNull);
        expect(updated!.aiSummary, 'Pre-existing summary.');
      },
    );

    test(
      'when summary generation returns null, aiSummary is not modified',
      () async {
        // Arrange
        final bookmark = _makeBookmark(
          id: 44,
          title: 'Null Summary Test',
        );
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
        fakeKeywordService.setResult(
          const KeywordExtractionResult(
            keywords: ['test'],
            category: 'test',
          ),
        );
        fakeSummaryService.setResult(null);

        // Act
        await service.enrich(44);

        // Assert
        final updated = await fakeBookmarkRepo.getById(44);
        expect(updated, isNotNull);
        expect(updated!.aiSummary, isNull);
      },
    );

    test(
      'when summary generation throws, error is isolated and smart tags still run',
      () async {
        // Arrange
        final bookmark = _makeBookmark(
          id: 45,
          title: 'Summary Failure Test',
        );
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
        fakeKeywordService.setResult(
          const KeywordExtractionResult(
            keywords: ['test'],
            category: 'test',
          ),
        );
        fakeSummaryService.setException(
          Exception('Summary generation failed'),
        );

        // Act
        await service.enrich(45);

        // Assert — smart tags should still run despite summary failure
        expect(fakeSmartTagService.evaluatedBookmarkIds, [45]);
        // Bookmark should still have keyword results persisted
        final updated = await fakeBookmarkRepo.getById(45);
        expect(updated!.aiKeywords, ['test']);
      },
    );
  });

  // ── 2. Null service backward compatibility ─────────────────────────
  group('backward compatibility', () {
    test(
      'when summaryGenerationService is null, enrichment completes normally',
      () async {
        // Arrange
        final serviceWithoutSummary = AiEnrichmentServiceImpl(
          appSettingsRepository: fakeSettingsRepo,
          bookmarkRepository: fakeBookmarkRepo,
          keywordExtractionService: fakeKeywordService,
          smartTagEngineService: fakeSmartTagService,
          // summaryGenerationService is omitted (null)
        );
        final bookmark = _makeBookmark(
          id: 46,
          title: 'No Summary Service Test',
        );
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
        fakeKeywordService.setResult(
          const KeywordExtractionResult(
            keywords: ['test'],
            category: 'test',
          ),
        );

        // Act & Assert — should not throw
        await serviceWithoutSummary.enrich(46);

        expect(fakeSmartTagService.evaluatedBookmarkIds, [46]);
        final updated = await fakeBookmarkRepo.getById(46);
        expect(updated!.aiKeywords, ['test']);
      },
    );
  });

  // ── 3. AI disabled gate ────────────────────────────────────────────
  group('AI disabled', () {
    test(
      'when aiEnabled is false, summary is not generated',
      () async {
        final bookmark = _makeBookmark(
          id: 47,
          title: 'AI Disabled Test',
        );
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: false));

        await service.enrich(47);

        final untouched = await fakeBookmarkRepo.getById(47);
        expect(untouched!.aiSummary, isNull);
        expect(fakeSmartTagService.evaluatedBookmarkIds, isEmpty);
      },
    );
  });

  // ── 4. Summary stage runs after keywords and before smart tags ─────
  group('stage ordering', () {
    test(
      'summary sees keyword-extracted bookmark fields when persisted',
      () async {
        // Arrange
        final bookmark = _makeBookmark(
          id: 48,
          title: 'Stage Ordering Test',
        );
        fakeBookmarkRepo.seed(bookmark);
        fakeSettingsRepo.setSettings(_makeSettings(aiEnabled: true));
        fakeKeywordService.setResult(
          const KeywordExtractionResult(
            keywords: ['ordering', 'test'],
            category: 'verification',
          ),
        );
        fakeSummaryService.setResult('Summary after keywords.');

        // Act
        await service.enrich(48);

        // Assert
        final updated = await fakeBookmarkRepo.getById(48);
        expect(updated!.aiKeywords, ['ordering', 'test']);
        expect(updated.aiCategory, 'verification');
        expect(updated.aiSummary, 'Summary after keywords.');
        expect(fakeSmartTagService.evaluatedBookmarkIds, [48]);
      },
    );
  });
}
