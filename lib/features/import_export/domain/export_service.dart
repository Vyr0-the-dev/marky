import 'dart:convert';

import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';
import 'package:marky/features/automation/domain/automation_rule_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';
import 'package:marky/features/notes/domain/note.dart';
import 'package:marky/features/notes/domain/note_repository.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';
import 'package:marky/features/search/domain/search_query.dart';
import 'package:marky/features/search/domain/search_query_repository.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

/// Serialises the Marky library into portable JSON (v2) or browser-compatible
/// Netscape Bookmark HTML.
class ExportService {
  const ExportService({
    required BookmarkRepository bookmarkRepository,
    required TagRepository tagRepository,
    required BookmarkCollectionRepository collectionRepository,
    NoteRepository? noteRepository,
    AutomationRuleRepository? automationRuleRepository,
    SearchQueryRepository? searchQueryRepository,
    ReminderRepository? reminderRepository,
  })  : _bookmarks = bookmarkRepository,
        _tags = tagRepository,
        _collections = collectionRepository,
        _notes = noteRepository,
        _automationRules = automationRuleRepository,
        _searchQueries = searchQueryRepository,
        _reminders = reminderRepository;

  final BookmarkRepository _bookmarks;
  final TagRepository _tags;
  final BookmarkCollectionRepository _collections;
  final NoteRepository? _notes;
  final AutomationRuleRepository? _automationRules;
  final SearchQueryRepository? _searchQueries;
  final ReminderRepository? _reminders;
  static const int _exportPageSize = 500;
  static const int currentBackupVersion = 2;

  /// Returns the full JSON v2 backup as a UTF-8 string.
  Future<String> exportAll() async {
    final List<Bookmark> bookmarks = await _exportBookmarks();
    final List<Tag> tags = await _tags.getAll();
    final List<BookmarkCollection> collections =
        await _collections.getAll(includeArchived: true);

    final Map<int, String> tagIdToSlug = <int, String>{
      for (final Tag t in tags)
        if (t.id != null) t.id!: t.slug,
    };
    final Map<int, String> collectionIdToSlug = <int, String>{
      for (final BookmarkCollection c in collections)
        if (c.id != null) c.id!: c.slug,
    };
    final Map<int, Bookmark> bookmarkById = <int, Bookmark>{
      for (final Bookmark b in bookmarks)
        if (b.id != null) b.id!: b,
    };

    final List<Map<String, dynamic>> serializedNotes = <Map<String, dynamic>>[];
    if (_notes != null) {
      for (final Bookmark b in bookmarks) {
        final int? bid = b.id;
        if (bid == null) continue;
        final List<Note> bookmarkNotes = await _notes.getByBookmarkId(bid);
        for (final Note n in bookmarkNotes) {
          serializedNotes.add(<String, dynamic>{
            'bookmarkUrlHash': b.urlHash,
            'bookmarkOriginalUrl': b.originalUrl,
            'content': n.content,
            'createdAt': n.createdAt.toIso8601String(),
            'updatedAt': n.updatedAt.toIso8601String(),
          });
        }
      }
    }

    final List<AutomationRule> rules = _automationRules == null
        ? const <AutomationRule>[]
        : await _automationRules.getAll();
    final List<SearchQuery> savedSearches = _searchQueries == null
        ? const <SearchQuery>[]
        : await _searchQueries.getSaved();
    final List<Reminder> activeReminders = _reminders == null
        ? const <Reminder>[]
        : await _reminders.getAllActive();

    final Map<String, dynamic> envelope = <String, dynamic>{
      'version': currentBackupVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'bookmarks': bookmarks
          .map(
            (Bookmark b) => _bookmarkToJson(
              b,
              tagIdToSlug: tagIdToSlug,
              collectionIdToSlug: collectionIdToSlug,
            ),
          )
          .toList(),
      'tags': tags.map(_tagToJson).toList(),
      'collections': collections
          .map(
            (BookmarkCollection c) => _collectionToJson(
              c,
              tagIdToSlug: tagIdToSlug,
            ),
          )
          .toList(),
      'notes': serializedNotes,
      'automationRules': rules
          .map(
            (AutomationRule r) => _ruleToJson(
              r,
              tagIdToSlug: tagIdToSlug,
              collectionIdToSlug: collectionIdToSlug,
            ),
          )
          .toList(),
      'savedSearches': savedSearches.map(_searchQueryToJson).toList(),
      'reminders': activeReminders
          .where((Reminder r) => bookmarkById.containsKey(r.bookmarkId))
          .map(
            (Reminder r) => _reminderToJson(
              r,
              bookmarkById[r.bookmarkId]!,
            ),
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  /// Exports bookmarks in browser-compatible Netscape Bookmark HTML format
  /// (Chrome, Firefox, Safari, Pocket compatible).
  Future<String> exportNetscapeHtml() async {
    final List<Bookmark> bookmarks = await _exportBookmarks();
    final List<Tag> tags = await _tags.getAll();
    final List<BookmarkCollection> collections =
        await _collections.getAll(includeArchived: true);

    final Map<int, String> tagNameById = <int, String>{
      for (final Tag t in tags)
        if (t.id != null) t.id!: t.name,
    };
    final Map<int, BookmarkCollection> manualCollections =
        <int, BookmarkCollection>{
      for (final BookmarkCollection c in collections)
        if (c.id != null && !c.isSmart) c.id!: c,
    };

    final Map<int, List<Bookmark>> byCollection = <int, List<Bookmark>>{};
    final List<Bookmark> uncategorized = <Bookmark>[];

    for (final Bookmark b in bookmarks) {
      final List<int> validColls =
          b.collectionIds.where(manualCollections.containsKey).toList();
      if (validColls.isEmpty) {
        uncategorized.add(b);
      } else {
        for (final int cid in validColls) {
          byCollection.putIfAbsent(cid, () => <Bookmark>[]).add(b);
        }
      }
    }

    final StringBuffer out = StringBuffer()
      ..writeln('<!DOCTYPE NETSCAPE-Bookmark-file-1>')
      ..writeln('<!-- Exported by Marky -->')
      ..writeln(
        '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">',
      )
      ..writeln('<TITLE>Marky Bookmarks</TITLE>')
      ..writeln('<H1>Marky Bookmarks</H1>')
      ..writeln('<DL><p>');

    for (final Bookmark b in uncategorized) {
      out.writeln(_bookmarkHtmlLine(b, tagNameById, indent: '    '));
    }

    for (final MapEntry<int, List<Bookmark>> entry in byCollection.entries) {
      final BookmarkCollection? coll = manualCollections[entry.key];
      if (coll == null) continue;
      final int addDate = coll.createdAt.millisecondsSinceEpoch ~/ 1000;
      out
        ..writeln(
          '    <DT><H3 ADD_DATE="$addDate">${_escapeHtml(coll.title)}</H3>',
        )
        ..writeln('    <DL><p>');
      for (final Bookmark b in entry.value) {
        out.writeln(_bookmarkHtmlLine(b, tagNameById, indent: '        '));
      }
      out.writeln('    </DL><p>');
    }

    out.writeln('</DL><p>');
    return out.toString();
  }

  Future<List<Bookmark>> _exportBookmarks() async {
    final List<Bookmark> active = await _exportBookmarkPageSet(
      const BookmarkFeedQuery(
        limit: _exportPageSize,
      ),
    );
    final List<Bookmark> archived = await _exportBookmarkPageSet(
      const BookmarkFeedQuery(
        filter: BookmarkFeedFilter.archived,
        limit: _exportPageSize,
      ),
    );
    return <Bookmark>[...active, ...archived];
  }

  Future<List<Bookmark>> _exportBookmarkPageSet(BookmarkFeedQuery base) async {
    final List<Bookmark> all = <Bookmark>[];
    int offset = 0;
    while (true) {
      final List<Bookmark> page = await _bookmarks.feed(
        base.copyWith(offset: offset),
      );
      if (page.isEmpty) break;
      all.addAll(page);
      if (page.length < _exportPageSize) break;
      offset += page.length;
    }
    return all;
  }

  static String _bookmarkHtmlLine(
    Bookmark b,
    Map<int, String> tagNameById, {
    required String indent,
  }) {
    final String href = _escapeHtml(b.canonicalUrl ?? b.originalUrl);
    final String title = _escapeHtml(b.displayTitle);
    final int addDate = b.createdAt.millisecondsSinceEpoch ~/ 1000;
    final List<String> tagNames = b.tagIds
        .map((int id) => tagNameById[id])
        .whereType<String>()
        .where((String s) => s.isNotEmpty)
        .toList();
    final String tagsAttr = tagNames.isEmpty
        ? ''
        : ' TAGS="${_escapeHtml(tagNames.join(','))}"';
    return '$indent<DT><A HREF="$href" ADD_DATE="$addDate"$tagsAttr>$title</A>';
  }

  static String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

  static Map<String, dynamic> _bookmarkToJson(
    Bookmark b, {
    required Map<int, String> tagIdToSlug,
    required Map<int, String> collectionIdToSlug,
  }) {
    final List<String> tagSlugs = b.tagIds
        .map((int id) => tagIdToSlug[id])
        .whereType<String>()
        .toList();
    final List<String> collectionSlugs = b.collectionIds
        .map((int id) => collectionIdToSlug[id])
        .whereType<String>()
        .toList();

    return <String, dynamic>{
      'originalUrl': b.originalUrl,
      'canonicalUrl': b.canonicalUrl,
      'urlHash': b.urlHash,
      'externalContentId': b.externalContentId,
      'title': b.title,
      'description': b.description,
      'snippet': b.snippet,
      'heroImageUrl': b.heroImageUrl,
      'faviconUrl': b.faviconUrl,
      'siteName': b.siteName,
      'author': b.author,
      'publisher': b.publisher,
      'publishDate': b.publishDate?.toIso8601String(),
      'languageCode': b.languageCode,
      'readingTimeMinutes': b.readingTimeMinutes,
      'contentType': b.contentType.name,
      'sourceType': b.sourceType.name,
      'normalizedHost': b.normalizedHost,
      'isFavorite': b.isFavorite,
      'isArchived': b.isArchived,
      'isPinned': b.isPinned,
      'isRead': b.isRead,
      'inlineNotes': b.inlineNotes,
      'tagIds': b.tagIds,
      'tagSlugs': tagSlugs,
      'collectionIds': b.collectionIds,
      'collectionSlugs': collectionSlugs,
      'createdAt': b.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _tagToJson(Tag t) {
    return <String, dynamic>{
      if (t.id != null) 'id': t.id,
      'name': t.name,
      'slug': t.slug,
      'colorArgb': t.colorArgb,
      'icon': t.icon,
      'description': t.description,
      'isPinned': t.isPinned,
      'orderIndex': t.orderIndex,
      'createdAt': t.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _collectionToJson(
    BookmarkCollection c, {
    required Map<int, String> tagIdToSlug,
  }) {
    String? smartRuleTagSlug;
    if (c.isSmart && c.smartRuleJson != null) {
      try {
        final SmartCollectionRule rule =
            SmartCollectionRule.decode(c.smartRuleJson!);
        if (rule.tagId != null) {
          smartRuleTagSlug = tagIdToSlug[rule.tagId!];
        }
      } on Object {
        smartRuleTagSlug = null;
      }
    }

    return <String, dynamic>{
      if (c.id != null) 'id': c.id,
      'title': c.title,
      'slug': c.slug,
      'description': c.description,
      'icon': c.icon,
      'accentColorArgb': c.accentColorArgb,
      'isPinned': c.isPinned,
      'isArchived': c.isArchived,
      'sortMode': c.sortMode.name,
      'orderIndex': c.orderIndex,
      'isSmart': c.isSmart,
      'smartRuleJson': c.smartRuleJson,
      if (smartRuleTagSlug != null) 'smartRuleTagSlug': smartRuleTagSlug,
      'createdAt': c.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _ruleToJson(
    AutomationRule r, {
    required Map<int, String> tagIdToSlug,
    required Map<int, String> collectionIdToSlug,
  }) {
    return <String, dynamic>{
      'name': r.name,
      'description': r.description,
      'enabled': r.enabled,
      'triggerType': r.triggerType.name,
      'triggerValue': r.triggerValue,
      'triggerLogic': r.triggerLogic.name,
      'conditions': r.conditions.map((AutomationCondition cond) {
        final Map<String, dynamic> out = <String, dynamic>{
          'type': cond.type.name,
          'value': cond.value,
        };
        if (cond.type == AutomationTriggerType.tagContains) {
          final int? tid = int.tryParse(cond.value.trim());
          if (tid != null && tagIdToSlug.containsKey(tid)) {
            out['tagSlug'] = tagIdToSlug[tid];
          }
        }
        return out;
      }).toList(),
      'actions': r.actions.map((AutomationAction act) {
        final Map<String, dynamic> out = <String, dynamic>{
          'type': act.type.name,
          'arg': act.arg,
        };
        if (act.type == AutomationActionType.addTag) {
          final int? tid = int.tryParse(act.arg.trim());
          if (tid != null && tagIdToSlug.containsKey(tid)) {
            out['tagSlug'] = tagIdToSlug[tid];
          }
        } else if (act.type == AutomationActionType.addToCollection) {
          final int? cid = int.tryParse(act.arg.trim());
          if (cid != null && collectionIdToSlug.containsKey(cid)) {
            out['collectionSlug'] = collectionIdToSlug[cid];
          }
        }
        return out;
      }).toList(),
      'priority': r.priority,
      'createdAt': r.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _searchQueryToJson(SearchQuery q) {
    return <String, dynamic>{
      'query': q.query,
      'label': q.label,
      'isSaved': q.isSaved,
      'createdAt': q.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _reminderToJson(Reminder r, Bookmark b) {
    return <String, dynamic>{
      'bookmarkUrlHash': b.urlHash,
      'bookmarkOriginalUrl': b.originalUrl,
      'title': r.title,
      'body': r.body,
      'scheduledAt': r.scheduledAt.toIso8601String(),
      'timezone': r.timezone,
      'repeatMode': r.repeatMode.name,
      'status': r.status.name,
      'snoozedUntil': r.snoozedUntil?.toIso8601String(),
      'createdAt': r.createdAt.toIso8601String(),
    };
  }
}
