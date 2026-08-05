const fs = require('fs');
const path = require('path');

const files = fs.readFileSync(process.argv[2] || 'test_files.txt', 'utf8')
  .split('\n')
  .filter(Boolean);

for (const file of files) {
  let content = fs.readFileSync(file, 'utf8');

  // getAll with arrow bodies
  content = content.replace(
    /Future<List<BookmarkItem>> getAll\(\) async =>/g,
    'Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async =>'
  );
  // getAll with block bodies
  content = content.replace(
    /Future<List<BookmarkItem>> getAll\(\) async \{/g,
    'Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async {'
  );

  // getFavorites
  content = content.replace(
    /Future<List<BookmarkItem>> getFavorites\(\) async =>/g,
    'Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async =>'
  );
  content = content.replace(
    /Future<List<BookmarkItem>> getFavorites\(\) async \{/g,
    'Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async {'
  );

  // getArchived
  content = content.replace(
    /Future<List<BookmarkItem>> getArchived\(\) async =>/g,
    'Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async =>'
  );
  content = content.replace(
    /Future<List<BookmarkItem>> getArchived\(\) async \{/g,
    'Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async {'
  );

  // getByCollectionId - Id type
  content = content.replace(
    /Future<List<BookmarkItem>> getByCollectionId\(Id collectionId\) async =>/g,
    'Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async =>'
  );
  content = content.replace(
    /Future<List<BookmarkItem>> getByCollectionId\(Id collectionId\) async \{/g,
    'Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async {'
  );
  // getByCollectionId - int type (some tests use int)
  content = content.replace(
    /Future<List<BookmarkItem>> getByCollectionId\(int collectionId\) async =>/g,
    'Future<List<BookmarkItem>> getByCollectionId(int collectionId, {int? offset, int? limit}) async =>'
  );
  content = content.replace(
    /Future<List<BookmarkItem>> getByCollectionId\(int collectionId\) async \{/g,
    'Future<List<BookmarkItem>> getByCollectionId(int collectionId, {int? offset, int? limit}) async {'
  );

  // getByTagId - Id type
  content = content.replace(
    /Future<List<BookmarkItem>> getByTagId\(Id tagId\) async =>/g,
    'Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async =>'
  );
  content = content.replace(
    /Future<List<BookmarkItem>> getByTagId\(Id tagId\) async \{/g,
    'Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async {'
  );
  // getByTagId - int type
  content = content.replace(
    /Future<List<BookmarkItem>> getByTagId\(int tagId\) async =>/g,
    'Future<List<BookmarkItem>> getByTagId(int tagId, {int? offset, int? limit}) async =>'
  );
  content = content.replace(
    /Future<List<BookmarkItem>> getByTagId\(int tagId\) async \{/g,
    'Future<List<BookmarkItem>> getByTagId(int tagId, {int? offset, int? limit}) async {'
  );

  // search - SearchQuery
  content = content.replace(
    /Future<List<BookmarkItem>> search\(SearchQuery query\) async =>/g,
    'Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async =>'
  );
  content = content.replace(
    /Future<List<BookmarkItem>> search\(SearchQuery query\) async \{/g,
    'Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async {'
  );
  // search - dynamic query
  content = content.replace(
    /Future<List<BookmarkItem>> search\(dynamic query\) async =>/g,
    'Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async =>'
  );
  content = content.replace(
    /Future<List<BookmarkItem>> search\(dynamic query\) async \{/g,
    'Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async {'
  );

  fs.writeFileSync(file, content);
  console.log('Updated', file);
}
