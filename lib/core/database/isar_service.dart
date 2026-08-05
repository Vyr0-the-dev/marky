import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Singleton-style service that manages the lifecycle of the local Isar
/// database.
///
/// Call [open] once during app bootstrap to obtain an [Isar] instance,
/// and [close] during shutdown or hot-restart cleanup.
class IsarService {
  IsarService._();

  static final IsarService _instance = IsarService._();

  /// Returns the singleton instance.
  static IsarService get instance => _instance;

  static final Logger _logger = Logger();

  Isar? _isar;

  /// The active Isar instance, or `null` if the database has not been opened.
  Isar? get isar => _isar;

  /// Opens the Isar database in the app's documents directory.
  ///
  /// [schemas] must contain at least one generated [CollectionSchema].
  /// Calling [open] when the database is already open returns the existing
  /// instance.
  ///
  /// [directory] overrides the default documents directory. Useful in tests
  /// to avoid collisions and to bypass path_provider on non-mobile platforms.
  ///
  /// Throws a [StateError] if called twice with conflicting schemas, or if
  /// [pathProvider] fails to return a directory.
  Future<Isar> open({
    required List<CollectionSchema<dynamic>> schemas,
    String? directory,
  }) async {
    if (_isar != null) {
      _logger.w('IsarService.open() called twice – returning existing instance');
      return _isar!;
    }

    if (schemas.isEmpty) {
      throw ArgumentError(
        'IsarService.open() requires at least one CollectionSchema. '
        'Ensure Isar entity classes are defined and build_runner has been run.',
      );
    }

    final String dir;
    if (directory != null) {
      dir = directory;
    } else {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        dir = appDir.path;
      } on Object catch (e, stackTrace) {
        _logger.e('Failed to resolve application documents directory', error: e, stackTrace: stackTrace);
        throw Exception('IsarService: path_provider failed – $e');
      }
    }

    _logger.i('Opening Isar at: $dir with ${schemas.length} schema(s)');

    try {
      _isar = await Isar.open(
        schemas,
        directory: dir,
        name: 'marky',
      );
      _logger.i('Isar opened successfully');
    } on Object catch (e, stackTrace) {
      _logger.e('Isar.openAsync failed', error: e, stackTrace: stackTrace);
      throw Exception('IsarService: Isar.openAsync failed at $dir – $e');
    }

    return _isar!;
  }

  /// Closes the Isar database if it is currently open.
  ///
  /// Throws a [StateError] if the database was never opened.
  Future<void> close() async {
    if (_isar == null) {
      throw StateError(
        'IsarService.close() called before open(). '
        'Ensure open() is called during bootstrap.',
      );
    }

    _logger.i('Closing Isar');
    await _isar!.close();
    _isar = null;
    _logger.i('Isar closed successfully');
  }

  /// Resets the internal Isar reference without calling close.
  ///
  /// **Use only in tests** when the underlying Isar instance has already
  /// been closed directly and the singleton needs to be returned to a
  /// clean state.
  @visibleForTesting
  void resetForTesting() {
    _isar = null;
  }
}
