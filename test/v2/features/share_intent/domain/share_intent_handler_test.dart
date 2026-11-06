import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/input/marky_input_limits.dart';
import 'package:marky/features/share_intent/domain/share_intent_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  test('getInitialText returns valid shared text and resets consumed payload',
      () async {
    bool resetCalled = false;
    final ShareIntentHandler handler = ShareIntentHandler(
      mediaStream: const Stream<List<SharedMediaFile>>.empty(),
      initialMediaGetter: () async => <SharedMediaFile>[
        SharedMediaFile(
          path: 'Read this https://example.com/article',
          type: SharedMediaType.text,
        ),
      ],
      reset: () async {
        resetCalled = true;
      },
    );

    final String? text = await handler.getInitialText();

    expect(text, 'Read this https://example.com/article');
    expect(resetCalled, isTrue);
  });

  test('getInitialText ignores oversized shared text without resetting',
      () async {
    bool resetCalled = false;
    final ShareIntentHandler handler = ShareIntentHandler(
      mediaStream: const Stream<List<SharedMediaFile>>.empty(),
      initialMediaGetter: () async => <SharedMediaFile>[
        SharedMediaFile(
          path:
              '${'x' * MarkyInputLimits.maxSharedTextLength} https://example.com',
          type: SharedMediaType.text,
        ),
      ],
      reset: () async {
        resetCalled = true;
      },
    );

    final String? text = await handler.getInitialText();

    expect(text, isNull);
    expect(resetCalled, isFalse);
  });
}
