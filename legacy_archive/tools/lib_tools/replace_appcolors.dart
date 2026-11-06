import 'dart:io';

void main() {
  final dir = Directory('lib/features');
  final map = {
    'AppColors.surface1': 'Theme.of(context).colorScheme.surface',
    'AppColors.surface2': 'Theme.of(context).colorScheme.surfaceContainer',
    'AppColors.surface3':
        'Theme.of(context).colorScheme.surfaceContainerHighest',
    'AppColors.textPrimary': 'Theme.of(context).colorScheme.onSurface',
    'AppColors.textSecondary': 'Theme.of(context).colorScheme.onSurfaceVariant',
    'AppColors.textTertiary':
        'Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)',
    'AppColors.accentPrimary': 'Theme.of(context).colorScheme.primary',
    'AppColors.accentSecondary': 'Theme.of(context).colorScheme.secondary',
    'AppColors.accentLuxe': 'Theme.of(context).colorScheme.tertiary',
    'AppColors.danger': 'Theme.of(context).colorScheme.error',
    'AppColors.warning':
        'Theme.of(context).colorScheme.errorContainer', // or Colors.orange
    'AppColors.success': 'Colors.green', // or something else
    'AppColors.border': 'Theme.of(context).colorScheme.outlineVariant',
    'AppColors.base': 'Theme.of(context).colorScheme.inverseSurface',
  };

  int filesChanged = 0;
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      bool changed = false;

      // first handle const AppColors
      final regexConst = RegExp(r'const\s+(.*?)(AppColors\.[a-zA-Z0-9_]+)');
      content = content.replaceAllMapped(regexConst, (match) {
        changed = true;
        // removing const but keeping everything else
        return '${match.group(1)}${match.group(2)}';
      });

      final regex = RegExp(
          r'const\s+([a-zA-Z0-9_<>]+\(.*?)AppColors\.([a-zA-Z0-9_]+)',
          dotAll: true);
      // actually, just stripping "const " if AppColors is on the SAME line is easiest:
      final lines = content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('AppColors.') && lines[i].contains('const ')) {
          // naive removal of const on the same line if it's before AppColors
          lines[i] = lines[i].replaceAll('const ', '');
          changed = true;
        }
      }
      content = lines.join('\n');

      map.forEach((key, value) {
        if (content.contains(key)) {
          content = content.replaceAll(key, value);
          changed = true;
        }
      });

      if (changed) {
        entity.writeAsStringSync(content);
        filesChanged++;
      }
    }
  }
  print('Changed $filesChanged files.');
}
