import 'dart:async';

import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/capture/domain/capture_service.dart';
import 'package:marky/features/widgets/domain/widget_feed_snapshot_service.dart';

class WidgetRefreshingCaptureService implements CaptureService {
  const WidgetRefreshingCaptureService({
    required CaptureService delegate,
    required Future<WidgetFeedSnapshotService> Function() snapshotService,
  })  : _delegate = delegate,
        _snapshotService = snapshotService;

  final CaptureService _delegate;
  final Future<WidgetFeedSnapshotService> Function() _snapshotService;

  @override
  Future<CaptureResult> capture(
    String rawInput, {
    BookmarkSourceType sourceType = BookmarkSourceType.manual,
  }) async {
    final CaptureResult result = await _delegate.capture(
      rawInput,
      sourceType: sourceType,
    );
    _refreshIfNeeded(<CaptureResult>[result]);
    return result;
  }

  @override
  Future<List<CaptureResult>> captureAllFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  }) async {
    final List<CaptureResult> results = await _delegate.captureAllFromText(
      text,
      sourceType: sourceType,
    );
    _refreshIfNeeded(results);
    return results;
  }

  @override
  Future<CaptureResult> captureFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  }) async {
    final CaptureResult result = await _delegate.captureFromText(
      text,
      sourceType: sourceType,
    );
    _refreshIfNeeded(<CaptureResult>[result]);
    return result;
  }

  void _refreshIfNeeded(List<CaptureResult> results) {
    if (!results.any(_shouldRefresh)) return;
    unawaited(
      _snapshotService()
          .then<void>((WidgetFeedSnapshotService service) => service.refresh())
          .catchError((_) {}),
    );
  }

  static bool _shouldRefresh(CaptureResult result) {
    return result.status == CaptureStatus.saved ||
        result.status == CaptureStatus.duplicate;
  }
}
