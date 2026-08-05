import 'package:equatable/equatable.dart';

/// Immutable aggregate result of an import operation.
class ImportResult extends Equatable {
  const ImportResult({
    required this.totalFound,
    required this.imported,
    required this.duplicatesSkipped,
    required this.failed,
    this.failureReasons = const <String>[],
    required this.elapsed,
  });

  /// Total bookmarks discovered in the source file.
  final int totalFound;

  /// Bookmarks successfully imported.
  final int imported;

  /// Bookmarks skipped because they already existed.
  final int duplicatesSkipped;

  /// Bookmarks that could not be imported due to errors.
  final int failed;

  /// Human-readable reasons for each failure.
  final List<String> failureReasons;

  /// Time spent performing the import.
  final Duration elapsed;

  @override
  List<Object?> get props => <Object?>[
        totalFound,
        imported,
        duplicatesSkipped,
        failed,
        failureReasons,
        elapsed,
      ];
}
