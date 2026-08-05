import 'dart:async';

import 'package:logger/logger.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Domain-level handler that abstracts `receive_sharing_intent` into a
/// testable, URL-focused API.
///
/// Handles both cold-start ([getInitialUrl]) and warm-start ([urlStream])
/// share scenarios, validates extracted text as URLs, and resets consumed
/// initial intents to prevent replay.
class ShareIntentHandler {
  ShareIntentHandler({
    required Stream<List<SharedMediaFile>> mediaStream,
    required Future<List<SharedMediaFile>> Function() initialMediaGetter,
    required Future<dynamic> Function() reset,
    Logger? logger,
  })  : _mediaStream = mediaStream,
        _initialMediaGetter = initialMediaGetter,
        _reset = reset,
        _logger = logger;

  final Stream<List<SharedMediaFile>> _mediaStream;
  final Future<List<SharedMediaFile>> Function() _initialMediaGetter;
  final Future<dynamic> Function() _reset;
  final Logger? _logger;

  Stream<String?>? _cachedUrlStream;

  /// A broadcast stream that emits validated URLs extracted from shared
  /// media of type [SharedMediaType.text] or [SharedMediaType.url].
  ///
  /// Non-URL text and other media types are silently filtered out.
  /// The stream is cached so multiple listeners share the same
  /// subscription without re-subscribing to the platform stream.
  Stream<String?> get urlStream {
    _cachedUrlStream ??= _mediaStream
        .map(_extractFirstValidUrl)
        .asBroadcastStream();

    return _cachedUrlStream!;
  }

  /// Retrieves the initial shared media (cold-start intent) and returns
  /// the first valid URL found.
  ///
  /// If a URL is found, [reset] is called automatically to prevent the
  /// same intent from being processed again on the next app launch.
  /// Returns `null` if no valid URL is present.
  Future<String?> getInitialUrl() async {
    _logger?.i('ShareIntentHandler: fetching initial media');

    final List<SharedMediaFile> media = await _initialMediaGetter();
    _logger?.d('ShareIntentHandler: initial media count=${media.length}');

    final String? url = _extractFirstValidUrl(media);

    if (url != null) {
      _logger?.i('ShareIntentHandler: extracted initial URL: $url');
      await _reset();
      _logger?.d('ShareIntentHandler: reset called after consuming initial URL');
    } else {
      _logger?.d('ShareIntentHandler: no valid URL in initial media');
    }

    return url;
  }

  /// Extracts the first valid URL from a list of shared media files.
  ///
  /// Only considers files of type [SharedMediaType.text] or
  /// [SharedMediaType.url]. Returns `null` if none match or none are
  /// valid URLs.
  String? _extractFirstValidUrl(List<SharedMediaFile> media) {
    for (final SharedMediaFile file in media) {
      if (file.type != SharedMediaType.text && file.type != SharedMediaType.url) {
        _logger?.d(
          'ShareIntentHandler: skipping media type=${file.type.value}',
        );
        continue;
      }

      final String candidate = file.path;
      final String? validated = _validateUrl(candidate);

      if (validated != null) {
        _logger?.i(
          'ShareIntentHandler: validated URL from stream: $validated',
        );
        return validated;
      } else {
        _logger?.d(
          'ShareIntentHandler: rejected non-URL text: "$candidate"',
        );
      }
    }

    return null;
  }

  /// Validates that [candidate] is a parseable URL with both a scheme
  /// and an authority.
  ///
  /// Returns the original string if valid, otherwise `null`.
  String? _validateUrl(String candidate) {
    final String trimmed = candidate.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
