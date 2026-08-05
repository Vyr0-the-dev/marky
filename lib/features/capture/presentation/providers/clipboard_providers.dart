import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:marky/features/capture/domain/services/clipboard_monitor.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';

// ─── Clipboard State ───────────────────────────────────────────────────

// Sentinel used by [copyWith] to distinguish "not provided" from `null`.
class _Undefined {
  const _Undefined();
}

const _Undefined _undefined = _Undefined();

/// Immutable state representing the current clipboard URL detection.
class ClipboardState {
  const ClipboardState({
    this.detectedUrl,
    this.lastSeenHash,
  });

  /// The most recently detected valid URL from the clipboard, or `null`
  /// if none has been detected or the user dismissed it.
  final String? detectedUrl;

  /// Hash of the most recently detected URL. Persists after dismissal
  /// so the same URL is not re-prompted within a session.
  final String? lastSeenHash;

  /// Returns a copy with selected fields replaced.
  ClipboardState copyWith({
    Object? detectedUrl = _undefined,
    Object? lastSeenHash = _undefined,
  }) {
    return ClipboardState(
      detectedUrl: detectedUrl is _Undefined ? this.detectedUrl : detectedUrl as String?,
      lastSeenHash: lastSeenHash is _Undefined ? this.lastSeenHash : lastSeenHash as String?,
    );
  }

  @override
  String toString() =>
      'ClipboardState(detectedUrl: $detectedUrl, lastSeenHash: $lastSeenHash)';
}

// ─── Clipboard Notifier ────────────────────────────────────────────────

/// Notifier that manages clipboard URL detection state.
///
/// Tracks the currently detected URL and its hash so the UI can show
/// a banner / sheet and the user can dismiss it. Uses [lastSeenHash]
/// to deduplicate across initState / resume cycles.
class ClipboardNotifier extends StateNotifier<ClipboardState> {
  ClipboardNotifier() : super(const ClipboardState());

  final Logger _logger = Logger();

  /// Sets the detected URL if its hash differs from [lastSeenHash].
  ///
  /// This prevents re-prompting the same URL within a session.
  void setDetectedUrl(String url, String hash) {
    if (state.lastSeenHash == hash) {
      _logger.d('ClipboardNotifier: ignoring duplicate hash $hash');
      return;
    }
    _logger.i('ClipboardNotifier: new URL detected — $url');
    state = state.copyWith(detectedUrl: url, lastSeenHash: hash);
  }

  /// Dismisses the current detected URL without clearing [lastSeenHash].
  ///
  /// Calling this means the user does not want to act on the URL right
  /// now, but we should not prompt again for the same URL.
  void dismiss() {
    _logger.d('ClipboardNotifier: dismissed current URL');
    state = state.copyWith(detectedUrl: null);
  }

  /// Clears both the detected URL and the last-seen hash.
  ///
  /// Useful for testing or when the user explicitly resets the session.
  void clear() {
    _logger.d('ClipboardNotifier: cleared all state');
    state = const ClipboardState();
  }
}

// ─── Providers ─────────────────────────────────────────────────────────

/// Provider that exposes the clipboard detection state and notifier.
final StateNotifierProvider<ClipboardNotifier, ClipboardState>
    clipboardUrlProvider =
    StateNotifierProvider<ClipboardNotifier, ClipboardState>(
  (Ref ref) => ClipboardNotifier(),
);

/// Provider that exposes the live [ClipboardMonitor] wired to the
/// platform's [Clipboard] API.
///
/// Override in tests with a monitor that uses an injected fake reader.
final Provider<ClipboardMonitor> clipboardMonitorProvider =
    Provider<ClipboardMonitor>((Ref ref) {
  return ClipboardMonitor(
    urlNormalizationService: UrlNormalizationService.instance,
    clipboardReader: () => Clipboard.getData(Clipboard.kTextPlain),
    logger: Logger(),
  );
});
