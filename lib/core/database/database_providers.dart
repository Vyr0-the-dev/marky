import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/database/marky_database.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

/// Riverpod handle to the open [Isar] instance.
///
/// Same override pattern as [appSettingsRepositoryProvider]: bootstrap
/// awaits [MarkyDatabase.open] *before* building the [ProviderScope]
/// and injects the result here, so all reads downstream are
/// synchronous. We deliberately do **not** wrap this in an
/// `AsyncValue` — every feature that touches Isar would have to
/// handle a loading state that's only ever transient, and the
/// app-wide splash screen already covers the open window.
final Provider<Isar> markyIsarProvider = Provider<Isar>((Ref ref) {
  throw UnimplementedError(
    'markyIsarProvider must be overridden at ProviderScope. Call '
    'markyDatabaseBootstrapOverrides() during app bootstrap and pass '
    'the result to ProviderScope.overrides.',
  );
});

/// Builds the override list for production bootstrap.
///
/// Resolves the documents directory, opens the v2 database, and
/// returns an override that pins the [markyIsarProvider] to the live
/// instance. Hot-restart safe — Isar deduplicates opens on the same
/// `(directory, name)` pair.
Future<List<Override>> markyDatabaseBootstrapOverrides({
  String? directoryOverride,
}) async {
  final ({Isar isar, List<Override> overrides}) bootstrap =
      await markyDatabaseBootstrap(directoryOverride: directoryOverride);
  return bootstrap.overrides;
}

Future<({Isar isar, List<Override> overrides})> markyDatabaseBootstrap({
  String? directoryOverride,
}) async {
  final String directory =
      directoryOverride ?? (await getApplicationDocumentsDirectory()).path;
  final Isar isar = await MarkyDatabase.open(directory: directory);
  return (
    isar: isar,
    overrides: <Override>[
      markyIsarProvider.overrideWithValue(isar),
    ],
  );
}

/// Test helper: opens a freshly-named Isar in [directory] and returns
/// both the instance and the override list. Tests use this to seed a
/// [ProviderScope] without leaking instances across cases.
///
/// Caller is responsible for closing [Isar] in tearDown — typically
/// `await isar.close(deleteFromDisk: true)`.
@visibleForTesting
Future<({Isar isar, List<Override> overrides})> testMarkyDatabase({
  required String directory,
  String? name,
}) async {
  final Isar isar = await MarkyDatabase.open(
    directory: directory,
    name: name ?? 'test_${DateTime.now().microsecondsSinceEpoch}',
  );
  return (
    isar: isar,
    overrides: <Override>[markyIsarProvider.overrideWithValue(isar)],
  );
}
