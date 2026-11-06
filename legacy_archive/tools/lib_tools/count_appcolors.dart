import 'dart:io';

void main() {
  int count = 0;
  int fileCount = 0;
  final dir = Directory('lib/features');
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final int matches = 'AppColors.'.allMatches(content).length;
      if (matches > 0) {
        count += matches;
        fileCount++;
      }
    }
  }
  print('Found $count occurrences in $fileCount files in lib/features.');

  count = 0;
  fileCount = 0;
  final dir2 = Directory('lib/shared');
  for (final entity in dir2.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final int matches = 'AppColors.'.allMatches(content).length;
      if (matches > 0) {
        count += matches;
        fileCount++;
      }
    }
  }
  print('Found $count occurrences in $fileCount files in lib/shared.');
}
