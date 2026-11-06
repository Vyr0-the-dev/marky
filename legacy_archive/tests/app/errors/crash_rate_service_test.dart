import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/errors/crash_rate_service.dart';
import 'package:marky/shared/models/crash_log.dart';

void main() {
  group('CrashRateService', () {
    late CrashRateService service;
    late Directory tempDir;
    late Isar testIsar;

    setUp(() async {
      service = CrashRateService.instance;
      service.resetForTesting();

      tempDir = Directory.systemTemp.createTempSync('crash_rate_test_');
      testIsar = await Isar.open(
        <CollectionSchema<dynamic>>[CrashLogSchema],
        directory: tempDir.path,
      );
      service.setIsar(testIsar);
      await service.loadPersistedData();
    });

    tearDown(() async {
      service.resetForTesting();
      if (testIsar.isOpen) {
        await testIsar.close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('initial state has zero crashes', () {
      expect(service.totalCrashCount, 0);
      expect(service.hasCrashes, isFalse);
      expect(service.lastCrashTimestamp, isNull);
      expect(service.lastCrashError, isNull);
      expect(service.lastCrashStackTrace, isNull);
    });

    test('initialize wires FlutterError.onError', () {
      final FlutterExceptionHandler? originalHandler = FlutterError.onError;

      service.initialize();

      expect(FlutterError.onError, isNotNull);
      expect(FlutterError.onError, isNot(originalHandler));
    });

    test('initialize wires PlatformDispatcher.onError', () {
      final bool Function(Object, StackTrace)? originalHandler =
          PlatformDispatcher.instance.onError;

      service.initialize();

      expect(PlatformDispatcher.instance.onError, isNotNull);
      expect(PlatformDispatcher.instance.onError, isNot(originalHandler));
    });

    test('initialize is idempotent', () {
      service.initialize();
      final FlutterExceptionHandler? firstHandler = FlutterError.onError;
      final bool Function(Object, StackTrace)? firstPlatformHandler =
          PlatformDispatcher.instance.onError;

      service.initialize();

      expect(FlutterError.onError, same(firstHandler));
      expect(PlatformDispatcher.instance.onError, same(firstPlatformHandler));
    });

    test('records crash via FlutterError.onError', () {
      service.initialize();

      // Simulate a widget build error.
      FlutterError.reportError(FlutterErrorDetails(
        exception: Exception('Test widget error'),
        stack: StackTrace.current,
      ));

      expect(service.totalCrashCount, 1);
      expect(service.hasCrashes, isTrue);
      expect(service.lastCrashTimestamp, isNotNull);
      expect(service.lastCrashError, contains('Test widget error'));
      expect(service.lastCrashStackTrace, isNotNull);
    });

    test('records multiple crashes and increments count', () {
      service.initialize();

      FlutterError.reportError(FlutterErrorDetails(
        exception: Exception('First error'),
        stack: StackTrace.current,
      ));
      FlutterError.reportError(FlutterErrorDetails(
        exception: Exception('Second error'),
        stack: StackTrace.current,
      ));

      expect(service.totalCrashCount, 2);
      expect(service.lastCrashError, contains('Second error'));
    });

    test('resetForTesting clears all state and restores handlers', () {
      service.initialize();
      final FlutterExceptionHandler? handlerBeforeReset = FlutterError.onError;

      FlutterError.reportError(FlutterErrorDetails(
        exception: Exception('Error to be reset'),
        stack: StackTrace.current,
      ));

      expect(service.totalCrashCount, 1);

      service.resetForTesting();

      expect(service.totalCrashCount, 0);
      expect(service.hasCrashes, isFalse);
      expect(service.lastCrashTimestamp, isNull);
      expect(service.lastCrashError, isNull);
      expect(service.lastCrashStackTrace, isNull);
      expect(FlutterError.onError, isNot(handlerBeforeReset));
    });

    test('persists crash data to Isar', () async {
      service.initialize();

      FlutterError.reportError(FlutterErrorDetails(
        exception: Exception('Persisted error'),
        stack: StackTrace.current,
      ));

      expect(service.totalCrashCount, 1);

      // Allow async persistence to complete.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final CrashLog? log = await testIsar.crashLogs.get(0);
      expect(log, isNotNull);
      expect(log!.totalCrashCount, 1);
      expect(log.lastCrashError, contains('Persisted error'));
    });

    test('loadPersistedData restores crash count across sessions', () async {
      // Simulate a prior crash persisted in Isar.
      final CrashLog existingLog = CrashLog(
        totalCrashCount: 5,
        lastCrashTimestamp: DateTime(2024).millisecondsSinceEpoch,
        lastCrashError: 'Prior error',
        lastCrashStackTrace: 'Prior stack',
      )..id = 0;

      await testIsar.writeTxn(() async {
        await testIsar.crashLogs.put(existingLog);
      });

      await service.loadPersistedData();

      expect(service.totalCrashCount, 5);
      expect(service.lastCrashError, 'Prior error');
      expect(service.lastCrashStackTrace, 'Prior stack');
    });
  });
}
