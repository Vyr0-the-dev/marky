import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/library/domain/broken_link_checker_service.dart';

void main() {
  group('BrokenLinkCheckerService', () {
    test('reports invalid URL scheme for non-http/https links', () async {
      final BrokenLinkCheckerService service = BrokenLinkCheckerService();
      final Bookmark bookmark = Bookmark(
        originalUrl: 'javascript:void(0)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final BrokenLinkReport? report = await service.checkBookmark(bookmark);
      expect(report, isNotNull);
      expect(report!.reason, BrokenLinkReason.other);
      expect(report.message, 'Invalid URL scheme');
    });

    test('classifies 404 response as notFound', () {
      final BrokenLinkCheckerService service = BrokenLinkCheckerService();
      final Bookmark bookmark = Bookmark(
        originalUrl: 'https://example.com/broken-page',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final DioException exception = DioException(
        requestOptions: RequestOptions(path: bookmark.originalUrl),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: bookmark.originalUrl),
          statusCode: 404,
        ),
      );

      final BrokenLinkReport report =
          service.mapDioException(bookmark, exception);

      expect(report.reason, BrokenLinkReason.notFound);
      expect(report.statusCode, 404);
      expect(report.message, contains('404'));
    });

    test('classifies 410 response as gone', () {
      final BrokenLinkCheckerService service = BrokenLinkCheckerService();
      final Bookmark bookmark = Bookmark(
        originalUrl: 'https://example.com/gone-page',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final DioException exception = DioException(
        requestOptions: RequestOptions(path: bookmark.originalUrl),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: bookmark.originalUrl),
          statusCode: 410,
        ),
      );

      final BrokenLinkReport report =
          service.mapDioException(bookmark, exception);

      expect(report.reason, BrokenLinkReason.gone);
      expect(report.statusCode, 410);
    });

    test('classifies 500 response as serverError', () {
      final BrokenLinkCheckerService service = BrokenLinkCheckerService();
      final Bookmark bookmark = Bookmark(
        originalUrl: 'https://example.com/server-error',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final DioException exception = DioException(
        requestOptions: RequestOptions(path: bookmark.originalUrl),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: bookmark.originalUrl),
          statusCode: 503,
        ),
      );

      final BrokenLinkReport report =
          service.mapDioException(bookmark, exception);

      expect(report.reason, BrokenLinkReason.serverError);
      expect(report.statusCode, 503);
    });

    test('classifies timeout as timeout reason', () {
      final BrokenLinkCheckerService service = BrokenLinkCheckerService();
      final Bookmark bookmark = Bookmark(
        originalUrl: 'https://example.com/timeout',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final DioException exception = DioException(
        requestOptions: RequestOptions(path: bookmark.originalUrl),
        type: DioExceptionType.connectionTimeout,
      );

      final BrokenLinkReport report =
          service.mapDioException(bookmark, exception);

      expect(report.reason, BrokenLinkReason.timeout);
    });
  });
}
