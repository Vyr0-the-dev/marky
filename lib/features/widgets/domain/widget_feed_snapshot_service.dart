import 'package:flutter/services.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/widgets/domain/widget_feed_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetFeedSnapshotService {
  WidgetFeedSnapshotService({
    required BookmarkRepository bookmarkRepository,
    required SharedPreferences preferences,
    MethodChannel? channel,
    DateTime Function()? now,
  })  : _bookmarkRepository = bookmarkRepository,
        _preferences = preferences,
        _channel = channel ?? const MethodChannel('marky/home_widget'),
        _now = now ?? DateTime.now;

  static const String keyTitle = 'marky_widget_title';
  static const String keySubtitle = 'marky_widget_subtitle';
  static const String keyItem1 = 'marky_widget_item_1';
  static const String keyItem2 = 'marky_widget_item_2';
  static const String keyItem3 = 'marky_widget_item_3';
  static const String keyUpdatedAt = 'marky_widget_updated_at';

  final BookmarkRepository _bookmarkRepository;
  final SharedPreferences _preferences;
  final MethodChannel _channel;
  final DateTime Function() _now;

  Future<WidgetFeedSnapshot> refresh() async {
    final List<Bookmark> bookmarks = await _bookmarkRepository.feed(
      const BookmarkFeedQuery(limit: 3),
    );
    final int unreadCount = await _bookmarkRepository.count(
      const BookmarkFeedQuery(filter: BookmarkFeedFilter.unread),
    );
    final DateTime updatedAt = _now();
    final WidgetFeedSnapshot snapshot = WidgetFeedSnapshot(
      title: 'Marky',
      subtitle: unreadCount == 0
          ? 'All caught up'
          : '$unreadCount unread link${unreadCount == 1 ? '' : 's'}',
      snippets: bookmarks.map(_snippetFor).toList(growable: false),
      updatedAt: updatedAt,
    );
    await _persist(snapshot);
    await _notifyAndroidWidget();
    return snapshot;
  }

  WidgetFeedSnippet _snippetFor(Bookmark bookmark) {
    final String title = bookmark.displayTitle.trim().isEmpty
        ? bookmark.originalUrl
        : bookmark.displayTitle;
    final String? host = bookmark.normalizedHost?.trim();
    final String subtitle =
        (host?.isNotEmpty ?? false) ? host! : bookmark.originalUrl;
    return WidgetFeedSnippet(title: title, subtitle: subtitle);
  }

  Future<void> _persist(WidgetFeedSnapshot snapshot) async {
    final List<String> items = snapshot.snippets
        .map(
          (WidgetFeedSnippet snippet) =>
              '${snippet.title} — ${snippet.subtitle}',
        )
        .toList(growable: false);

    await Future.wait<bool>(<Future<bool>>[
      _preferences.setString(keyTitle, snapshot.title),
      _preferences.setString(keySubtitle, snapshot.subtitle),
      _preferences.setString(keyItem1, items.isNotEmpty ? items[0] : ''),
      _preferences.setString(keyItem2, items.length > 1 ? items[1] : ''),
      _preferences.setString(keyItem3, items.length > 2 ? items[2] : ''),
      _preferences.setString(
        keyUpdatedAt,
        snapshot.updatedAt.toIso8601String(),
      ),
    ]);
  }

  Future<void> _notifyAndroidWidget() async {
    try {
      await _channel.invokeMethod<void>('updateFeedWidget');
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
