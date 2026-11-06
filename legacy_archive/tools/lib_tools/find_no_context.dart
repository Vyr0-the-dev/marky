import 'dart:io';

void main() {
  final dir = Directory('lib/features');
  final regex = RegExp(r'AppColors\.[a-zA-Z0-9]+');
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final lines = content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (regex.hasMatch(lines[i])) {
          // Check if this file has a build method or if it's a model
          if (!content.contains('BuildContext context') &&
              !content.contains('Widget build')) {
            print('No context in ${entity.path}: ${lines[i].trim()}');
          }
        }
      }
    }
  }
}
