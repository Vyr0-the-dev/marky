import 'package:flutter_test/flutter_test.dart';
import 'package:marky/shared/errors/safe_error_details.dart';

void main() {
  test('debugOnlyErrorDetails hides sensitive details in release mode', () {
    final String? details = debugOnlyErrorDetails(
      Exception('private url https://vault.example.com/secret?token=abc'),
      stackTrace: StackTrace.fromString('private stack trace'),
      releaseMode: true,
    );

    expect(details, isNull);
  });

  test('debugOnlyErrorDetails keeps troubleshooting details outside release',
      () {
    final String? details = debugOnlyErrorDetails(
      Exception('debug-only failure detail'),
      stackTrace: StackTrace.fromString('debug stack'),
    );

    expect(details, contains('debug-only failure detail'));
    expect(details, contains('debug stack'));
  });
}
