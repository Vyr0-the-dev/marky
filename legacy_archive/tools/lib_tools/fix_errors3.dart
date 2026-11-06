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

    if (errorType == 'CONST_EVAL_METHOD_INVOCATION') {
      final f = File(file);
      if (f.existsSync()) {
        final contentLines = f.readAsLinesSync();
        // search backward from this line up to 5 lines
        for (int i = row; i >= 0 && i >= row - 5; i--) {
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
