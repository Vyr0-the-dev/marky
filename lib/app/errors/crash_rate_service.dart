import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import 'package:marky/shared/models/crash_log.dart';

/// Lightweight crash-rate observability service.
///
/// Tracks uncaught framework errors and platform dispatcher errors,
/// persisting crash metadata to Isar for durability across sessions.
/// Falls back to in-memory storage when Isar is not yet available.
///
/// Initialize once during app bootstrap via [initialize] before
/// any other error handlers so all uncaught errors are recorded.
class CrashRateService {
  CrashRateService._();

  static final CrashRateService _instance = CrashRateService._();

  /// Returns the singleton instance.
  static CrashRateService get instance => _instance;

  final Logger _logger = Logger();

  int _totalCrashCount = 0;
  DateTime? _lastCrashTimestamp;
  String? _lastCrashError;
  String? _lastCrashStackTrace;

  Isar? _isar;
  bool _initialized = false;
  FlutterExceptionHandler? _previousFlutterError;
  bool Function(Object, StackTrace)? _previousPlatformError;

  /// Total number of crashes recorded since app launch.
  int get totalCrashCount => _totalCrashCount;

  /// Timestamp of the most recent crash, or `null` if none.
  DateTime? get lastCrashTimestamp => _lastCrashTimestamp;

  /// Error message of the most recent crash, or `null` if none.
  String? get lastCrashError => _lastCrashError;

  /// Stack trace of the most recent crash, or `null` if none.
  String? get lastCrashStackTrace => _lastCrashStackTrace;

  /// Whether any crashes have been recorded.
  bool get hasCrashes => _totalCrashCount > 0;

  /// The injected Isar instance, or `null` if not yet set.
  Isar? get isar => _isar;

  /// Injects an Isar instance so crash data can be persisted.
  ///
  /// Call this once after Isar is open (e.g., inside [bootstrap]).
  /// If an Isar instance was already injected, this replaces it.
  // ignore: use_setters_to_change_properties
  void setIsar(Isar isar) {
    _isar = isar;
  }

  /// Loads persisted crash data from Isar if available.
  ///
  /// Call this after setting [isar] during bootstrap to restore the
  /// crash counter across sessions.
  Future<void> loadPersistedData() async {
    if (_isar == null) {
      _logger.w('CrashRateService: loadPersistedData called before setIsar');
      return;
    }

    try {
      final CrashLog? log = await _isar!.crashLogs.get(0);
      if (log != null) {
        _totalCrashCount = log.totalCrashCount;
        _lastCrashTimestamp = log.lastCrashTimestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(log.lastCrashTimestamp!)
            : null;
        _lastCrashError = log.lastCrashError;
        _lastCrashStackTrace = log.lastCrashStackTrace;
        _logger.i(
          'CrashRateService: loaded persisted crash count=$_totalCrashCount',
        );
      }
    } on Object catch (e, stackTrace) {
      _logger.e(
        'CrashRateService: failed to load persisted crash data',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Initializes crash handlers.
  ///
  /// Wires [FlutterError.onError] and
  /// [PlatformDispatcher.instance.onError] to record every uncaught
  /// exception. Previously set handlers are preserved and called after
  /// recording so existing instrumentation (e.g., Firebase Crashlytics)
  /// is not disrupted.
  ///
  /// Idempotent: subsequent calls are ignored until [resetForTesting]
  /// is invoked.
  void initialize() {
    if (_initialized) {
      _logger.w('CrashRateService: already initialized, skipping');
      return;
    }
    _initialized = true;

    _logger.i('CrashRateService: initializing crash handlers');

    // Capture framework-level widget errors.
    _previousFlutterError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      _recordCrash(
        error: details.exceptionAsString(),
        stackTrace: details.stack?.toString(),
      );
      _previousFlutterError?.call(details);
    };

    // Capture zone-level / async uncaught errors.
    _previousPlatformError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _recordCrash(
        error: error.toString(),
        stackTrace: stack.toString(),
      );
      return _previousPlatformError?.call(error, stack) ?? false;
    };
  }

  /// Records a single crash incident and persists to Isar if available.
  void _recordCrash({required String error, String? stackTrace}) {
    _totalCrashCount++;
    _lastCrashTimestamp = DateTime.now();
    _lastCrashError = error;
    _lastCrashStackTrace = stackTrace;

    _logger.e(
      'CrashRateService: crash recorded (#$_totalCrashCount)',
      error: error,
      stackTrace: stackTrace != null
          ? StackTrace.fromString(stackTrace)
          : StackTrace.current,
    );

    _persistToIsar();
  }

  /// Writes current crash state to Isar asynchronously.
  ///
  /// Fire-and-forget: errors are logged but never thrown.
  void _persistToIsar() {
    final Isar? isar = _isar;
    if (isar == null) return;

    final CrashLog log = CrashLog(
      totalCrashCount: _totalCrashCount,
      lastCrashTimestamp: _lastCrashTimestamp?.millisecondsSinceEpoch,
      lastCrashError: _lastCrashError,
      lastCrashStackTrace: _lastCrashStackTrace,
    )..id = 0;

    unawaited(
      isar.writeTxn(() async {
        await isar.crashLogs.put(log);
      }).catchError((Object e, StackTrace stackTrace) {
        _logger.e(
          'CrashRateService: failed to persist crash data',
          error: e,
          stackTrace: stackTrace,
        );
        // Swallow persistence errors so a crash never crashes the app.
        return null;
      }),
    );
  }

  /// Resets all crash counters, metadata, and error handlers.
  ///
  /// Restores [FlutterError.onError] and
  /// [PlatformDispatcher.instance.onError] to their values before
  /// [initialize] was called. **Use only in tests.**
  @visibleForTesting
  void resetForTesting() {
    if (_initialized) {
      FlutterError.onError = _previousFlutterError;
      PlatformDispatcher.instance.onError = _previousPlatformError;
      _previousFlutterError = null;
      _previousPlatformError = null;
      _initialized = false;
    }

    _totalCrashCount = 0;
    _lastCrashTimestamp = null;
    _lastCrashError = null;
    _lastCrashStackTrace = null;
    _isar = null;
  }
}
