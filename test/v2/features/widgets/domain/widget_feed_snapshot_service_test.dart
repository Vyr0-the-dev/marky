import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/widgets/domain/widget_feed_snapshot.dart';
import 'package:marky/features/widgets/domain/widget_feed_snapshot_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WidgetFeedSnapshotService', () {
    test('persists latest feed snippets and notifies native widget', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final List<MethodCall> calls = <MethodCall>[];
      const MethodChannel channel = MethodChannel('test/widget');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        calls.add(call);
        return null;
      });

      final WidgetFeedSnapshotService service = WidgetFeedSnapshotService(
        bookmarkRepository: _FakeBookmarkRepository(
          bookmarks: <Bookmark>[
            _bookmark(
              title: 'A deep read',
            ),
            _bookmark(
              id: 2,
              title: 'Second link',
              host: 'news.dev',
            ),
          ],
          unreadCount: 2,
        ),
        preferences: preferences,
        channel: channel,
        now: () => DateTime(2026, 1, 10, 9),
      );

      final snapshot = await service.refresh();

      expect(snapshot.subtitle, '2 unread links');
      expect(snapshot.snippets, hasLength(2));
      expect(
        preferences.getString(WidgetFeedSnapshotService.keyTitle),
        'Marky',
      );
      expect(
        preferences.getString(WidgetFeedSnapshotService.keySubtitle),
        '2 unread links',
      );
      expect(
        preferences.getString(WidgetFeedSnapshotService.keyItem1),
        'A deep read — example.com',
      );
      expect(
        preferences.getString(WidgetFeedSnapshotService.keyItem2),
        'Second link — news.dev',
      );
      expect(calls.single.method, 'updateFeedWidget');
    });

    test('clears stale snippet slots when feed is empty', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        WidgetFeedSnapshotService.keyItem1: 'Old item 1',
        WidgetFeedSnapshotService.keyItem2: 'Old item 2',
        WidgetFeedSnapshotService.keyItem3: 'Old item 3',
      });
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final List<MethodCall> calls = <MethodCall>[];
      const MethodChannel channel = MethodChannel('test/widget_empty');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        calls.add(call);
        return null;
      });

      final WidgetFeedSnapshotService service = WidgetFeedSnapshotService(
        bookmarkRepository: const _FakeBookmarkRepository(
          bookmarks: <Bookmark>[],
          unreadCount: 0,
        ),
        preferences: preferences,
        channel: channel,
        now: () => DateTime(2026, 1, 10, 10),
      );

      final snapshot = await service.refresh();

      expect(snapshot.subtitle, 'All caught up');
      expect(snapshot.snippets, isEmpty);
      expect(preferences.getString(WidgetFeedSnapshotService.keyItem1), '');
      expect(preferences.getString(WidgetFeedSnapshotService.keyItem2), '');
      expect(preferences.getString(WidgetFeedSnapshotService.keyItem3), '');
      expect(
        preferences.getString(WidgetFeedSnapshotService.keyUpdatedAt),
        DateTime(2026, 1, 10, 10).toIso8601String(),
      );
      expect(calls.single.method, 'updateFeedWidget');
    });

    test('persists snapshot even when native widget update fails', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      const MethodChannel channel = MethodChannel('test/widget_failure');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        throw PlatformException(code: 'native-widget-failed');
      });

      final WidgetFeedSnapshotService service = WidgetFeedSnapshotService(
        bookmarkRepository: _FakeBookmarkRepository(
          bookmarks: <Bookmark>[_bookmark(title: 'Saved for later')],
          unreadCount: 1,
        ),
        preferences: preferences,
        channel: channel,
        now: () => DateTime(2026, 1, 10, 11),
      );

      final WidgetFeedSnapshot snapshot = await service.refresh();

      expect(snapshot.subtitle, '1 unread link');
      expect(
        preferences.getString(WidgetFeedSnapshotService.keyItem1),
        'Saved for later — example.com',
      );
    });
  });
}

Bookmark _bookmark({
  int id = 1,
  String title = 'Link',
  String host = 'example.com',
}) {
  final DateTime now = DateTime(2026);
  return Bookmark(
    id: id,
    originalUrl: 'https://$host/$id',
    canonicalUrl: 'https://$host/$id',
    normalizedHost: host,
    title: title,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeBookmarkRepository implements BookmarkRepository {
  const _FakeBookmarkRepository({
    required this.bookmarks,
    required this.unreadCount,
  });

  final List<Bookmark> bookmarks;
  final int unreadCount;

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => bookmarks;

  @override
  Future<int> count(BookmarkFeedQuery query) async => unreadCount;

  @override
  Future<int> countAll() => throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<int> deleteAll(List<int> ids) => throw UnimplementedError();
  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) =>
      throw UnimplementedError();
  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) =>
      throw UnimplementedError();
  @override
  Future<Bookmark?> findByUrlHash(String urlHash) => throw UnimplementedError();
  @override
  Future<Bookmark?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> getByIds(List<int> ids) => throw UnimplementedError();
  @override
  Future<Bookmark> save(Bookmark bookmark) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) =>
      throw UnimplementedError();
  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) =>
      throw UnimplementedError();
  @override
  Stream<Bookmark?> watchById(int id) => throw UnimplementedError();
  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      throw UnimplementedError();
}
