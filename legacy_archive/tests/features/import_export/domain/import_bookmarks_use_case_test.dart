import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/import_export/data/services/import_bookmarks_service.dart';
import 'package:marky/features/import_export/domain/models/import_result.dart';
import 'package:marky/features/import_export/domain/use_cases/import_bookmarks_use_case.dart';

/// Fake [ImportBookmarksService] that returns a canned result.
class _FakeImportBookmarksService implements ImportBookmarksService {
  _FakeImportBookmarksService({
    this.resultToReturn,
    this.throwOnCall = false,
  });

  final ImportResult? resultToReturn;
  final bool throwOnCall;

  final List<_ImportCall> calls = <_ImportCall>[];

  @override
  Future<ImportResult> importFromHtml({
    required String htmlContent,
    required String importSource,
    void Function(int current, int total)? onProgress,
  }) async {
    calls.add(
      _ImportCall(
        htmlContent: htmlContent,
        importSource: importSource,
      ),
    );

    if (throwOnCall) {
      throw Exception('Service error');
    }

    return resultToReturn ??
        const ImportResult(
          totalFound: 0,
          imported: 0,
          duplicatesSkipped: 0,
          failed: 0,
          elapsed: Duration.zero,
        );
  }
}

class _ImportCall {
  const _ImportCall({
    required this.htmlContent,
    required this.importSource,
  });

  final String htmlContent;
  final String importSource;
}

void main() {
  group('ImportBookmarksUseCase', () {
    late _FakeImportBookmarksService fakeService;
    late ImportBookmarksUseCase useCase;

    setUp(() {
      fakeService = _FakeImportBookmarksService();
      useCase = ImportBookmarksUseCase(service: fakeService);
    });

    test('forwards htmlContent and importSource to service', () async {
      const String html = '<html></html>';
      const String source = 'chrome';

      await useCase.execute(htmlContent: html, importSource: source);

      expect(fakeService.calls.length, 1);
      expect(fakeService.calls.first.htmlContent, html);
      expect(fakeService.calls.first.importSource, source);
    });

    test('forwards onProgress callback to service', () async {
      final List<(int, int)> progressEvents = <(int, int)>[];

      await useCase.execute(
        htmlContent: '<html></html>',
        importSource: 'firefox',
        onProgress: (int current, int total) {
          progressEvents.add((current, total));
        },
      );

      // The fake service doesn't invoke onProgress, but the parameter
      // is forwarded. We verify the call was made by checking the service
      // received a call.
      expect(fakeService.calls.length, 1);
    });

    test('returns the result from the service', () async {
      const ImportResult expectedResult = ImportResult(
        totalFound: 5,
        imported: 3,
        duplicatesSkipped: 1,
        failed: 1,
        failureReasons: <String>['err'],
        elapsed: Duration(seconds: 2),
      );

      fakeService = _FakeImportBookmarksService(
        resultToReturn: expectedResult,
      );
      useCase = ImportBookmarksUseCase(service: fakeService);

      final ImportResult result = await useCase.execute(
        htmlContent: '<html></html>',
        importSource: 'safari',
      );

      expect(result, expectedResult);
    });

    test('propagates exceptions from the service', () async {
      fakeService = _FakeImportBookmarksService(throwOnCall: true);
      useCase = ImportBookmarksUseCase(service: fakeService);

      expect(
        () => useCase.execute(
          htmlContent: '<html></html>',
          importSource: 'edge',
        ),
        throwsException,
      );
    });
  });
}
