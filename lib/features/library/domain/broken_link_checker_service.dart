import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/l10n/app_localizations.dart';

enum BrokenLinkReason {
  notFound,
  gone,
  serverError,
  dnsOrNetworkError,
  timeout,
  other;

  String localizedLabel(AppLocalizations? l10n) {
    switch (this) {
      case BrokenLinkReason.notFound:
        return l10n?.brokenReasonNotFound ?? 'Not Found (404)';
      case BrokenLinkReason.gone:
        return l10n?.brokenReasonGone ?? 'Gone (410)';
      case BrokenLinkReason.serverError:
        return l10n?.brokenReasonServerError ?? 'Server Error (5xx)';
      case BrokenLinkReason.dnsOrNetworkError:
        return l10n?.brokenReasonDns ?? 'DNS / Network Error';
      case BrokenLinkReason.timeout:
        return l10n?.brokenReasonTimeout ?? 'Request Timeout';
      case BrokenLinkReason.other:
        return l10n?.brokenReasonOther ?? 'Access Error';
    }
  }
}

class BrokenLinkReport {
  const BrokenLinkReport({
    required this.bookmark,
    required this.reason,
    this.statusCode,
    required this.message,
  });

  final Bookmark bookmark;
  final BrokenLinkReason reason;
  final int? statusCode;
  final String message;
}

class BrokenLinkCheckerService {
  BrokenLinkCheckerService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 6),
                receiveTimeout: const Duration(seconds: 6),
                headers: <String, String>{
                  'User-Agent':
                      'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36 Marky/1.0',
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                },
                followRedirects: true,
                maxRedirects: 5,
                validateStatus: (int? status) => status != null && status < 400,
              ),
            );

  final Dio _dio;

  /// Builds an Internet Archive Wayback Machine lookup URL for [originalUrl].
  static String waybackUrlFor(String originalUrl) {
    return 'https://web.archive.org/web/${Uri.encodeFull(originalUrl.trim())}';
  }

  Future<BrokenLinkReport?> checkBookmark(Bookmark bookmark) async {
    final String url = bookmark.canonicalUrl ?? bookmark.originalUrl;
    if (url.trim().isEmpty || !url.startsWith('http')) {
      return BrokenLinkReport(
        bookmark: bookmark,
        reason: BrokenLinkReason.other,
        message: 'Invalid URL scheme',
      );
    }

    try {
      // First try a lightweight HEAD request
      await _dio.head<dynamic>(url);
      return null; // 2xx or 3xx -> Healthy!
    } on DioException catch (e) {
      final int? statusCode = e.response?.statusCode;

      // Some servers return 405 Method Not Allowed or 403 to HEAD requests. Fallback to range GET.
      if (statusCode == 405 || statusCode == 403) {
        try {
          await _dio.get<dynamic>(
            url,
            options: Options(
              headers: <String, String>{'Range': 'bytes=0-1024'},
            ),
          );
          return null; // Healthy with GET
        } on DioException catch (fallbackError) {
          return mapDioException(bookmark, fallbackError);
        }
      }

      return mapDioException(bookmark, e);
    } catch (e) {
      return BrokenLinkReport(
        bookmark: bookmark,
        reason: BrokenLinkReason.other,
        message: e.toString(),
      );
    }
  }

  @visibleForTesting
  BrokenLinkReport mapDioException(Bookmark bookmark, DioException e) {
    final int? code = e.response?.statusCode;

    if (code == 404) {
      return BrokenLinkReport(
        bookmark: bookmark,
        reason: BrokenLinkReason.notFound,
        statusCode: 404,
        message: 'HTTP 404 Not Found',
      );
    }

    if (code == 410) {
      return BrokenLinkReport(
        bookmark: bookmark,
        reason: BrokenLinkReason.gone,
        statusCode: 410,
        message: 'HTTP 410 Gone',
      );
    }

    if (code != null && code >= 500 && code <= 599) {
      return BrokenLinkReport(
        bookmark: bookmark,
        reason: BrokenLinkReason.serverError,
        statusCode: code,
        message: 'HTTP $code Server Error',
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return BrokenLinkReport(
        bookmark: bookmark,
        reason: BrokenLinkReason.timeout,
        message: 'Timed out waiting for response',
      );
    }

    if (e.error is SocketException ||
        e.type == DioExceptionType.connectionError) {
      return BrokenLinkReport(
        bookmark: bookmark,
        reason: BrokenLinkReason.dnsOrNetworkError,
        message: 'Could not resolve host / unreachable',
      );
    }

    return BrokenLinkReport(
      bookmark: bookmark,
      reason: BrokenLinkReason.other,
      statusCode: code,
      message: e.message ?? 'Access failed ($code)',
    );
  }
}

final Provider<BrokenLinkCheckerService> brokenLinkCheckerServiceProvider =
    Provider<BrokenLinkCheckerService>((Ref ref) {
  return BrokenLinkCheckerService();
});
