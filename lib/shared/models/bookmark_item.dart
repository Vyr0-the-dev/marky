import 'package:isar/isar.dart';
import 'package:marky/core/scraping/enums/favicon_status.dart';
import 'package:marky/core/scraping/enums/scraping_status.dart';
import 'package:marky/core/scraping/enums/thumbnail_status.dart';

part 'bookmark_item.g.dart';

/// The core bookmark entity representing a saved link and its enriched metadata.
///
/// This is the most complex collection in Marky. It stores everything from the
/// raw captured URL through AI-generated enrichment, status flags, and local
/// cache state.
@collection
class BookmarkItem {
  BookmarkItem({
    required this.originalUrl,
    this.sharedText,
    this.cleanedUrl,
    this.resolvedUrl,
    this.canonicalUrl,
    this.normalizedHost,
    this.urlHash,
    this.externalContentId,
    this.title,
    this.description,
    this.snippet,
    this.extractedText,
    this.author,
    this.publisher,
    this.siteName,
    this.sourceDomain,
    this.sourceType,
    this.contentType,
    this.languageCode,
    this.thumbnailUrl,
    this.localThumbnailPath,
    this.heroImageUrl,
    this.heroImageLocalPath,
    this.faviconUrl,
    this.localFaviconPath,
    this.videoThumbnailUrl,
    this.publishDate,
    this.tagIds,
    this.collectionIds,
    this.noteIds,
    this.isFavorite = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.isRead = false,
    this.isInVault = false,
    this.isPinned = false,
    this.reminderIds,
    required this.createdAt,
    required this.updatedAt,
    this.lastOpenedAt,
    this.lastSharedAt,
    this.lastInteractionAt,
    this.readProgress,
    this.readingTimeMinutes,
    this.duplicateGroupId,
    this.extractionStatus,
    this.scrapingStatus = ScrapingStatus.pending,
    this.thumbnailStatus = ThumbnailStatus.pending,
    this.faviconStatus = FaviconStatus.pending,
    this.localCacheStatus,
    this.syncStatus,
    this.sourceApp,
    this.sourceDeviceInfo,
    this.importSource,
    this.openCount = 0,
    this.aiSummary,
    this.aiKeywords,
    this.aiCategory,
    this.aiSentiment,
    this.aiClusterId,
    this.aiEmbeddingRef,
    this.customMetadataJson,
  });

  /// Auto-increment primary key.
  Id id = Isar.autoIncrement;

  // ─── URL fields ────────────────────────────────────────────────────────

  /// The raw URL as it was shared or captured.
  String originalUrl;

  /// Optional text that accompanied the shared link (e.g. tweet text).
  String? sharedText;

  /// URL after basic cleanup (trim, decode, etc.).
  String? cleanedUrl;

  /// Final resolved URL after following redirects.
  String? resolvedUrl;

  /// Canonical URL extracted from the page or API.
  @Index()
  String? canonicalUrl;

  /// Normalized host name used for grouping and filtering (e.g. 'youtube.com').
  @Index()
  String? normalizedHost;

  /// Hash of the canonical URL for fast duplicate detection.
  @Index()
  String? urlHash;

  /// External platform content ID (e.g. YouTube video ID, tweet ID).
  String? externalContentId;

  // ─── Content metadata ──────────────────────────────────────────────────

  /// Page title.
  String? title;

  /// Meta description or Open Graph description.
  String? description;

  /// Short auto-generated or user-edited snippet.
  String? snippet;

  /// Full text extracted from the page body.
  String? extractedText;

  /// Content author name.
  String? author;

  /// Publishing entity.
  String? publisher;

  /// Site name from Open Graph or meta tags.
  String? siteName;

  /// Top-level domain extracted from URL.
  String? sourceDomain;

  /// Source classification: 'manual', 'share_sheet', 'clipboard', 'import'.
  String? sourceType;

  /// Detected content type: 'article', 'video', 'image', 'product', etc.
  String? contentType;

  /// ISO language code detected from content.
  String? languageCode;

  // ─── Media assets ──────────────────────────────────────────────────────

  /// Remote thumbnail image URL.
  String? thumbnailUrl;

  /// Local file path for cached thumbnail.
  String? localThumbnailPath;

  /// Dominant color hex code extracted from the thumbnail image.
  String? dominantColorHex;

  /// Remote hero / featured image URL.
  String? heroImageUrl;

  /// Local file path for cached hero image.
  String? heroImageLocalPath;

  /// Remote favicon URL.
  String? faviconUrl;

  /// Local file path for cached favicon.
  String? localFaviconPath;

  /// Video-specific thumbnail URL.
  String? videoThumbnailUrl;

  /// Original publication date if available.
  DateTime? publishDate;

  // ─── Relationships (ID references) ─────────────────────────────────────

  /// IDs of attached tags.
  List<int>? tagIds;

  /// IDs of collections this item belongs to.
  List<int>? collectionIds;

  /// IDs of attached notes.
  List<int>? noteIds;

  /// IDs of associated reminders.
  List<int>? reminderIds;

  // ─── Status flags ──────────────────────────────────────────────────────

  /// Whether the item is starred / favorited.
  @Index()
  bool isFavorite;

  /// Whether the item is archived (hidden from main feed).
  @Index(
    name: 'isArchived_isInVault_createdAt',
    composite: [
      CompositeIndex('isInVault'),
      CompositeIndex('createdAt'),
    ],
  )
  bool isArchived;

  /// Soft-delete flag. True means pending permanent deletion.
  bool isDeleted;

  /// Whether the user has opened / read this item.
  @Index()
  bool isRead;

  /// Whether the item is stored in the protected vault.
  @Index()
  bool isInVault;

  /// Whether the item is pinned to the top of lists.
  bool isPinned;

  // ─── Timestamps ────────────────────────────────────────────────────────

  /// When the bookmark was first created.
  @Index()
  DateTime createdAt;

  /// When the bookmark was last modified.
  DateTime updatedAt;

  /// When the user last opened this bookmark.
  DateTime? lastOpenedAt;

  /// When the bookmark was last shared outward.
  DateTime? lastSharedAt;

  /// Last time the user interacted with this item (open, edit, tag, etc.).
  DateTime? lastInteractionAt;

  // ─── Reading state ─────────────────────────────────────────────────────

  /// Progress between 0.0 and 1.0 for long-form content.
  double? readProgress;

  /// Estimated reading time in minutes.
  int? readingTimeMinutes;

  // ─── Deduplication ─────────────────────────────────────────────────────

  /// Group ID linking duplicates of the same URL together.
  String? duplicateGroupId;

  // ─── Processing status ─────────────────────────────────────────────────

  /// Text extraction status: 'pending', 'processing', 'done', 'failed'.
  String? extractionStatus;

  /// Scraping status: 'pending', 'processing', 'done', 'failed'.
  @enumerated
  ScrapingStatus scrapingStatus;

  /// Thumbnail download/cache status: 'pending', 'processing', 'done', 'failed'.
  @enumerated
  ThumbnailStatus thumbnailStatus = ThumbnailStatus.pending;

  /// Favicon download/cache status: 'pending', 'processing', 'done', 'failed'.
  @enumerated
  FaviconStatus faviconStatus = FaviconStatus.pending;

  /// Local asset cache status: 'pending', 'cached', 'failed'.
  String? localCacheStatus;

  /// Cloud sync status: 'local', 'syncing', 'synced', 'conflict'.
  String? syncStatus;

  // ─── Provenance ────────────────────────────────────────────────────────

  /// Name of the app that shared the link to Marky.
  String? sourceApp;

  /// Device info string at time of capture.
  String? sourceDeviceInfo;

  /// Import batch source if this came from an import job.
  String? importSource;

  /// How many times the user has opened this bookmark.
  int openCount;

  // ─── AI enrichment (nullable with defaults to avoid migrations) ────────

  /// AI-generated summary of the content.
  String? aiSummary;

  /// AI-extracted keywords.
  List<String>? aiKeywords;

  /// AI-assigned category.
  String? aiCategory;

  /// AI-detected sentiment: 'positive', 'neutral', 'negative'.
  String? aiSentiment;

  /// ID of the AI clustering group this item belongs to.
  String? aiClusterId;

  /// Reference to a pre-computed embedding vector (stored externally).
  String? aiEmbeddingRef;

  /// Arbitrary JSON string for extensibility.
  String? customMetadataJson;
}
