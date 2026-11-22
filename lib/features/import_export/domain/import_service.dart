import 'dart:convert';
import 'dart:isolate';

import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';
import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/core/database/enums/collection_sort_mode.dart';
import 'package:marky/core/database/enums/reminder_repeat_mode.dart';
import 'package:marky/core/database/enums/reminder_status.dart';
import 'package:marky/core/url/content_type_detector.dart';
import 'package:marky/core/url/external_content_id_extractor.dart';
import 'package:marky/core/url/url_hasher.dart';
import 'package:marky/core/url/url_normalizer.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';
import 'package:marky/features/automation/domain/automation_rule_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/domain/duplicate_check_result.dart';
import 'package:marky/features/capture/domain/duplicate_detector.dart';
import 'package:marky/features/capture/domain/upsert_merge_service.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';
import 'package:marky/features/import_export/domain/netscape_bookmark_parser.dart';
import 'package:marky/features/notes/domain/note.dart';
import 'package:marky/features/notes/domain/note_repository.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';
import 'package:marky/features/search/domain/search_query.dart';
import 'package:marky/features/search/domain/search_query_repository.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

/// Result returned after a JSON or HTML import.
class ImportResult {
  const ImportResult({
    this.bookmarksImported = 0,
    this.bookmarksMerged = 0,
    this.bookmarksSkipped = 0,
    this.tagsImported = 0,
    this.collectionsImported = 0,
    this.notesImported = 0,
    this.automationRulesImported = 0,
    this.savedSearchesImported = 0,
    this.remindersImported = 0,
    this.importedBookmarkIds = const <int>[],
  });

  final int bookmarksImported;
  final int bookmarksMerged;
  final int bookmarksSkipped;
  final int tagsImported;
  final int collectionsImported;
  final int notesImported;
  final int automationRulesImported;
  final int savedSearchesImported;
  final int remindersImported;
  final List<int> importedBookmarkIds;
}

/// Restores a Marky JSON backup (v1 or v2) or browser Netscape HTML file,
/// deduplicating bookmarks and remapping tag/collection IDs cleanly.
class ImportService {
  const ImportService({
    required BookmarkRepository bookmarkRepository,
    required TagRepository tagRepository,
    required BookmarkCollectionRepository collectionRepository,
    required DuplicateDetector duplicateDetector,
    required UpsertMergeService mergeService,
    NoteRepository? noteRepository,
    AutomationRuleRepository? automationRuleRepository,
    SearchQueryRepository? searchQueryRepository,
    ReminderRepository? reminderRepository,
  })  : _bookmarks = bookmarkRepository,
        _tags = tagRepository,
        _collections = collectionRepository,
        _duplicateDetector = duplicateDetector,
        _mergeService = mergeService,
        _notes = noteRepository,
        _automationRules = automationRuleRepository,
        _searchQueries = searchQueryRepository,
        _reminders = reminderRepository;

  final BookmarkRepository _bookmarks;
  final TagRepository _tags;
  final BookmarkCollectionRepository _collections;
  final DuplicateDetector _duplicateDetector;
  final UpsertMergeService _mergeService;
  final NoteRepository? _notes;
  final AutomationRuleRepository? _automationRules;
  final SearchQueryRepository? _searchQueries;
  final ReminderRepository? _reminders;

  static const UrlNormalizer _normalizer = UrlNormalizer();
  static const UrlHasher _hasher = UrlHasher();
  static const ExternalContentIdExtractor _contentIdExtractor =
      ExternalContentIdExtractor();
  static const ContentTypeDetector _contentTypeDetector = ContentTypeDetector();

  /// Parses [jsonString] (v1 or v2) and inserts missing entities while
  /// remapping tag and collection references by slug / old ID.
  Future<ImportResult> importAll(String jsonString) async {
    final Map<String, dynamic> envelope =
        json.decode(jsonString) as Map<String, dynamic>;

    final int version = (envelope['version'] as int?) ?? 1;
    if (version != 1 && version != 2) {
      throw FormatException('Unsupported backup version: $version');
    }

    int bookmarksImported = 0;
    int bookmarksMerged = 0;
    int bookmarksSkipped = 0;
    int tagsImported = 0;
    int collectionsImported = 0;
    int notesImported = 0;
    int automationRulesImported = 0;
    int savedSearchesImported = 0;
    int remindersImported = 0;

    final Map<String, int> tagSlugToId = <String, int>{};
    final Map<int, int> oldTagIdToNewId = <int, int>{};
    final Map<String, int> collectionSlugToId = <String, int>{};
    final Map<int, int> oldCollectionIdToNewId = <int, int>{};

    // ── Tags ────────────────────────────────────────────────────
    final List<dynamic> rawTags =
        (envelope['tags'] as List<dynamic>?) ?? <dynamic>[];
    for (final dynamic raw in rawTags) {
      final Map<String, dynamic> m = raw as Map<String, dynamic>;
      final String name = (m['name'] as String?) ?? '';
      if (name.isEmpty) continue;

      final String slug = (m['slug'] as String?)?.trim().isNotEmpty ?? false
          ? (m['slug'] as String).trim()
          : Tag.slugify(name);
      final int? oldId = m['id'] as int?;

      Tag? existing = await _tags.findBySlug(slug);
      existing ??= await _tags.findBySlug(Tag.slugify(name));

      Tag resolved;
      if (existing != null) {
        resolved = existing;
      } else {
        final Tag created = await _tags.createFromName(
          name,
          colorArgb: m['colorArgb'] as int?,
          icon: m['icon'] as String?,
        );
        final bool needsExtraMeta = (m['description'] as String?) != null ||
            ((m['isPinned'] as bool?) ?? false) ||
            ((m['orderIndex'] as int?) ?? 0) != 0;
        resolved = needsExtraMeta
            ? await _tags.save(
                created.copyWith(
                  description: m['description'] as String?,
                  isPinned: (m['isPinned'] as bool?) ?? false,
                  orderIndex: (m['orderIndex'] as int?) ?? 0,
                ),
              )
            : created;
        tagsImported++;
      }

      if (resolved.id != null) {
        tagSlugToId[slug] = resolved.id!;
        tagSlugToId[resolved.slug] = resolved.id!;
        if (oldId != null) oldTagIdToNewId[oldId] = resolved.id!;
      }
    }

    // ── Collections (manual + smart) ────────────────────────────
    final List<dynamic> rawCollections =
        (envelope['collections'] as List<dynamic>?) ?? <dynamic>[];
    for (final dynamic raw in rawCollections) {
      final Map<String, dynamic> m = raw as Map<String, dynamic>;
      final String title = (m['title'] as String?) ?? '';
      if (title.isEmpty) continue;

      final String slug = (m['slug'] as String?)?.trim().isNotEmpty ?? false
          ? (m['slug'] as String).trim()
          : BookmarkCollection.slugify(title);
      final int? oldId = m['id'] as int?;

      BookmarkCollection? existing = await _collections.findBySlug(slug);
      existing ??=
          await _collections.findBySlug(BookmarkCollection.slugify(title));

      BookmarkCollection resolved;
      if (existing != null) {
        resolved = existing;
      } else {
        final bool isSmart = (m['isSmart'] as bool?) ?? false;
        final String? smartRuleJson = m['smartRuleJson'] as String?;
        final String? smartRuleTagSlug = m['smartRuleTagSlug'] as String?;
        BookmarkCollection created;

        if (isSmart && smartRuleJson != null && smartRuleJson.isNotEmpty) {
          SmartCollectionRule? decodedRule;
          try {
            final SmartCollectionRule parsed =
                SmartCollectionRule.decode(smartRuleJson);
            final int? remappedTagId = smartRuleTagSlug != null
                ? tagSlugToId[smartRuleTagSlug]
                : (parsed.tagId != null
                    ? (oldTagIdToNewId[parsed.tagId!] ?? parsed.tagId)
                    : null);
            decodedRule = SmartCollectionRule(
              filter: parsed.filter,
              tagId: remappedTagId,
              host: parsed.host,
              contentType: parsed.contentType,
              addedWithinDays: parsed.addedWithinDays,
            );
          } on Object {
            decodedRule = null;
          }

          if (decodedRule != null) {
            created = await _collections.createSmartFromRule(
              title,
              decodedRule,
              accentColorArgb: m['accentColorArgb'] as int?,
              icon: m['icon'] as String?,
            );
          } else {
            created = await _collections.createFromTitle(
              title,
              accentColorArgb: m['accentColorArgb'] as int?,
              icon: m['icon'] as String?,
            );
          }
        } else {
          created = await _collections.createFromTitle(
            title,
            accentColorArgb: m['accentColorArgb'] as int?,
            icon: m['icon'] as String?,
          );
        }

        final CollectionSortMode sortMode = _parseSortMode(
          m['sortMode'] as String?,
        );
        final bool needsExtraMeta = (m['description'] as String?) != null ||
            ((m['isPinned'] as bool?) ?? false) ||
            ((m['isArchived'] as bool?) ?? false) ||
            ((m['orderIndex'] as int?) ?? 0) != 0 ||
            sortMode != CollectionSortMode.newestFirst;

        resolved = needsExtraMeta
            ? await _collections.save(
                created.copyWith(
                  description: m['description'] as String?,
                  isPinned: (m['isPinned'] as bool?) ?? false,
                  isArchived: (m['isArchived'] as bool?) ?? false,
                  orderIndex: (m['orderIndex'] as int?) ?? 0,
                  sortMode: sortMode,
                ),
              )
            : created;
        collectionsImported++;
      }

      if (resolved.id != null) {
        collectionSlugToId[slug] = resolved.id!;
        collectionSlugToId[resolved.slug] = resolved.id!;
        if (oldId != null) oldCollectionIdToNewId[oldId] = resolved.id!;
      }
    }

    // ── Bookmarks ───────────────────────────────────────────────
    final Map<String, int> bookmarkHashToId = <String, int>{};
    final List<dynamic> rawBookmarks =
        (envelope['bookmarks'] as List<dynamic>?) ?? <dynamic>[];
    for (final dynamic raw in rawBookmarks) {
      final Map<String, dynamic> m = raw as Map<String, dynamic>;
      final String url = ((m['originalUrl'] as String?) ?? '').trim();
      if (url.isEmpty) continue;

      final Bookmark? incoming = _bookmarkFromJson(
        m,
        tagSlugToId: tagSlugToId,
        oldTagIdToNewId: oldTagIdToNewId,
        collectionSlugToId: collectionSlugToId,
        oldCollectionIdToNewId: oldCollectionIdToNewId,
      );
      if (incoming == null) {
        bookmarksSkipped++;
        continue;
      }

      final DuplicateCheckResult duplicate = await _duplicateDetector.check(
        urlHash: incoming.urlHash!,
        canonicalUrl: incoming.canonicalUrl!,
        externalContentId: incoming.externalContentId,
      );

      Bookmark persisted;
      if (duplicate.isNew) {
        persisted = await _bookmarks.save(incoming);
        bookmarksImported++;
      } else {
        final Bookmark existing = duplicate.existingBookmark!;
        final Bookmark merged = _mergeService.merge(existing, incoming);
        persisted = await _bookmarks.save(merged);
        bookmarksMerged++;
      }

      if (persisted.id != null) {
        if (incoming.urlHash != null) {
          bookmarkHashToId[incoming.urlHash!] = persisted.id!;
        }
        final String? rawHash = m['urlHash'] as String?;
        if (rawHash != null && rawHash.isNotEmpty) {
          bookmarkHashToId[rawHash] = persisted.id!;
        }
      }
    }

    // ── Notes (v2) ──────────────────────────────────────────────
    if (_notes != null) {
      final List<dynamic> rawNotes =
          (envelope['notes'] as List<dynamic>?) ?? <dynamic>[];
      final Map<int, Set<String>> existingNotesByBookmark =
          <int, Set<String>>{};
      for (final dynamic raw in rawNotes) {
        if (raw is! Map<String, dynamic>) continue;
        final String content = ((raw['content'] as String?) ?? '').trim();
        if (content.isEmpty) continue;

        final int? bookmarkId = await _resolveBookmarkId(
          urlHash: raw['bookmarkUrlHash'] as String?,
          originalUrl: raw['bookmarkOriginalUrl'] as String?,
          cache: bookmarkHashToId,
        );
        if (bookmarkId == null) continue;

        final Set<String> seen = existingNotesByBookmark[bookmarkId] ??
            (await _notes.getByBookmarkId(bookmarkId))
                .map((Note n) => n.content.trim())
                .toSet();
        existingNotesByBookmark[bookmarkId] = seen;
        if (seen.contains(content)) continue;

        final DateTime now = DateTime.now();
        await _notes.save(
          Note(
            bookmarkId: bookmarkId,
            content: content,
            createdAt: _tryParseDate(raw['createdAt'] as String?) ?? now,
            updatedAt: _tryParseDate(raw['updatedAt'] as String?) ?? now,
          ),
        );
        seen.add(content);
        notesImported++;
      }
    }

    // ── Automation Rules (v2) ───────────────────────────────────
    if (_automationRules != null) {
      final List<dynamic> rawRules =
          (envelope['automationRules'] as List<dynamic>?) ?? <dynamic>[];
      if (rawRules.isNotEmpty) {
        final Set<String> existingNames = (await _automationRules.getAll())
            .map((AutomationRule r) => r.name.trim().toLowerCase())
            .toSet();
        for (final dynamic raw in rawRules) {
          if (raw is! Map<String, dynamic>) continue;
          final String name = ((raw['name'] as String?) ?? '').trim();
          if (name.isEmpty || existingNames.contains(name.toLowerCase())) {
            continue;
          }
          final AutomationRule? parsed = _ruleFromJson(
            raw,
            tagSlugToId: tagSlugToId,
            oldTagIdToNewId: oldTagIdToNewId,
            collectionSlugToId: collectionSlugToId,
            oldCollectionIdToNewId: oldCollectionIdToNewId,
          );
          if (parsed == null || parsed.actions.isEmpty) continue;
          await _automationRules.save(parsed);
          existingNames.add(name.toLowerCase());
          automationRulesImported++;
        }
      }
    }

    // ── Saved Searches (v2) ─────────────────────────────────────
    if (_searchQueries != null) {
      final List<dynamic> rawSearches =
          (envelope['savedSearches'] as List<dynamic>?) ?? <dynamic>[];
      for (final dynamic raw in rawSearches) {
        if (raw is! Map<String, dynamic>) continue;
        final String query = ((raw['query'] as String?) ?? '').trim();
        if (query.isEmpty) continue;
        final SearchQuery? existing =
            await _searchQueries.findByNormalizedQuery(query.toLowerCase());
        if (existing != null && existing.isSaved) continue;
        await _searchQueries.saveSearch(
          query,
          label: raw['label'] as String?,
        );
        savedSearchesImported++;
      }
    }

    // ── Active Reminders (v2) ───────────────────────────────────
    if (_reminders != null) {
      final List<dynamic> rawReminders =
          (envelope['reminders'] as List<dynamic>?) ?? <dynamic>[];
      for (final dynamic raw in rawReminders) {
        if (raw is! Map<String, dynamic>) continue;
        final String title = ((raw['title'] as String?) ?? '').trim();
        final DateTime? scheduledAt =
            _tryParseDate(raw['scheduledAt'] as String?);
        if (title.isEmpty || scheduledAt == null) continue;

        final int? bookmarkId = await _resolveBookmarkId(
          urlHash: raw['bookmarkUrlHash'] as String?,
          originalUrl: raw['bookmarkOriginalUrl'] as String?,
          cache: bookmarkHashToId,
        );
        if (bookmarkId == null) continue;

        final List<Reminder> existingForBookmark =
            await _reminders.getByBookmarkId(bookmarkId);
        final bool duplicateReminder = existingForBookmark.any(
          (Reminder r) =>
              r.isActive &&
              r.title == title &&
              r.scheduledAt.toUtc() == scheduledAt.toUtc(),
        );
        if (duplicateReminder) continue;

        await _reminders.save(
          Reminder(
            bookmarkId: bookmarkId,
            title: title,
            body: raw['body'] as String?,
            scheduledAt: scheduledAt,
            timezone: (raw['timezone'] as String?) ?? 'UTC',
            repeatMode: _parseRepeatMode(raw['repeatMode'] as String?),
            status: _parseReminderStatus(raw['status'] as String?),
            snoozedUntil: _tryParseDate(raw['snoozedUntil'] as String?),
            createdAt:
                _tryParseDate(raw['createdAt'] as String?) ?? DateTime.now(),
          ),
        );
        remindersImported++;
      }
    }

    // Recompute cached tag/collection counts so Library stays accurate.
    await _recomputeCountsBestEffort();

    return ImportResult(
      bookmarksImported: bookmarksImported,
      bookmarksMerged: bookmarksMerged,
      bookmarksSkipped: bookmarksSkipped,
      tagsImported: tagsImported,
      collectionsImported: collectionsImported,
      notesImported: notesImported,
      automationRulesImported: automationRulesImported,
      savedSearchesImported: savedSearchesImported,
      remindersImported: remindersImported,
    );
  }

  /// Parses HTML bookmarks (Netscape Bookmark format) and inserts missing entities.
  ///
  /// Offloads DOM parsing of large browser exports (e.g. Firefox files with
  /// inline base64 icons) to a background isolate and commits all bookmarks in
  /// a single atomic batch transaction so reactive feeds update immediately.
  Future<ImportResult> importHtmlBookmarks(String htmlString) async {
    const int isolateThresholdChars = 16 * 1024;
    final List<NetscapeBookmarkEntry> entries =
        htmlString.length > isolateThresholdChars
            ? await Isolate.run<List<NetscapeBookmarkEntry>>(
                () => const NetscapeBookmarkParser().parse(htmlString),
              )
            : const NetscapeBookmarkParser().parse(htmlString);

    int bookmarksImported = 0;
    int bookmarksMerged = 0;
    int bookmarksSkipped = 0;
    int tagsImported = 0;
    int collectionsImported = 0;

    final Map<String, int> folderToCollectionId = <String, int>{};
    final Map<String, int> tagNameToId = <String, int>{};
    // Deduplicate identical URLs appearing in multiple folders within the same
    // HTML file before committing so Isar's unique urlHash index never collides.
    final Map<String, int> pendingIndexByHash = <String, int>{};
    final List<Bookmark> toSave = <Bookmark>[];
    final List<bool> isNewFlags = <bool>[];

    final DateTime now = DateTime.now();

    for (final NetscapeBookmarkEntry entry in entries) {
      final String? canonicalUrl = _normalizer.normalize(entry.url);
      if (canonicalUrl == null) {
        bookmarksSkipped++;
        continue;
      }

      final String urlHash = _hasher.hash(canonicalUrl);
      final String? externalContentId =
          _contentIdExtractor.extract(canonicalUrl);

      // Resolve collection from folder
      final List<int> collectionIds = <int>[];
      if (entry.folder != null && entry.folder!.trim().isNotEmpty) {
        final String folder = entry.folder!.trim();
        if (!folderToCollectionId.containsKey(folder)) {
          final BookmarkCollection? existing =
              await _collections.findBySlug(BookmarkCollection.slugify(folder));
          if (existing != null && existing.id != null) {
            folderToCollectionId[folder] = existing.id!;
          } else {
            final BookmarkCollection created =
                await _collections.createFromTitle(folder);
            if (created.id != null) {
              folderToCollectionId[folder] = created.id!;
              collectionsImported++;
            }
          }
        }
        final int? collId = folderToCollectionId[folder];
        if (collId != null) collectionIds.add(collId);
      }

      // Resolve tags
      final List<int> tagIds = <int>[];
      for (final String tagName in entry.tags) {
        final String trimmed = tagName.trim();
        if (trimmed.isEmpty) continue;
        if (!tagNameToId.containsKey(trimmed)) {
          final Tag? existing = await _tags.findBySlug(Tag.slugify(trimmed));
          if (existing != null && existing.id != null) {
            tagNameToId[trimmed] = existing.id!;
          } else {
            final Tag created = await _tags.createFromName(trimmed);
            if (created.id != null) {
              tagNameToId[trimmed] = created.id!;
              tagsImported++;
            }
          }
        }
        final int? tId = tagNameToId[trimmed];
        if (tId != null && !tagIds.contains(tId)) tagIds.add(tId);
      }

      final Bookmark incoming = Bookmark(
        originalUrl: entry.url,
        canonicalUrl: canonicalUrl,
        urlHash: urlHash,
        externalContentId: externalContentId,
        title: entry.title,
        normalizedHost: _normalizer.extractNormalizedHost(canonicalUrl),
        contentType: _contentTypeDetector.detect(canonicalUrl),
        faviconUrl: entry.iconUrl,
        collectionIds: collectionIds,
        tagIds: tagIds,
        createdAt: entry.createdAt ?? now,
        updatedAt: now,
      );

      final int? pendingIndex = pendingIndexByHash[urlHash];
      if (pendingIndex != null) {
        toSave[pendingIndex] = _mergeService.merge(
          toSave[pendingIndex],
          incoming,
        );
        bookmarksMerged++;
        continue;
      }

      final DuplicateCheckResult duplicate = await _duplicateDetector.check(
        urlHash: urlHash,
        canonicalUrl: canonicalUrl,
        externalContentId: externalContentId,
      );

      if (duplicate.isNew) {
        pendingIndexByHash[urlHash] = toSave.length;
        toSave.add(incoming);
        isNewFlags.add(true);
        bookmarksImported++;
      } else {
        final Bookmark existing = duplicate.existingBookmark!;
        final Bookmark merged = _mergeService.merge(existing, incoming);
        pendingIndexByHash[urlHash] = toSave.length;
        toSave.add(merged);
        isNewFlags.add(false);
        bookmarksMerged++;
      }
    }

    final List<Bookmark> persisted = await _saveBatchBestEffort(toSave);
    final List<int> importedIds = <int>[];
    for (int i = 0; i < persisted.length; i++) {
      final int? id = persisted[i].id;
      if (id != null && i < isNewFlags.length && isNewFlags[i]) {
        importedIds.add(id);
      }
    }

    await _recomputeCountsBestEffort();

    return ImportResult(
      bookmarksImported: bookmarksImported,
      bookmarksMerged: bookmarksMerged,
      bookmarksSkipped: bookmarksSkipped,
      tagsImported: tagsImported,
      collectionsImported: collectionsImported,
      importedBookmarkIds: importedIds,
    );
  }

  Future<List<Bookmark>> _saveBatchBestEffort(List<Bookmark> bookmarks) async {
    if (bookmarks.isEmpty) return const <Bookmark>[];
    try {
      return await _bookmarks.saveAll(bookmarks);
    } on UnimplementedError {
      final List<Bookmark> saved = <Bookmark>[];
      for (final Bookmark bookmark in bookmarks) {
        saved.add(await _bookmarks.save(bookmark));
      }
      return saved;
    }
  }

  Future<void> _recomputeCountsBestEffort() async {
    try {
      await _tags.recomputeAllUsageCounts();
    } on Object {
      // Some unit-test fakes throw UnimplementedError for recompute; ignore.
    }
    try {
      await _collections.recomputeAllItemCounts();
    } on Object {
      // Some unit-test fakes throw UnimplementedError for recompute; ignore.
    }
  }

  Future<int?> _resolveBookmarkId({
    required String? urlHash,
    required String? originalUrl,
    required Map<String, int> cache,
  }) async {
    if (urlHash != null && cache.containsKey(urlHash)) {
      return cache[urlHash];
    }
    if (originalUrl != null && originalUrl.trim().isNotEmpty) {
      final String? canonical = _normalizer.normalize(originalUrl);
      if (canonical != null) {
        final String h = _hasher.hash(canonical);
        if (cache.containsKey(h)) return cache[h];
        final Bookmark? found = await _bookmarks.findByUrlHash(h);
        if (found?.id != null) {
          cache[h] = found!.id!;
          return found.id;
        }
      }
    }
    if (urlHash != null && urlHash.isNotEmpty) {
      final Bookmark? found = await _bookmarks.findByUrlHash(urlHash);
      if (found?.id != null) {
        cache[urlHash] = found!.id!;
        return found.id;
      }
    }
    return null;
  }

  static Bookmark? _bookmarkFromJson(
    Map<String, dynamic> m, {
    required Map<String, int> tagSlugToId,
    required Map<int, int> oldTagIdToNewId,
    required Map<String, int> collectionSlugToId,
    required Map<int, int> oldCollectionIdToNewId,
  }) {
    final String url = ((m['originalUrl'] as String?) ?? '').trim();
    if (url.isEmpty) return null;

    final String? rawCanonical = (m['canonicalUrl'] as String?)?.trim();
    final String? canonicalUrl = rawCanonical != null && rawCanonical.isNotEmpty
        ? _normalizer.normalize(rawCanonical) ?? _normalizer.normalize(url)
        : _normalizer.normalize(url);
    if (canonicalUrl == null) return null;

    final String urlHash = _hasher.hash(canonicalUrl);
    final String? normalizedHost = (m['normalizedHost'] as String?) ??
        _normalizer.extractNormalizedHost(canonicalUrl);
    final String? externalContentId = (m['externalContentId'] as String?) ??
        _contentIdExtractor.extract(canonicalUrl);
    final BookmarkContentType contentType =
        (m['contentType'] as String?) == null
            ? _contentTypeDetector.detect(canonicalUrl)
            : _parseContentType(m['contentType'] as String?);
    final DateTime now = DateTime.now();

    final List<int> resolvedTagIds = _resolveRemappedIds(
      slugsRaw: m['tagSlugs'],
      idsRaw: m['tagIds'],
      slugToId: tagSlugToId,
      oldIdToNewId: oldTagIdToNewId,
    );
    final List<int> resolvedCollectionIds = _resolveRemappedIds(
      slugsRaw: m['collectionSlugs'],
      idsRaw: m['collectionIds'],
      slugToId: collectionSlugToId,
      oldIdToNewId: oldCollectionIdToNewId,
    );

    return Bookmark(
      originalUrl: url,
      canonicalUrl: canonicalUrl,
      urlHash: urlHash,
      externalContentId: externalContentId,
      title: m['title'] as String?,
      description: m['description'] as String?,
      snippet: m['snippet'] as String?,
      heroImageUrl: m['heroImageUrl'] as String?,
      faviconUrl: m['faviconUrl'] as String?,
      siteName: m['siteName'] as String?,
      author: m['author'] as String?,
      publisher: m['publisher'] as String?,
      publishDate: _tryParseDate(m['publishDate'] as String?),
      languageCode: m['languageCode'] as String?,
      readingTimeMinutes: m['readingTimeMinutes'] as int?,
      contentType: contentType,
      sourceType: _parseSourceType(m['sourceType'] as String?),
      normalizedHost: normalizedHost,
      isFavorite: (m['isFavorite'] as bool?) ?? false,
      isArchived: (m['isArchived'] as bool?) ?? false,
      isPinned: (m['isPinned'] as bool?) ?? false,
      isRead: (m['isRead'] as bool?) ?? false,
      inlineNotes: m['inlineNotes'] as String?,
      tagIds: resolvedTagIds,
      collectionIds: resolvedCollectionIds,
      createdAt: _tryParseDate(m['createdAt'] as String?) ?? now,
      updatedAt: now,
    );
  }

  static List<int> _resolveRemappedIds({
    required dynamic slugsRaw,
    required dynamic idsRaw,
    required Map<String, int> slugToId,
    required Map<int, int> oldIdToNewId,
  }) {
    final List<int> resolved = <int>[];

    if (slugsRaw is List && slugsRaw.isNotEmpty) {
      for (final dynamic item in slugsRaw) {
        if (item is String && slugToId.containsKey(item)) {
          final int mapped = slugToId[item]!;
          if (!resolved.contains(mapped)) resolved.add(mapped);
        }
      }
      if (resolved.isNotEmpty) return resolved;
    }

    for (final int rawId in _parseIntList(idsRaw)) {
      final int mapped = oldIdToNewId[rawId] ?? rawId;
      if (!resolved.contains(mapped)) resolved.add(mapped);
    }
    return resolved;
  }

  static AutomationRule? _ruleFromJson(
    Map<String, dynamic> m, {
    required Map<String, int> tagSlugToId,
    required Map<int, int> oldTagIdToNewId,
    required Map<String, int> collectionSlugToId,
    required Map<int, int> oldCollectionIdToNewId,
  }) {
    final String name = ((m['name'] as String?) ?? '').trim();
    if (name.isEmpty) return null;

    final AutomationTriggerType triggerType = _parseTriggerType(
      m['triggerType'] as String?,
    );
    final String triggerValue = (m['triggerValue'] as String?) ?? '';
    final AutomationTriggerLogic logic =
        (m['triggerLogic'] as String?) == AutomationTriggerLogic.any.name
            ? AutomationTriggerLogic.any
            : AutomationTriggerLogic.all;

    final List<AutomationCondition> conditions = <AutomationCondition>[];
    final dynamic rawConds = m['conditions'];
    if (rawConds is List) {
      for (final dynamic item in rawConds) {
        if (item is! Map<String, dynamic>) continue;
        final AutomationTriggerType cType = _parseTriggerType(
          item['type'] as String?,
        );
        String cVal = (item['value'] as String?) ?? '';
        if (cType == AutomationTriggerType.tagContains) {
          final String? tSlug = item['tagSlug'] as String?;
          if (tSlug != null && tagSlugToId.containsKey(tSlug)) {
            cVal = '${tagSlugToId[tSlug]}';
          } else {
            final int? oldId = int.tryParse(cVal.trim());
            if (oldId != null && oldTagIdToNewId.containsKey(oldId)) {
              cVal = '${oldTagIdToNewId[oldId]}';
            }
          }
        }
        conditions.add(AutomationCondition(type: cType, value: cVal));
      }
    }

    final List<AutomationAction> actions = <AutomationAction>[];
    final dynamic rawActs = m['actions'];
    if (rawActs is List) {
      for (final dynamic item in rawActs) {
        if (item is! Map<String, dynamic>) continue;
        final AutomationActionType aType = _parseActionType(
          item['type'] as String?,
        );
        String aArg = (item['arg'] as String?) ?? '';
        if (aType == AutomationActionType.addTag) {
          final String? tSlug = item['tagSlug'] as String?;
          if (tSlug != null && tagSlugToId.containsKey(tSlug)) {
            aArg = '${tagSlugToId[tSlug]}';
          } else {
            final int? oldId = int.tryParse(aArg.trim());
            if (oldId != null && oldTagIdToNewId.containsKey(oldId)) {
              aArg = '${oldTagIdToNewId[oldId]}';
            }
          }
        } else if (aType == AutomationActionType.addToCollection) {
          final String? cSlug = item['collectionSlug'] as String?;
          if (cSlug != null && collectionSlugToId.containsKey(cSlug)) {
            aArg = '${collectionSlugToId[cSlug]}';
          } else {
            final int? oldId = int.tryParse(aArg.trim());
            if (oldId != null && oldCollectionIdToNewId.containsKey(oldId)) {
              aArg = '${oldCollectionIdToNewId[oldId]}';
            }
          }
        }
        actions.add(AutomationAction(type: aType, arg: aArg));
      }
    }

    final DateTime now = DateTime.now();
    return AutomationRule(
      name: name,
      description: m['description'] as String?,
      enabled: (m['enabled'] as bool?) ?? true,
      triggerType: conditions.isNotEmpty ? conditions.first.type : triggerType,
      triggerValue:
          conditions.isNotEmpty ? conditions.first.value : triggerValue,
      triggerLogic: logic,
      conditions: conditions,
      actions: actions,
      priority: (m['priority'] as int?) ?? 100,
      createdAt: _tryParseDate(m['createdAt'] as String?) ?? now,
      updatedAt: now,
    );
  }

  static DateTime? _tryParseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  static BookmarkContentType _parseContentType(String? s) {
    if (s == null) return BookmarkContentType.article;
    return BookmarkContentType.values.firstWhere(
      (BookmarkContentType e) => e.name == s,
      orElse: () => BookmarkContentType.article,
    );
  }

  static BookmarkSourceType _parseSourceType(String? s) {
    if (s == null) return BookmarkSourceType.manual;
    return BookmarkSourceType.values.firstWhere(
      (BookmarkSourceType e) => e.name == s,
      orElse: () => BookmarkSourceType.manual,
    );
  }

  static CollectionSortMode _parseSortMode(String? s) {
    if (s == null) return CollectionSortMode.newestFirst;
    return CollectionSortMode.values.firstWhere(
      (CollectionSortMode e) => e.name == s,
      orElse: () => CollectionSortMode.newestFirst,
    );
  }

  static AutomationTriggerType _parseTriggerType(String? s) {
    if (s == null) return AutomationTriggerType.domainContains;
    return AutomationTriggerType.values.firstWhere(
      (AutomationTriggerType e) => e.name == s,
      orElse: () => AutomationTriggerType.domainContains,
    );
  }

  static AutomationActionType _parseActionType(String? s) {
    if (s == null) return AutomationActionType.addTag;
    return AutomationActionType.values.firstWhere(
      (AutomationActionType e) => e.name == s,
      orElse: () => AutomationActionType.addTag,
    );
  }

  static ReminderRepeatMode _parseRepeatMode(String? s) {
    if (s == null) return ReminderRepeatMode.none;
    return ReminderRepeatMode.values.firstWhere(
      (ReminderRepeatMode e) => e.name == s,
      orElse: () => ReminderRepeatMode.none,
    );
  }

  static ReminderStatus _parseReminderStatus(String? s) {
    if (s == null) return ReminderStatus.pending;
    return ReminderStatus.values.firstWhere(
      (ReminderStatus e) => e.name == s,
      orElse: () => ReminderStatus.pending,
    );
  }

  static List<int> _parseIntList(dynamic raw) {
    if (raw == null) return <int>[];
    if (raw is! List) return <int>[];
    return raw.whereType<int>().toList();
  }
}
