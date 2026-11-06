@Tags(<String>['integration'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/marky_database.dart';
import 'package:marky/features/search/data/isar_search_query_repository.dart';
import 'package:marky/features/search/domain/search_query.dart';
import 'package:marky/features/search/domain/search_query_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late SearchQueryRepository repo;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('search_query_repo_test_');
    isar = await MarkyDatabase.open(
      directory: tempDir.path,
      name: 'test_${tempDir.path.hashCode}',
    );
    repo = IsarSearchQueryRepository(isar);
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('recordRecent dedupes normalized query and increments use count',
      () async {
    final SearchQuery first = await repo.recordRecent(' Flutter   Tips ');
    final SearchQuery second = await repo.recordRecent('flutter tips');

    expect(second.id, first.id);
    expect(second.normalizedQuery, 'flutter tips');
    expect(second.useCount, 2);

    final List<SearchQuery> recent = await repo.getRecent();
    expect(recent, hasLength(1));
    expect(recent.single.query, 'flutter tips');
  });

  test('getRecent returns most recently used first and respects limit',
      () async {
    await repo.recordRecent('alpha');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repo.recordRecent('beta');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repo.recordRecent('gamma');

    final List<SearchQuery> recent = await repo.getRecent(limit: 2);

    expect(recent.map((SearchQuery q) => q.query), <String>['gamma', 'beta']);
  });

  test('saveSearch promotes query into saved list', () async {
    await repo.recordRecent('tag:dart is:favorite');
    final SearchQuery saved = await repo.saveSearch('tag:dart is:favorite');

    expect(saved.isSaved, isTrue);
    expect(saved.savedAt, isNotNull);

    final List<SearchQuery> savedSearches = await repo.getSaved();
    expect(savedSearches.single.normalizedQuery, 'tag:dart is:favorite');
  });

  test('unsave removes from saved list without deleting recent row', () async {
    final SearchQuery saved = await repo.saveSearch('domain:flutter.dev');

    await repo.unsave(saved.id!);

    expect(await repo.getSaved(), isEmpty);
    expect(await repo.findByNormalizedQuery('domain:flutter.dev'), isNotNull);
  });

  test('clearRecent hides recent rows without touching saved searches',
      () async {
    await repo.recordRecent('flutter');
    await repo.saveSearch('dart');

    await repo.clearRecent();

    expect(await repo.getRecent(), isEmpty);
    expect(await repo.getSaved(), hasLength(1));
  });

  test('watchRecent emits updates', () async {
    final List<List<SearchQuery>> emissions = <List<SearchQuery>>[];
    final StreamSubscription<List<SearchQuery>> sub =
        repo.watchRecent().listen(emissions.add);

    await Future<void>.delayed(Duration.zero);
    await repo.recordRecent('flutter');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await sub.cancel();

    expect(emissions, isNotEmpty);
    expect(emissions.last.map((SearchQuery q) => q.query), <String>['flutter']);
  });
}
