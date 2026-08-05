import 'package:marky/features/import_export/data/services/share_platform.dart';

/// Pure-Dart fake that records every shared file path for test verification.
class FakeSharePlatform implements SharePlatform {
  final List<String> sharedPaths = <String>[];
  final List<String?> sharedSubjects = <String?>[];

  @override
  Future<void> shareFile(String path, {String? subject}) async {
    sharedPaths.add(path);
    sharedSubjects.add(subject);
  }

  void reset() {
    sharedPaths.clear();
    sharedSubjects.clear();
  }
}
