import 'dart:io';

void main() {
  final process =
      Process.runSync('dart', ['analyze', '--format=machine', 'lib']);
  final output = process.stdout.toString();

  final lines = output.split('\n');
  int constFixed = 0;

  for (final line in lines) {
    if (line.isEmpty) continue;
    final parts = line.split('|');
    if (parts.length < 8) continue;
    final errorType = parts[2];
    final file = parts[3];
    final row = int.parse(parts[4]) - 1; // 0-based
    final col = int.parse(parts[5]) - 1;
    final msg = parts[7];

    if (errorType == 'const_eval_method_invocation') {
      final f = File(file);
      if (f.existsSync()) {
        final contentLines = f.readAsLinesSync();
        // we need to search backward from this line to find the nearest `const `
        for (int i = row; i >= 0; i--) {
          if (contentLines[i].contains('const ')) {
            contentLines[i] = contentLines[i].replaceFirst('const ', '');
            f.writeAsStringSync(contentLines.join('\n'));
            constFixed++;
            break;
          }
        }
      }
    }
  }
  print('Removed const from $constFixed places.');
}
