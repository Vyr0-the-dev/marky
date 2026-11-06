import 'dart:io';

void main() {
  final output = Process.runSync('dart', ['analyze', '--format=machine', 'lib'])
      .stdout
      .toString();
  final lines = output.split('\n');

  for (final line in lines) {
    if (line.isEmpty) continue;
    final parts = line.split('|');
    if (parts.length < 8) continue;
    final errorType = parts[2];
    final file = parts[3];
    final row = int.parse(parts[4]) - 1; // 0-based
    if (errorType == 'UNDEFINED_IDENTIFIER' && parts[7].contains("'context'")) {
      final f = File(file);
      if (f.existsSync()) {
        final contentLines = f.readAsLinesSync();
        print('--- $file:$row ---');
        for (int i = row - 2; i <= row + 2; i++) {
          if (i >= 0 && i < contentLines.length) {
            print('${i == row ? ">> " : "   "}${contentLines[i]}');
          }
        }
      }
    }
  }
}
