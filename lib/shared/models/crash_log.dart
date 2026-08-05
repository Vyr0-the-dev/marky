import 'package:isar/isar.dart';

part 'crash_log.g.dart';

/// Single-row crash telemetry stored in Isar for durability across sessions.
///
/// Always use [id] = 0 so only one row ever exists.
@collection
class CrashLog {
  CrashLog({
    this.totalCrashCount = 0,
    this.lastCrashTimestamp,
    this.lastCrashError,
    this.lastCrashStackTrace,
  });

  /// Fixed id for the single crash-log row.
  Id id = 0;

  /// Total number of crashes recorded.
  int totalCrashCount;

  /// Epoch milliseconds of the most recent crash, or `null` if none.
  int? lastCrashTimestamp;

  /// Error message of the most recent crash, or `null` if none.
  String? lastCrashError;

  /// Stack trace of the most recent crash, or `null` if none.
  String? lastCrashStackTrace;
}
