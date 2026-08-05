import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/ai/domain/models/embedding_vector.dart';

void main() {
  group('EmbeddingVector', () {
    test('valid construction with matching dimensions', () {
      const values = [0.1, 0.2, 0.3];
      const dimensions = 3;
      final vector = EmbeddingVector(
        values: values,
        dimensions: dimensions,
      );

      expect(vector.values, equals(values));
      expect(vector.dimensions, equals(dimensions));
    });

    test('throws AssertionError when dimensions mismatch', () {
      expect(
        () => EmbeddingVector(
          values: [0.1, 0.2],
          dimensions: 3,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when values is empty', () {
      expect(
        () => EmbeddingVector(
          values: [],
          dimensions: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('equality considers values and dimensions', () {
      final a = EmbeddingVector(
        values: [0.1, 0.2, 0.3],
        dimensions: 3,
      );
      final b = EmbeddingVector(
        values: [0.1, 0.2, 0.3],
        dimensions: 3,
      );
      final c = EmbeddingVector(
        values: [0.1, 0.2, 0.4],
        dimensions: 3,
      );
      final d = EmbeddingVector(
        values: [0.1, 0.2, 0.3, 0.5],
        dimensions: 4,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
    });

    test('toString contains dimensions and truncated values', () {
      final vector = EmbeddingVector(
        values: [0.1, 0.2, 0.3, 0.4],
        dimensions: 4,
      );
      final str = vector.toString();

      expect(str, contains('dimensions: 4'));
      expect(str, contains('...'));
    });

    test('toString shows all values when 3 or fewer', () {
      final vector = EmbeddingVector(
        values: [0.1, 0.2],
        dimensions: 2,
      );
      final str = vector.toString();

      expect(str, contains('0.1'));
      expect(str, contains('0.2'));
      expect(str, isNot(contains('...')));
    });
  });
}
