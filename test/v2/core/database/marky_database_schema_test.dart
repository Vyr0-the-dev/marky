import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/database/marky_database.dart';

void main() {
  test('database schema version and collection order are explicit', () {
    expect(MarkyDatabase.defaultName, 'marky_v2');
    expect(MarkyDatabase.schemaVersion, 1);
    expect(
      MarkyDatabase.schemaNames,
      <String>[
        'BookmarkEntity',
        'TagEntity',
        'CollectionEntity',
        'ReminderEntity',
        'AutomationRuleEntity',
        'BackupMetaEntity',
        'NoteEntity',
        'SearchQueryEntity',
      ],
    );
    expect(
      MarkyDatabase.schemas.map((schema) => schema.name).toList(),
      MarkyDatabase.schemaNames,
    );
  });
}
