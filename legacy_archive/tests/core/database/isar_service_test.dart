import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/database/isar_service.dart';
import 'package:marky/shared/models/app_settings.dart';

void main() {
  group('IsarService', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('isar_service_test_');
    });

    tearDown(() async {
      // Ensure IsarService singleton is fully reset between tests.
      final service = IsarService.instance;
      if (service.isar != null) {
        try {
          await service.close();
        } on Object {
          // If close fails (e.g., already closed), force-reset the internal
          // pointer so subsequent tests start from a clean singleton state.
          // ignore: invalid_use_of_visible_for_testing_member
          service.resetForTesting();
        }
      }
      // Clean up temp directory.
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('instance returns the same singleton', () {
      final a = IsarService.instance;
      final b = IsarService.instance;
      expect(identical(a, b), isTrue);
    });

    test('open creates an Isar instance and close disposes it', () async {
      final service = IsarService.instance;

      expect(service.isar, isNull);

      final isar = await service.open(
        schemas: [AppSettingsSchema],
        directory: tempDir.path,
      );

      expect(isar, isNotNull);
      expect(isar.isOpen, isTrue);
      expect(service.isar, same(isar));

      await service.close();

      expect(service.isar, isNull);
      expect(isar.isOpen, isFalse);
    });

    test('open called twice returns existing instance', () async {
      final service = IsarService.instance;

      final first = await service.open(
        schemas: [AppSettingsSchema],
        directory: tempDir.path,
      );

      final second = await service.open(
        schemas: [AppSettingsSchema],
        directory: tempDir.path,
      );

      expect(second, same(first));
    });

    test('close before open throws StateError', () async {
      final service = IsarService.instance;

      // Ensure the singleton is in a closed state.
      // If a prior test left it open, close it first.
      if (service.isar != null && service.isar!.isOpen) {
        await service.close();
      }

      expect(service.isar, isNull);
      expect(service.close, throwsA(isA<StateError>()));
    });

    test('open with empty schemas throws ArgumentError', () async {
      final service = IsarService.instance;

      expect(
        () => service.open(schemas: [], directory: tempDir.path),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
