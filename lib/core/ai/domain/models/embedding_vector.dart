import 'package:meta/meta.dart';

/// Immutable value object representing a dense embedding vector.
///
/// Enforces non-empty values and dimension consistency at construction time.
/// Equality and hashCode are based on both the values and declared dimensions.
@immutable
class EmbeddingVector {
  EmbeddingVector({
    required this.values,
    required this.dimensions,
  })  : assert(values.length == dimensions, 'values length must match dimensions'),
        assert(values.isNotEmpty, 'values must not be empty');

  /// The dense vector values.
  final List<double> values;

  /// The declared dimensionality of the vector.
  final int dimensions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingVector &&
          other.runtimeType == runtimeType &&
          other.dimensions == dimensions &&
          _listEquals(other.values, values);

  @override
  int get hashCode => Object.hash(
        dimensions,
        Object.hashAll(values),
      );

  @override
  String toString() =>
      'EmbeddingVector(dimensions: $dimensions, values: [${values.take(3).join(', ')}${values.length > 3 ? ', ...' : ''}])';
}

/// Local helper for deep list equality on doubles.
bool _listEquals(List<double> a, List<double> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
