import 'package:meta/meta.dart';

/// Action types supported by the automation engine.
///
/// Actions are collected, deduplicated, and executed in priority order.
enum RuleActionType {
  /// Adds a tag to the bookmark.
  addTag,

  /// Adds the bookmark to a collection.
  addToCollection,

  /// Marks the bookmark as archived.
  archive,

  /// Creates a reminder attached to the bookmark.
  addReminder,

  /// Moves the bookmark to the vault.
  moveToVault,

  /// Marks the bookmark as favorite.
  markAsFavorite,
}

/// Lightweight action configuration executed by [AutomationEngineService].
@immutable
class RuleAction {
  const RuleAction({
    required this.actionType,
    required this.config,
  });

  factory RuleAction.fromJson(Map<String, dynamic> json) {
    return RuleAction(
      actionType: RuleActionType.values.byName(json['actionType'] as String),
      config: (json['config'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
    );
  }

  final RuleActionType actionType;

  /// Type-specific configuration map.
  ///
  /// Keys per type:
  /// - `addTag` → `{'tagId': 42}` (or `{'tagSlug': 'flutter'}`)
  /// - `addToCollection` → `{'collectionId': 7}` (or `{'collectionSlug': 'work'}`)
  /// - `archive` → `{}`
  /// - `addReminder` → `{'title': 'Read later', 'scheduledAt': '...', 'body?': '...'}`
  /// - `moveToVault` → `{}`
  /// - `markAsFavorite` → `{}`
  final Map<String, dynamic> config;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'actionType': actionType.name,
        'config': config,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleAction &&
          runtimeType == other.runtimeType &&
          actionType == other.actionType &&
          _deepEqual(config, other.config);

  @override
  int get hashCode => Object.hash(actionType, _deepHash(config));

  /// Deep equality for config maps.
  static bool _deepEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key)) return false;
      final dynamic av = entry.value;
      final dynamic bv = b[entry.key];
      if (av is Map && bv is Map) {
        if (!_deepEqual(av.cast<String, dynamic>(), bv.cast<String, dynamic>())) {
          return false;
        }
      } else if (av is List && bv is List) {
        if (av.length != bv.length) return false;
        for (var i = 0; i < av.length; i++) {
          if (av[i] != bv[i]) return false;
        }
      } else if (av != bv) {
        return false;
      }
    }
    return true;
  }

  /// Deep hash for config maps.
  static int _deepHash(Map<String, dynamic> map) {
    var hash = 0;
    for (final entry in map.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
      hash = hash ^ entry.key.hashCode;
      final dynamic v = entry.value;
      if (v is Map) {
        hash = hash ^ _deepHash(v.cast<String, dynamic>());
      } else if (v is List) {
        hash = hash ^ Object.hashAll(v);
      } else {
        hash = hash ^ v.hashCode;
      }
    }
    return hash;
  }
}
