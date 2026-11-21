import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/storage/cache_management_service.dart';

void main() {
  group('CacheManagementService', () {
    test('computes combined disk size across reader cache and thumbnails and clears them',
        () async {
      final Directory docDir =
          await Directory.systemTemp.createTemp('marky_cache_doc_');
      final Directory tempDir =
          await Directory.systemTemp.createTemp('marky_cache_tmp_');
      addTearDown(() async {
        if (docDir.existsSync()) await docDir.delete(recursive: true);
        if (tempDir.existsSync()) await tempDir.delete(recursive: true);
      });

      final Directory readerDir = Directory('${docDir.path}/reader_cache')
        ..createSync(recursive: true);
      final Directory thumbDir = Directory('${docDir.path}/thumbnails')
        ..createSync(recursive: true);
      final Directory legacyDir = Directory('${tempDir.path}/reader_cache')
        ..createSync(recursive: true);

      File('${readerDir.path}/a.json').writeAsBytesSync(List<int>.filled(500, 1));
      File('${thumbDir.path}/b.jpg').writeAsBytesSync(List<int>.filled(1500, 2));
      File('${legacyDir.path}/c.json').writeAsBytesSync(List<int>.filled(250, 3));

      final CacheManagementService service = CacheManagementService(
        documentsDirProvider: () async => docDir,
        tempDirProvider: () async => tempDir,
      );

      expect(await service.computeTotalBytes(), 2250);

      await service.clearAll();

      expect(await service.computeTotalBytes(), 0);
      expect(File('${readerDir.path}/a.json').existsSync(), isFalse);
      expect(File('${thumbDir.path}/b.jpg').existsSync(), isFalse);
      expect(File('${legacyDir.path}/c.json').existsSync(), isFalse);
    });

    test('formats byte sizes cleanly', () {
      expect(CacheManagementService.formatBytes(0), '0 B');
      expect(CacheManagementService.formatBytes(512), '512 B');
      expect(CacheManagementService.formatBytes(2048), '2 KB');
      expect(CacheManagementService.formatBytes(3 * 1024 * 1024), '3.0 MB');
    });
  });
}
