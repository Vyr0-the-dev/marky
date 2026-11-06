import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  final Map<String, String> replacements = {
    'AppColors.base': 'Theme.of(context).scaffoldBackgroundColor',
    'AppColors.surface1': 'Theme.of(context).colorScheme.surface',
    'AppColors.surface2': 'Theme.of(context).colorScheme.surfaceContainer',
    'AppColors.surface3': 'Theme.of(context).colorScheme.surfaceContainerHighest',
    'AppColors.border': 'Theme.of(context).colorScheme.outlineVariant',
    'AppColors.textPrimary': 'Theme.of(context).colorScheme.onSurface',
    'AppColors.textSecondary': 'Theme.of(context).colorScheme.onSurfaceVariant',
    'AppColors.textTertiary': 'Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)',
    'AppColors.accentPrimary': 'Theme.of(context).colorScheme.primary',
    'AppColors.accentSecondary': 'Theme.of(context).colorScheme.secondary',
    'AppColors.accentTertiary': 'Theme.of(context).colorScheme.tertiary',
    'AppColors.accentLuxe': 'Theme.of(context).colorScheme.tertiary', // Using tertiary for luxe
    'AppColors.danger': 'Theme.of(context).colorScheme.error',
    'AppColors.warning': 'Colors.orange', // Fallback
    'AppColors.success': 'Colors.green', // Fallback
  };

  for (var file in files) {
    String content = file.readAsStringSync();
    if (!content.contains('AppColors.')) continue;
    
    // We only want to replace if there is a 'context' in scope. A simple heuristic:
    // If the file imports material and has 'Widget build(BuildContext context' or similar, we replace.
    // However, this might break if AppColors is used outside build.
    // Let's just replace and we can run dart analyze to see if it breaks.
    
    // Actually, a safer approach is to only replace inside methods that have `context`.
    // But for a quick refactor, let's just do a global replace for the presentation layer.
    if (file.path.contains('presentation') || file.path.contains('shared\\widgets') || file.path.contains('shared/widgets')) {
       String original = content;
       for (var entry in replacements.entries) {
          content = content.replaceAll(entry.key, entry.value);
       }
       if (original != content) {
          file.writeAsStringSync(content);
          print('Updated ${file.path}');
       }
    }
  }
}