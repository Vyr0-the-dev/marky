import 'dart:io';

void main() {
  final dir = Directory('lib/features');
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      bool changed = false;

      // Fix _resolveColor
      if (content.contains('Color _resolveColor(String? hex)')) {
        content = content.replaceAll('Color _resolveColor(String? hex)',
            'Color _resolveColor(BuildContext context, String? hex)');
        content = content.replaceAll(
            '_resolveColor(tag.color)', '_resolveColor(context, tag.color)');
        content = content.replaceAll('_resolveColor(collection.color)',
            '_resolveColor(context, collection.color)');
        content = content.replaceAll(
            '_resolveColor(null)', '_resolveColor(context, null)');
        content = content.replaceAllMapped(RegExp(r'_resolveColor\((.*?)\)'),
            (match) {
          if (match.group(1)!.startsWith('context')) return match.group(0)!;
          return '_resolveColor(context, ${match.group(1)})';
        });
        changed = true;
      }

      // Fix _backgroundColor
      if (content.contains('Color _backgroundColor(Color color)')) {
        content = content.replaceAll('Color _backgroundColor(Color color)',
            'Color _backgroundColor(BuildContext context, Color color)');
        content = content.replaceAllMapped(RegExp(r'_backgroundColor\((.*?)\)'),
            (match) {
          if (match.group(1)!.startsWith('context')) return match.group(0)!;
          return '_backgroundColor(context, ${match.group(1)})';
        });
        changed = true;
      }

      // Fix _buildSectionHeader
      if (content.contains('Widget _buildSectionHeader(String title)')) {
        content = content.replaceAll('Widget _buildSectionHeader(String title)',
            'Widget _buildSectionHeader(BuildContext context, String title)');
        content = content
            .replaceAllMapped(RegExp(r'_buildSectionHeader\((.*?)\)'), (match) {
          if (match.group(1)!.startsWith('context')) return match.group(0)!;
          return '_buildSectionHeader(context, ${match.group(1)})';
        });
        changed = true;
      }

      // Fix _buildSwitchTile
      if (content.contains('Widget _buildSwitchTile({')) {
        content = content.replaceAll('Widget _buildSwitchTile({',
            'Widget _buildSwitchTile(BuildContext context, {');
        content = content.replaceAll(
            '_buildSwitchTile(', '_buildSwitchTile(context, ');
        changed = true;
      }

      // Fix _buildRow in import_result_dialog
      if (content.contains(
          'Widget _buildRow(String label, int value, {Color? color})')) {
        content = content.replaceAll(
            'Widget _buildRow(String label, int value, {Color? color})',
            'Widget _buildRow(BuildContext context, String label, int value, {Color? color})');
        content = content.replaceAll('_buildRow(', '_buildRow(context, ');
        changed = true;
      }

      if (changed) {
        entity.writeAsStringSync(content);
      }
    }
  }
}
