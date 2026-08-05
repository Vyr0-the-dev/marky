import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/bootstrap/app_bootstrap.dart';
import 'package:marky/core/ai/domain/models/embedding_document.dart';
import 'package:marky/core/database/isar_service.dart';
import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/automation_rule.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/note.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:marky/shared/models/tag.dart';
import 'package:marky/shared/models/vault_config.dart';

/// Benchmarks the cold-start bootstrap time of the Marky app.
///
/// Measures the time from [bootstrap] entry to the [run] callback being
/// invoked, which is the point where the app widget tree is mounted.
/// The benchmark opens a real Isar database with all schemas and
/// initializes all domain services, but skips notification service
/// initialization and reminder rescheduling (platform-dependent and
/// non-deterministic in tests) via [skipNotifications].
///
/// Success criterion: cold start < 2500ms.
void main() {
  group('Cold-start benchmark', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('marky_cold_start_test_');
    });

    tearDown(() async {
      // Ensure IsarService singleton is reset between tests.
      final service = IsarService.instance;
      if (service.isar != null) {
        try {
          await service.close();
        } on Object {
          // ignore: invalid_use_of_visible_for_testing_member
          service.resetForTesting();
        }
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('bootstrap completes in under 2500ms', () async {
      final Stopwatch stopwatch = Stopwatch()..start();
      bool runCalled = false;

      await bootstrap(
        run: () {
          runCalled = true;
        },
        isarDirectory: tempDir.path,
        skipNotifications: true,
      );

      stopwatch.stop();

      expect(runCalled, isTrue,
          reason: 'run callback should have been invoked');
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2500),
        reason: 'Cold-start bootstrap should complete in under 2500ms '
            '(actual: ${stopwatch.elapsedMilliseconds}ms)',
      );

      // Clean up Isar instance opened by bootstrap.
      // ignore: invalid_use_of_visible_for_testing_member
      // IsarService.instance.close() may fail if already closed; wrap safely.
    });

    test('Isar open with all schemas completes in under 1000ms', () async {
      final Stopwatch stopwatch = Stopwatch()..start();

      final Isar isar = await Isar.open(
        <CollectionSchema<dynamic>>[
          AppSettingsSchema,
          AutomationRuleSchema,
          BookmarkItemSchema,
          TagSchema,
          BookmarkCollectionSchema,
          NoteSchema,
          ReminderSchema,
          VaultConfigSchema,
          EmbeddingDocumentSchema,
        ],
        directory: tempDir.path,
      );

      stopwatch.stop();
      await isar.close();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Isar open with all schemas should complete in under 1000ms '
            '(actual: ${stopwatch.elapsedMilliseconds}ms)',
      );
    });
  });
}
