import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';

/// Persistence + query boundary for [Bookmark].
///
/// Feature code (capture, feed, detail, automation) talks to this
/// interface only — never to the Isar entity directly. That keeps the
/// engine swappable (e.g. for an in-memory test double or a future
/// migration to a different store) and keeps the domain model free
/// of Isar's annotation noise.
///
/// Method shape conventions:
/// - **`save`** is a single upsert path (insert when `id == null`,
///   update otherwise). Callers don't need a separate create/update
///   split — Isar's `put` handles both.
/// - Read methods return `null` instead of throwing when "not found";
///   exceptions are reserved for actual errors (storage failure,
///   broken invariant).
/// - **`watchFeed`** is a Stream so the feed UI can subscribe once
///   and react to any write (foreground edit, background scrape,
///   automation rule firing). Streams emit the *whole* current page
///   each tick — pagination is recomputed at the source rather than
///   patched at the consumer.
abstract interface class BookmarkRepository {
  // ─── Single-row CRUD ───────────────────────────────────────────────

  /// Inserts or updates [bookmark]. Returns the persisted copy with
  /// `id` populated. Sets [Bookmark.updatedAt] to the current wall
  /// clock automatically — callers should *not* set it themselves.
  Future<Bookmark> save(Bookmark bookmark);

  /// Inserts/updates many in a single Isar transaction. Returns the
  /// list in the same order as input.
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks);

  /// Returns the bookmark with [id] or `null` if it has been deleted
  /// (or never existed).
  Future<Bookmark?> getById(int id);

  /// Returns multiple bookmarks by id, preserving input order.
  /// Missing ids are dropped silently — feature code that needs
  /// strict 1:1 must check the length.
  Future<List<Bookmark>> getByIds(List<int> ids);

  /// Permanent delete. We don't soft-delete (see entity docstring);
  /// `Future<bool>` reflects whether the row existed.
  Future<bool> delete(int id);

  /// Permanent batch delete. Returns the count actually removed.
  Future<int> deleteAll(List<int> ids);

  // ─── Lookup paths used during capture / dedupe ─────────────────────

  /// Fast probe for "have we seen this URL before?".
  /// Caller is expected to compute the same SHA-256 hash that the
  /// dedupe service uses on the canonical URL.
  Future<Bookmark?> findByUrlHash(String urlHash);

  /// Slower fallback for when the hash-based path missed but we still
  /// want to check on canonical URL equality (e.g. older bookmarks
  /// captured before urlHash was populated).
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl);

  /// Looks up a bookmark by its platform-specific content ID (e.g.
  /// `youtube:dQw4w9WgXcQ`). Used by the dedupe engine to collapse
  /// "different URL, same content" duplicates.
  Future<Bookmark?> findByExternalContentId(String externalContentId);

  // ─── Aggregate counts ─────────────────────────────────────────────

  /// Total non-archived bookmark count. Powers the app-bar counter.
  Future<int> countAll();

  /// Count restricted by [query] — same predicate set as [feed], but
  /// without the limit/offset/sort. Used by paginators to know when
  /// to stop loading.
  Future<int> count(BookmarkFeedQuery query);

  // ─── Feed queries ──────────────────────────────────────────────────

  /// One-shot snapshot. Honours filter, sort, and pagination from
  /// [query]. Pinned bookmarks always float to the top regardless of
  /// sort, so the visual contract ("pinned stays pinned") never
  /// surprises the user.
  Future<List<Bookmark>> feed(BookmarkFeedQuery query);

  /// Reactive feed. Emits an initial page synchronously after
  /// subscribe and re-emits whenever any underlying row mutates.
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query);

  /// Watches a single bookmark by id — used by the detail screen.
  /// Emits `null` immediately after the row is deleted so detail
  /// screens can pop themselves on background deletion.
  Stream<Bookmark?> watchById(int id);

  // ─── Search ──────────────────────────────────────────────────────

  /// Full-text keyword search across title, normalizedHost, snippet,
  /// author, and siteName. Returns up to [limit] results, ordered by
  /// relevance (title matches first, then other fields).
  Future<List<Bookmark>> search(String query, {int limit = 50});
}
