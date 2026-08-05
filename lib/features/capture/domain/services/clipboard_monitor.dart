import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';

/// Result of a clipboard check containing the validated URL and its hash.
class ClipboardCheckResult {
  const ClipboardCheckResult({
    required this.url,
    required this.hash,
  });

  final String url;
  final String hash;

  @override
  String toString() => 'ClipboardCheckResult(url: $url, hash: $hash)';
}

/// Typedef for a function that reads clipboard data.
typedef ClipboardReader = Future<ClipboardData?> Function();

/// Monitors the system clipboard for URLs.
///
/// Injectable [ClipboardReader] allows full testability without touching
/// Flutter's static [Clipboard] API.
class ClipboardMonitor {
  ClipboardMonitor({
    required UrlNormalizationService urlNormalizationService,
    required ClipboardReader clipboardReader,
    Logger? logger,
  })  : _urlNormalizationService = urlNormalizationService,
        _clipboardReader = clipboardReader,
        _logger = logger;

  final UrlNormalizationService _urlNormalizationService;
  final ClipboardReader _clipboardReader;
  final Logger? _logger;

  /// Checks the clipboard for a valid URL.
  ///
  /// Returns a [ClipboardCheckResult] containing the normalized URL and its
  /// canonical hash if the clipboard contains a valid URL. Returns `null` if
  /// the clipboard is empty, does not contain a URL, or if reading fails.
  Future<ClipboardCheckResult?> checkClipboard() async {
    _logger?.d('ClipboardMonitor: checking clipboard');

    final ClipboardData? data;
    try {
      data = await _clipboardReader();
    } catch (e, st) {
      _logger?.w(
        'ClipboardMonitor: clipboard read failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }

    final String? text = data?.text;
    if (text == null || text.isEmpty) {
      _logger?.d('ClipboardMonitor: clipboard empty or no text');
      return null;
    }

    _logger?.d('ClipboardMonitor: raw clipboard text: "$text"');

    final String? normalizedUrl = _urlNormalizationService.normalizeUrl(text);
    if (normalizedUrl == null) {
      _logger?.d('ClipboardMonitor: not a valid URL: "$text"');
      return null;
    }

    final String hash = _urlNormalizationService.computeUrlHash(normalizedUrl);

    _logger?.i('ClipboardMonitor: valid URL found — $normalizedUrl');
    return ClipboardCheckResult(url: normalizedUrl, hash: hash);
  }
}
