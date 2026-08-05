import 'dart:convert';
import 'dart:io';

import 'package:marky/features/import_export/data/services/share_platform.dart';
import 'package:marky/features/import_export/domain/models/export_data.dart';
import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/note.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:marky/shared/models/tag.dart';
import 'package:path/path.dart' as p;

/// Service that serializes [ExportData] to JSON, strips device-local paths,
/// adds schema metadata, writes to a temp file, and triggers the share sheet.
class ExportService {
  ExportService({
    required SharePlatform sharePlatform,
    required Future<Directory> Function() getTempDirectory,
  })  : _sharePlatform = sharePlatform,
        _getTempDirectory = getTempDirectory;

  final SharePlatform _sharePlatform;
  final Future<Directory> Function() _getTempDirectory;

  /// Serializes [data] to JSON and shares the resulting file.
  ///
  /// Returns the generated file path on success.
  /// Throws on serialization, file I/O, or share errors.
  Future<String> exportAndShare(ExportData data) async {
    final jsonMap = _buildJsonMap(data);
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);

    final tempDir = await _getTempDirectory();
    final fileName = 'marky_export_${_formatTimestamp(data.exportTimestamp)}.json';
    final filePath = p.join(tempDir.path, fileName);

    final file = File(filePath);
    await file.writeAsString(jsonString, flush: true);

    await _sharePlatform.shareFile(
      filePath,
      subject: 'Marky Export',
    );

    return filePath;
  }

  Map<String, dynamic> _buildJsonMap(ExportData data) {
    return <String, dynamic>{
      'version': 'marky_export_v1',
      'exportedAt': data.exportTimestamp.toUtc().toIso8601String(),
      'schemaVersion': data.schemaVersion,
      'bookmarks': data.bookmarks.map(_bookmarkToJson).toList(),
      'tags': data.tags.map(_tagToJson).toList(),
      'collections': data.collections.map(_collectionToJson).toList(),
      'notes': data.notes.map(_noteToJson).toList(),
      'reminders': data.reminders.map(_reminderToJson).toList(),
      if (data.settings != null) 'settings': _settingsToJson(data.settings!),
    };
  }

  Map<String, dynamic> _bookmarkToJson(BookmarkItem b) {
    return <String, dynamic>{
      'id': b.id,
      'originalUrl': b.originalUrl,
      if (b.sharedText != null) 'sharedText': b.sharedText,
      if (b.cleanedUrl != null) 'cleanedUrl': b.cleanedUrl,
      if (b.resolvedUrl != null) 'resolvedUrl': b.resolvedUrl,
      if (b.canonicalUrl != null) 'canonicalUrl': b.canonicalUrl,
      if (b.normalizedHost != null) 'normalizedHost': b.normalizedHost,
      if (b.urlHash != null) 'urlHash': b.urlHash,
      if (b.externalContentId != null) 'externalContentId': b.externalContentId,
      if (b.title != null) 'title': b.title,
      if (b.description != null) 'description': b.description,
      if (b.snippet != null) 'snippet': b.snippet,
      if (b.extractedText != null) 'extractedText': b.extractedText,
      if (b.author != null) 'author': b.author,
      if (b.publisher != null) 'publisher': b.publisher,
      if (b.siteName != null) 'siteName': b.siteName,
      if (b.sourceDomain != null) 'sourceDomain': b.sourceDomain,
      if (b.sourceType != null) 'sourceType': b.sourceType,
      if (b.contentType != null) 'contentType': b.contentType,
      if (b.languageCode != null) 'languageCode': b.languageCode,
      if (b.thumbnailUrl != null) 'thumbnailUrl': b.thumbnailUrl,
      // localThumbnailPath intentionally omitted — device-local
      if (b.dominantColorHex != null) 'dominantColorHex': b.dominantColorHex,
      if (b.heroImageUrl != null) 'heroImageUrl': b.heroImageUrl,
      // heroImageLocalPath intentionally omitted — device-local
      if (b.faviconUrl != null) 'faviconUrl': b.faviconUrl,
      // localFaviconPath intentionally omitted — device-local
      if (b.videoThumbnailUrl != null) 'videoThumbnailUrl': b.videoThumbnailUrl,
      if (b.publishDate != null) 'publishDate': b.publishDate!.toUtc().toIso8601String(),
      if (b.tagIds != null) 'tagIds': b.tagIds,
      if (b.collectionIds != null) 'collectionIds': b.collectionIds,
      if (b.noteIds != null) 'noteIds': b.noteIds,
      if (b.reminderIds != null) 'reminderIds': b.reminderIds,
      'isFavorite': b.isFavorite,
      'isArchived': b.isArchived,
      'isDeleted': b.isDeleted,
      'isRead': b.isRead,
      'isInVault': b.isInVault,
      'isPinned': b.isPinned,
      'createdAt': b.createdAt.toUtc().toIso8601String(),
      'updatedAt': b.updatedAt.toUtc().toIso8601String(),
      if (b.lastOpenedAt != null) 'lastOpenedAt': b.lastOpenedAt!.toUtc().toIso8601String(),
      if (b.lastSharedAt != null) 'lastSharedAt': b.lastSharedAt!.toUtc().toIso8601String(),
      if (b.lastInteractionAt != null)
        'lastInteractionAt': b.lastInteractionAt!.toUtc().toIso8601String(),
      if (b.readProgress != null) 'readProgress': b.readProgress,
      if (b.readingTimeMinutes != null) 'readingTimeMinutes': b.readingTimeMinutes,
      if (b.duplicateGroupId != null) 'duplicateGroupId': b.duplicateGroupId,
      if (b.extractionStatus != null) 'extractionStatus': b.extractionStatus,
      'scrapingStatus': b.scrapingStatus.name,
      'thumbnailStatus': b.thumbnailStatus.name,
      'faviconStatus': b.faviconStatus.name,
      if (b.localCacheStatus != null) 'localCacheStatus': b.localCacheStatus,
      if (b.syncStatus != null) 'syncStatus': b.syncStatus,
      if (b.sourceApp != null) 'sourceApp': b.sourceApp,
      if (b.sourceDeviceInfo != null) 'sourceDeviceInfo': b.sourceDeviceInfo,
      if (b.importSource != null) 'importSource': b.importSource,
      'openCount': b.openCount,
      if (b.aiSummary != null) 'aiSummary': b.aiSummary,
      if (b.aiKeywords != null) 'aiKeywords': b.aiKeywords,
      if (b.aiCategory != null) 'aiCategory': b.aiCategory,
      if (b.aiSentiment != null) 'aiSentiment': b.aiSentiment,
      if (b.aiClusterId != null) 'aiClusterId': b.aiClusterId,
      if (b.aiEmbeddingRef != null) 'aiEmbeddingRef': b.aiEmbeddingRef,
      if (b.customMetadataJson != null) 'customMetadataJson': b.customMetadataJson,
    };
  }

  Map<String, dynamic> _tagToJson(Tag t) {
    return <String, dynamic>{
      'id': t.id,
      'name': t.name,
      'slug': t.slug,
      if (t.color != null) 'color': t.color,
      if (t.icon != null) 'icon': t.icon,
      if (t.description != null) 'description': t.description,
      'createdAt': t.createdAt.toUtc().toIso8601String(),
      'updatedAt': t.updatedAt.toUtc().toIso8601String(),
      'usageCount': t.usageCount,
      'isSystemTag': t.isSystemTag,
      'isSmartTag': t.isSmartTag,
      if (t.ruleJson != null) 'ruleJson': t.ruleJson,
      'orderIndex': t.orderIndex,
    };
  }

  Map<String, dynamic> _collectionToJson(BookmarkCollection c) {
    return <String, dynamic>{
      'id': c.id,
      'title': c.title,
      'slug': c.slug,
      if (c.description != null) 'description': c.description,
      if (c.icon != null) 'icon': c.icon,
      if (c.accentColor != null) 'accentColor': c.accentColor,
      if (c.coverMode != null) 'coverMode': c.coverMode,
      if (c.coverImageUrl != null) 'coverImageUrl': c.coverImageUrl,
      // coverLocalPath intentionally omitted — device-local
      'isPinned': c.isPinned,
      'isArchived': c.isArchived,
      'isSmartCollection': c.isSmartCollection,
      if (c.smartRuleJson != null) 'smartRuleJson': c.smartRuleJson,
      'itemCount': c.itemCount,
      if (c.sortMode != null) 'sortMode': c.sortMode,
      'createdAt': c.createdAt.toUtc().toIso8601String(),
      'updatedAt': c.updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> _noteToJson(Note n) {
    return <String, dynamic>{
      'id': n.id,
      'bookmarkId': n.bookmarkId,
      'content': n.content,
      'contentFormat': n.contentFormat,
      'createdAt': n.createdAt.toUtc().toIso8601String(),
      'updatedAt': n.updatedAt.toUtc().toIso8601String(),
      'isPinned': n.isPinned,
      if (n.colorLabel != null) 'colorLabel': n.colorLabel,
    };
  }

  Map<String, dynamic> _reminderToJson(Reminder r) {
    return <String, dynamic>{
      'id': r.id,
      'bookmarkId': r.bookmarkId,
      'title': r.title,
      if (r.body != null) 'body': r.body,
      'scheduledAt': r.scheduledAt.toUtc().toIso8601String(),
      'timezone': r.timezone,
      'repeatMode': r.repeatMode,
      if (r.repeatRule != null) 'repeatRule': r.repeatRule,
      if (r.notificationId != null) 'notificationId': r.notificationId,
      'status': r.status,
      'createdAt': r.createdAt.toUtc().toIso8601String(),
      if (r.completedAt != null) 'completedAt': r.completedAt!.toUtc().toIso8601String(),
      if (r.snoozedUntil != null) 'snoozedUntil': r.snoozedUntil!.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> _settingsToJson(AppSettings s) {
    return <String, dynamic>{
      'id': s.id,
      'themeMode': s.themeMode,
      'accentColor': s.accentColor,
      'dynamicColorEnabled': s.dynamicColorEnabled,
      'oledPureBlackEnabled': s.oledPureBlackEnabled,
      'gridDensity': s.gridDensity,
      'defaultLayoutMode': s.defaultLayoutMode,
      'defaultOpenBehavior': s.defaultOpenBehavior,
      'hapticsEnabled': s.hapticsEnabled,
      'animationsEnabled': s.animationsEnabled,
      'clipboardDetectionEnabled': s.clipboardDetectionEnabled,
      if (s.autoArchiveDays != null) 'autoArchiveDays': s.autoArchiveDays,
      if (s.autoDeleteDays != null) 'autoDeleteDays': s.autoDeleteDays,
      'backupEnabled': s.backupEnabled,
      if (s.backupTarget != null) 'backupTarget': s.backupTarget,
      'backupEncryptionEnabled': s.backupEncryptionEnabled,
      'aiEnabled': s.aiEnabled,
      'localAiOnlyMode': s.localAiOnlyMode,
      'languagePreference': s.languagePreference,
      'analyticsEnabled': s.analyticsEnabled,
      'crashLogsEnabled': s.crashLogsEnabled,
      if (s.recentSearches != null) 'recentSearches': s.recentSearches,
    };
  }

  String _formatTimestamp(DateTime dt) {
    final utc = dt.toUtc();
    return '${utc.year}${_two(utc.month)}${_two(utc.day)}_${_two(utc.hour)}${_two(utc.minute)}${_two(utc.second)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
