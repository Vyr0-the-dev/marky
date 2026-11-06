import 'package:flutter_test/flutter_test.dart';

import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/capture/domain/capture_service.dart';
import 'package:marky/features/share_intent/domain/share_capture_coordinator.dart';

void main() {
  test('captureSharedText routes shared text into v2 capture pipeline',
      () async {
    final _FakeCaptureService captureService = _FakeCaptureService();
    final ShareCaptureCoordinator coordinator = ShareCaptureCoordinator(
      captureService: captureService,
    );

    final CaptureResult result = await coordinator.captureSharedText(
      'Read this https://example.com/article',
    );

    expect(result.status, CaptureStatus.invalidUrl);
    expect(captureService.lastText, 'Read this https://example.com/article');
    expect(captureService.lastSourceType, BookmarkSourceType.share);
  });
}

class _FakeCaptureService implements CaptureService {
  String? lastText;
  BookmarkSourceType? lastSourceType;

  @override
  Future<CaptureResult> capture(
    String rawInput, {
    BookmarkSourceType sourceType = BookmarkSourceType.manual,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CaptureResult> captureFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  }) async {
    lastText = text;
    lastSourceType = sourceType;
    return const CaptureResult.invalidUrl();
  }

  @override
  Future<List<CaptureResult>> captureAllFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  }) {
    throw UnimplementedError();
  }
}
