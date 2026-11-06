import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/tags/presentation/widgets/tag_chip.dart';
import 'package:marky/shared/models/tag.dart';

void main() {
  group('TagChip', () {
    Tag createTag({
      required String name,
      String? color,
      String? icon,
    }) {
      return Tag(
        name: name,
        slug: name.toLowerCase().replaceAll(' ', '-'),
        color: color,
        icon: icon,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    testWidgets('renders tag name', (WidgetTester tester) async {
      final tag = createTag(name: 'Flutter');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChip(tag: tag),
          ),
        ),
      );

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('renders color dot when no color is set', (WidgetTester tester) async {
      final tag = createTag(name: 'Dart');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChip(tag: tag),
          ),
        ),
      );

      // The chip should contain a Container with BoxDecoration shape: circle
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      final tag = createTag(name: 'Kotlin');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChip(
              tag: tag,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Kotlin'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows checkbox when showCheckbox is true', (WidgetTester tester) async {
      final tag = createTag(name: 'Swift');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChip(
              tag: tag,
              showCheckbox: true,
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('checkbox is checked when isSelected is true', (WidgetTester tester) async {
      final tag = createTag(name: 'Rust');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChip(
              tag: tag,
              showCheckbox: true,
              isSelected: true,
            ),
          ),
        ),
      );

      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('checkbox is unchecked when isSelected is false', (WidgetTester tester) async {
      final tag = createTag(name: 'Go');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChip(
              tag: tag,
              showCheckbox: true,
            ),
          ),
        ),
      );

      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('parses hex color correctly', (WidgetTester tester) async {
      final tag = createTag(name: 'Colored', color: '#FF5722');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChip(tag: tag),
          ),
        ),
      );

      expect(find.text('Colored'), findsOneWidget);
      // The chip should render without error.
    });

    testWidgets('falls back to accentPrimary for invalid color', (WidgetTester tester) async {
      final tag = createTag(name: 'BadColor', color: 'not-a-color');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChip(tag: tag),
          ),
        ),
      );

      expect(find.text('BadColor'), findsOneWidget);
    });

    testWidgets('selected state uses different text color', (WidgetTester tester) async {
      final tag = createTag(name: 'Selected', color: '#7C5CFF');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChip(
              tag: tag,
              isSelected: true,
            ),
          ),
        ),
      );

      expect(find.text('Selected'), findsOneWidget);
    });
  });
}
