import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/capture/domain/services/share_intent_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  group('ShareIntentHandler', () {
    late List<SharedMediaFile> mockInitialMedia;
    late StreamController<List<SharedMediaFile>> mockStreamController;
    late bool resetCalled;
    late ShareIntentHandler handler;

    setUp(() {
      mockInitialMedia = <SharedMediaFile>[];
      mockStreamController = StreamController<List<SharedMediaFile>>.broadcast();
      resetCalled = false;

      handler = ShareIntentHandler(
        mediaStream: mockStreamController.stream,
        initialMediaGetter: () async => List<SharedMediaFile>.from(mockInitialMedia),
        reset: () async {
          resetCalled = true;
        },
      );
    });

    tearDown(() async {
      await mockStreamController.close();
    });

    group('getInitialUrl', () {
      test('returns null when initial media is empty', () async {
        mockInitialMedia = <SharedMediaFile>[];

        final String? result = await handler.getInitialUrl();

        expect(result, isNull);
        expect(resetCalled, isFalse);
      });

      test('returns null and does not reset for non-text media', () async {
        mockInitialMedia = <SharedMediaFile>[
          SharedMediaFile(
            path: '/path/to/image.png',
            type: SharedMediaType.image,
          ),
        ];

        final String? result = await handler.getInitialUrl();

        expect(result, isNull);
        expect(resetCalled, isFalse);
      });

      test('extracts valid URL from text media and resets', () async {
        mockInitialMedia = <SharedMediaFile>[
          SharedMediaFile(
            path: 'https://example.com/article',
            type: SharedMediaType.text,
          ),
        ];

        final String? result = await handler.getInitialUrl();

        expect(result, 'https://example.com/article');
        expect(resetCalled, isTrue);
      });

      test('extracts valid URL from url media and resets', () async {
        mockInitialMedia = <SharedMediaFile>[
          SharedMediaFile(
            path: 'https://flutter.dev',
            type: SharedMediaType.url,
          ),
        ];

        final String? result = await handler.getInitialUrl();

        expect(result, 'https://flutter.dev');
        expect(resetCalled, isTrue);
      });

      test('rejects invalid text and returns null without reset', () async {
        mockInitialMedia = <SharedMediaFile>[
          SharedMediaFile(
            path: 'not a url at all',
            type: SharedMediaType.text,
          ),
        ];

        final String? result = await handler.getInitialUrl();

        expect(result, isNull);
        expect(resetCalled, isFalse);
      });

      test('rejects text missing scheme and authority', () async {
        mockInitialMedia = <SharedMediaFile>[
          SharedMediaFile(
            path: 'example.com', // Missing scheme — Uri.tryParse still parses but host may be empty
            type: SharedMediaType.text,
          ),
        ];

        final String? result = await handler.getInitialUrl();

        expect(result, isNull);
        expect(resetCalled, isFalse);
      });

      test('returns first valid URL from multi-file intent', () async {
        mockInitialMedia = <SharedMediaFile>[
          SharedMediaFile(
            path: 'just some text',
            type: SharedMediaType.text,
          ),
          SharedMediaFile(
            path: 'https://second.com',
            type: SharedMediaType.url,
          ),
          SharedMediaFile(
            path: 'https://third.com',
            type: SharedMediaType.url,
          ),
        ];

        final String? result = await handler.getInitialUrl();

        expect(result, 'https://second.com');
        expect(resetCalled, isTrue);
      });
    });

    group('urlStream', () {
      test('filters out non-text and non-url media types', () async {
        final List<String?> emitted = <String?>[];
        final StreamSubscription<String?> sub = handler.urlStream.listen(emitted.add);

        mockStreamController.add(<SharedMediaFile>[
          SharedMediaFile(
            path: '/path/to/video.mp4',
            type: SharedMediaType.video,
          ),
        ]);

        await Future<void>.delayed(Duration.zero);
        expect(emitted, <String?>[null]);

        await sub.cancel();
      });

      test('emits validated URL from text media', () async {
        final List<String?> emitted = <String?>[];
        final StreamSubscription<String?> sub = handler.urlStream.listen(emitted.add);

        mockStreamController.add(<SharedMediaFile>[
          SharedMediaFile(
            path: 'https://github.com/flutter/flutter',
            type: SharedMediaType.text,
          ),
        ]);

        await Future<void>.delayed(Duration.zero);
        expect(emitted, <String?>['https://github.com/flutter/flutter']);

        await sub.cancel();
      });

      test('emits null for invalid text in stream', () async {
        final List<String?> emitted = <String?>[];
        final StreamSubscription<String?> sub = handler.urlStream.listen(emitted.add);

        mockStreamController.add(<SharedMediaFile>[
          SharedMediaFile(
            path: 'hello world',
            type: SharedMediaType.text,
          ),
        ]);

        await Future<void>.delayed(Duration.zero);
        expect(emitted, <String?>[null]);

        await sub.cancel();
      });

      test('handles multi-file intent and takes first valid URL', () async {
        final List<String?> emitted = <String?>[];
        final StreamSubscription<String?> sub = handler.urlStream.listen(emitted.add);

        mockStreamController.add(<SharedMediaFile>[
          SharedMediaFile(
            path: 'random note',
            type: SharedMediaType.text,
          ),
          SharedMediaFile(
            path: 'https://valid.url.com',
            type: SharedMediaType.url,
          ),
        ]);

        await Future<void>.delayed(Duration.zero);
        expect(emitted, <String?>['https://valid.url.com']);

        await sub.cancel();
      });

      test('caches broadcast stream for multiple listeners', () async {
        final List<String?> emitted1 = <String?>[];
        final List<String?> emitted2 = <String?>[];

        final StreamSubscription<String?> sub1 = handler.urlStream.listen(emitted1.add);
        final StreamSubscription<String?> sub2 = handler.urlStream.listen(emitted2.add);

        mockStreamController.add(<SharedMediaFile>[
          SharedMediaFile(
            path: 'https://shared.stream',
            type: SharedMediaType.text,
          ),
        ]);

        await Future<void>.delayed(Duration.zero);
        expect(emitted1, <String?>['https://shared.stream']);
        expect(emitted2, <String?>['https://shared.stream']);

        await sub1.cancel();
        await sub2.cancel();
      });
    });
  });
}
