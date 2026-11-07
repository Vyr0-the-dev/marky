import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/detail/presentation/detail_screen.dart';
import 'package:marky/features/detail/presentation/widgets/edit_bookmark_sheet.dart';
import 'package:marky/features/notes/data/note_providers.dart';
import 'package:marky/features/notes/domain/note.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/l10n/app_localizations.dart';

void main() {
  testWidgets(
      'DetailScreen renders AppBar actions, overflow menu, and sticky bottom bar',
      (WidgetTester tester) async {
    final _InMemoryBookmarkRepository repository =
        _InMemoryBookmarkRepository();
    addTearDown(repository.dispose);

    final DateTime now = DateTime(2026, 2, 1, 12);
    final Bookmark initial = await repository.save(
      Bookmark(
        id: 1,
        originalUrl: 'https://example.com/editorial-reading',
        canonicalUrl: 'https://example.com/editorial-reading',
        normalizedHost: 'example.com',
        title: 'Editorial Reading Room',
        description: 'Clean reading layout without mid-body action matrix.',
        scrapingStatus: BookmarkScrapingStatus.done,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          ...testAppSettingsOverrides(),
          bookmarkRepositoryProvider.overrideWithValue(repository),
          bookmarkByIdProvider(initial.id!).overrideWith(
            (ref) => repository.watchById(initial.id!),
          ),
          tagByIdProvider.overrideWith((ref, id) => Stream<Tag?>.value(null)),
          bookmarkCollectionByIdProvider.overrideWith(
            (ref, id) => Stream<BookmarkCollection?>.value(null),
          ),
          notesByBookmarkProvider.overrideWith(
            (ref, id) => Stream<List<Note>>.value(<Note>[]),
          ),
          remindersForBookmarkProvider.overrideWith(
            (ref, id) => Stream<List<Reminder>>.value(<Reminder>[]),
          ),
        ],
        child: MaterialApp(
          theme: ReadingRoomTheme.build(ReadingRoomVariant.light),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: DetailScreen(id: initial.id!),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify editorial content is rendered
    expect(find.text('Editorial Reading Room'), findsOneWidget);
    expect(
      find.text('Clean reading layout without mid-body action matrix.'),
      findsOneWidget,
    );

    // Sticky bottom action bar has Open & Copy buttons
    expect(find.text('Open'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_browser), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.byIcon(Icons.copy_outlined), findsOneWidget);

    // Top AppBar has Favorite, Pin, Share quick-toggles
    expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);
    expect(find.byIcon(Icons.share_outlined), findsOneWidget);

    // Toggle favorite
    await tester.tap(find.byTooltip('Favorite'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect((await repository.getById(initial.id!))!.isFavorite, isTrue);

    // Toggle pin
    await tester.tap(find.byTooltip('Pin'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.push_pin), findsOneWidget);
    expect((await repository.getById(initial.id!))!.isPinned, isTrue);

    // Overflow menu exposes Edit, Refetch, Read, Archive, Delete
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Refetch'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Toggle Read via overflow menu
    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();
    expect((await repository.getById(initial.id!))!.isRead, isTrue);

    // Toggle Archive via overflow menu
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Unread'), findsOneWidget);
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect((await repository.getById(initial.id!))!.isArchived, isTrue);

    // Copy URL from sticky bottom bar
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(find.text('Link copied'), findsOneWidget);

    // Edit title & description from overflow menu
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byType(EditBookmarkSheet), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).first,
      'Updated Editorial Title',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Updated Editorial Title'), findsOneWidget);

    // Delete confirmation dialog from overflow menu
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete bookmark?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await repository.getById(initial.id!), isNotNull);
  });

  testWidgets(
      'DetailScreen renders in-app video play button and badge for video bookmarks',
      (WidgetTester tester) async {
    final _InMemoryBookmarkRepository repository =
        _InMemoryBookmarkRepository();
    addTearDown(repository.dispose);

    final DateTime now = DateTime(2026, 2, 1, 12);
    final Bookmark videoBookmark = await repository.save(
      Bookmark(
        id: 2,
        originalUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        canonicalUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        normalizedHost: 'youtube.com',
        title: 'Rick Astley - Never Gonna Give You Up',
        heroImageUrl: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        contentType: BookmarkContentType.video,
        scrapingStatus: BookmarkScrapingStatus.done,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          ...testAppSettingsOverrides(),
          bookmarkRepositoryProvider.overrideWithValue(repository),
          bookmarkByIdProvider(videoBookmark.id!).overrideWith(
            (ref) => repository.watchById(videoBookmark.id!),
          ),
          tagByIdProvider.overrideWith((ref, id) => Stream<Tag?>.value(null)),
          bookmarkCollectionByIdProvider.overrideWith(
            (ref, id) => Stream<BookmarkCollection?>.value(null),
          ),
          notesByBookmarkProvider.overrideWith(
            (ref, id) => Stream<List<Note>>.value(<Note>[]),
          ),
          remindersForBookmarkProvider.overrideWith(
            (ref, id) => Stream<List<Reminder>>.value(<Reminder>[]),
          ),
        ],
        child: MaterialApp(
          theme: ReadingRoomTheme.build(ReadingRoomVariant.light),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: DetailScreen(id: videoBookmark.id!),
        ),
      ),
    );
    await tester.pump();

    // Verify video badge and play button are rendered
    expect(find.text('VİDEO'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.text('Rick Astley - Never Gonna Give You Up'), findsOneWidget);
  });
}

class _InMemoryBookmarkRepository implements BookmarkRepository {
  final Map<int, Bookmark> _items = <int, Bookmark>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  void dispose() {
    unawaited(_changes.close());
  }

  @override
  Future<Bookmark> save(Bookmark bookmark) async {
    final int id = bookmark.id ?? (_items.length + 1);
    final Bookmark saved = bookmark.copyWith(id: id);
    _items[id] = saved;
    if (!_changes.isClosed) _changes.add(null);
    return saved;
  }

  @override
  Future<Bookmark?> getById(int id) async => _items[id];

  @override
  Stream<Bookmark?> watchById(int id) async* {
    yield _items[id];
    await for (final _ in _changes.stream) {
      yield _items[id];
    }
  }

  @override
  Future<bool> delete(int id) async {
    final bool removed = _items.remove(id) != null;
    if (removed && !_changes.isClosed) _changes.add(null);
    return removed;
  }

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) =>
      throw UnimplementedError();
  @override
  Future<List<Bookmark>> getByIds(List<int> ids) => throw UnimplementedError();
  @override
  Future<int> deleteAll(List<int> ids) => throw UnimplementedError();
  @override
  Future<Bookmark?> findByUrlHash(String urlHash) => throw UnimplementedError();
  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) =>
      throw UnimplementedError();
  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) =>
      throw UnimplementedError();
  @override
  Future<int> countAll() => throw UnimplementedError();
  @override
  Future<int> count(BookmarkFeedQuery query) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) =>
      throw UnimplementedError();
  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      throw UnimplementedError();
  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) =>
      throw UnimplementedError();
}
