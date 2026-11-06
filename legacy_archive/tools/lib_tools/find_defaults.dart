import 'dart:io';

void main() {
  final dir = Directory('lib/features');
  final regex = RegExp(r'=\s*AppColors\.[a-zA-Z0-9]+');
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final lines = content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (regex.hasMatch(lines[i])) {
          print('Default/assignment in ${entity.path}: ${lines[i].trim()}');
        }
      }
    }
  }
}
