import 'package:isar/isar.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';

part 'bookmark_entity.g.dart';

/// The core Marky entity — one row per saved link.
///
/// This is intentionally leaner than the legacy `BookmarkItem`. Dropped:
/// - AI enrichment fields (`aiSummary`, `aiKeywords`, `aiCategory`,
///   `aiSentiment`, `aiClusterId`, `aiEmbeddingRef`) — out of scope
///   for the MVP.
/// - Redundant URL variants (`cleanedUrl`, `resolvedUrl`,
///   `sharedText`, `sourceApp`, `sourceDeviceInfo`, `importSource`) —
///   not surfaced anywhere in the UI; canonical + host + hash are
///   enough for dedupe and display.
/// - `isDeleted` soft-delete — we hard-delete. Undo is surfaced via
///   a snackbar "Undo" within the session; true recovery comes from
///   the Google Drive backup (Faz 11), not a tombstone column.
/// - `customMetadataJson` — no caller reads it; YAGNI.
///
/// Fields retained from legacy are documented below with the specific
/// UI / feature that uses them so future simplification passes know
/// what's load-bearing.
@Collection(accessor: 'bookmarks')
class BookmarkEntity {
  BookmarkEntity({
    required this.originalUrl,
    this.canonicalUrl,
    this.normalizedHost,
    this.urlHash,
    this.externalContentId,
    this.title,
    this.description,
    this.snippet,
    this.author,
    this.siteName,
    this.publisher,
    this.publishDate,
    this.languageCode,
    this.contentType = BookmarkContentType.unknown,
    this.sourceType = BookmarkSourceType.manual,
    this.heroImageUrl,
    this.heroImageLocalPath,
    this.faviconUrl,
    this.localFaviconPath,
    this.dominantColorHex,
    this.tagIds = const <int>[],
    this.collectionIds = const <int>[],
    this.reminderIds = const <int>[],
    this.inlineNotes,
    this.isFavorite = false,
    this.isArchived = false,
    this.isRead = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastOpenedAt,
    this.lastInteractionAt,
    this.openCount = 0,
    this.readProgress,
    this.readingTimeMinutes,
    this.scrapingStatus = BookmarkScrapingStatus.pending,
    this.duplicateGroupId,
  });

  Id id = Isar.autoIncrement;

  // ─── URL fields ─────────────────────────────────────────────────

  /// The URL as captured. Never mutated after insert so we can always
  /// show the user what they originally saved, even if scraping later
  /// resolves a different canonical.
  String originalUrl;

  /// Canonical URL after normalisation (strip trackers, follow
  /// redirects, extract `<link rel=canonical>`). Indexed so the
  /// "find bookmark by URL" lookup is O(log n).
  @Index()
  String? canonicalUrl;

  /// Normalised host (e.g. `youtube.com`, never `www.youtube.com`
  /// or `m.youtube.com`). Indexed for domain-based grouping, the
  /// automation engine, and the dashboard's "top domains" widget.
  @Index()
  String? normalizedHost;

  /// SHA-256 of the canonical URL. Indexed for the fast dedupe
  /// probe during capture ("is this URL already in the library?").
  @Index()
  String? urlHash;

  /// Platform-specific content ID extracted from the URL, e.g.
  /// a YouTube video ID or a tweet status id. Used to collapse
  /// "different URL, same content" duplicates (mobile vs desktop
  /// YouTube links). Indexed for fast duplicate detection.
  @Index()
  String? externalContentId;

  // ─── Content metadata ───────────────────────────────────────────

  /// Human-readable title. Falls back to [originalUrl] in the UI if
  /// scraping failed.
  String? title;

  /// Long-form description (meta description / OG description).
  String? description;

  /// Short auto-generated excerpt shown on cards when description is
  /// too long. Truncated to roughly 160 chars by the scraper.
  String? snippet;

  String? author;
  String? siteName;
  String? publisher;

  /// Original publish date extracted from OG / JSON-LD / article
  /// metadata. Used by the dashboard's "freshness" chart.
  DateTime? publishDate;

  /// ISO 639-1 language code (`en`, `tr`, `ja`...). Used for future
  /// per-language filters; scraper writes it but UI doesn't read it
  /// yet at MVP.
  String? languageCode;

  /// Medium classification — picks the card layout.
  @Enumerated(EnumType.name)
  BookmarkContentType contentType;

  /// How the bookmark entered the library.
  @Enumerated(EnumType.name)
  BookmarkSourceType sourceType;

  // ─── Media ──────────────────────────────────────────────────────

  String? heroImageUrl;

  /// Local cache path for the hero image, populated by the download
  /// worker after scrape completes. Nullable so cards can still show
  /// a skeleton while the image is in flight.
  String? heroImageLocalPath;

  String? faviconUrl;
  String? localFaviconPath;

  /// Dominant colour extracted from the hero image (`#RRGGBB`). Used
  /// as a card accent for items whose hero hasn't downloaded yet and
  /// as the empty-state tint in the detail view.
  String? dominantColorHex;

  // ─── Relationships (Id references, not Isar Links) ──────────────
  //
  // Legacy used plain List<int> references rather than Isar's typed
  // Links. V2 keeps that pattern because:
  // - Isar Links are heavier (separate B-tree per link) and we're
  //   joining in-memory anyway at the repository layer.
  // - Backup / export serialises far cleaner with int lists.
  // - Migration-on-rename is trivial (just update the int).

  List<int> tagIds;
  List<int> collectionIds;
  List<int> reminderIds;

  /// Per-bookmark inline notes. Replaces the legacy `Note` collection
  /// — notes are almost always 1:1 with a bookmark, and splitting
  /// them into a separate table added join cost with no UX payoff.
  /// Future: if users ever ask for standalone notes, upgrade to a
  /// dedicated collection.
  String? inlineNotes;

  // ─── Status flags ───────────────────────────────────────────────

  @Index()
  bool isFavorite;

  @Index(
    name: 'isArchived_createdAt',
    composite: <CompositeIndex>[CompositeIndex('createdAt')],
  )
  bool isArchived;

  @Index()
  bool isRead;

  bool isPinned;

  // ─── Timestamps ─────────────────────────────────────────────────

  @Index()
  DateTime createdAt;

  DateTime updatedAt;

  DateTime? lastOpenedAt;

  /// Last time the user touched the bookmark in any way (opened,
  /// retagged, edited). Powers the "recently interacted" sort and
  /// the reading streak widget on the dashboard (Faz 10).
  DateTime? lastInteractionAt;

  // ─── Reading state ──────────────────────────────────────────────

  int openCount;

  /// Fractional reading progress [0.0, 1.0] for long-form content.
  /// Null means "not a long-read" or "never measured".
  double? readProgress;

  /// Estimated reading time in minutes, computed by the scraper from
  /// word count at ~225 wpm. Shown on article cards.
  int? readingTimeMinutes;

  // ─── Processing status ──────────────────────────────────────────

  @Enumerated(EnumType.name)
  BookmarkScrapingStatus scrapingStatus;

  /// Group ID (usually a hash) that links bookmarks we believe are
  /// duplicates of the same underlying content. Populated by the
  /// dedupe service at capture time (Faz 4). Same-group items get a
  /// "merge?" suggestion in the UI.
  String? duplicateGroupId;
}
