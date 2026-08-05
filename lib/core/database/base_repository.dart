import 'package:isar/isar.dart';

/// Generic CRUD contract for Isar-backed repositories.
///
/// Each feature repository should extend this interface and narrow the
/// type parameter to its entity class.
abstract class BaseRepository<T> {
  /// Returns the entity with [id], or `null` if not found.
  Future<T?> getById(Id id);

  /// Returns all entities of type [T].
  Future<List<T>> getAll();

  /// Inserts [entity] and returns its assigned [Id].
  Future<Id> insert(T entity);

  /// Updates [entity] in place and returns its [Id].
  Future<Id> update(T entity);

  /// Deletes the entity with [id].
  ///
  /// No-op if the entity does not exist.
  Future<void> delete(Id id);

  /// Deletes all entities of type [T].
  Future<void> clear();
}
