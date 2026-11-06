import 'dart:io';

void main() {
  final output = Process.runSync('dart', ['analyze', '--format=machine', 'lib'])
      .stdout
      .toString();
  final lines = output.split('\n');
  final Set<String> undefinedContextFiles = {};

  for (final line in lines) {
    if (line.isEmpty) continue;
    final parts = line.split('|');
    if (parts.length < 8) continue;
    final errorType = parts[2];
    final file = parts[3];
    if (errorType == 'UNDEFINED_IDENTIFIER' && parts[7].contains("'context'")) {
      undefinedContextFiles.add(file);
    }
  }

  for (final file in undefinedContextFiles) {
    print(file);
  }
}
