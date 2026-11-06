import 'package:marky/core/input/marky_input_limits.dart';
import 'package:marky/core/url/url_extractor.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareIntentHandler {
  ShareIntentHandler({
    required Stream<List<SharedMediaFile>> mediaStream,
    required Future<List<SharedMediaFile>> Function() initialMediaGetter,
    required Future<dynamic> Function() reset,
    UrlExtractor urlExtractor = const UrlExtractor(),
  })  : _mediaStream = mediaStream,
        _initialMediaGetter = initialMediaGetter,
        _reset = reset,
        _urlExtractor = urlExtractor;

  final Stream<List<SharedMediaFile>> _mediaStream;
  final Future<List<SharedMediaFile>> Function() _initialMediaGetter;
  final Future<dynamic> Function() _reset;
  final UrlExtractor _urlExtractor;
  Stream<String?>? _cachedTextStream;

  Stream<String?> get textStream {
    _cachedTextStream ??=
        _mediaStream.map(_extractFirstText).asBroadcastStream();
    return _cachedTextStream!;
  }

  Future<String?> getInitialText() async {
    final List<SharedMediaFile> media = await _initialMediaGetter();
    final String? text = _extractFirstText(media);
    if (text != null) await _reset();
    return text;
  }

  String? _extractFirstText(List<SharedMediaFile> media) {
    for (final SharedMediaFile file in media) {
      if (file.type != SharedMediaType.text &&
          file.type != SharedMediaType.url) {
        continue;
      }
      if (file.path.length > MarkyInputLimits.maxSharedTextLength) continue;
      final String payload = file.path.trim();
      if (payload.isEmpty) continue;
      if (_urlExtractor.extractFirst(payload) != null) return payload;
    }
    return null;
  }
}
