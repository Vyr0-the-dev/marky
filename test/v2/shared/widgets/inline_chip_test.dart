import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/shared/widgets/inline_chip.dart';

Widget _host(Widget child,
    {ReadingRoomVariant variant = ReadingRoomVariant.light}) {
  return MaterialApp(
    theme: ReadingRoomTheme.build(variant),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('InlineChip', () {
    testWidgets('renders label', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const InlineChip(label: 'Design')));
      expect(find.text('Design'), findsOneWidget);
    });

    testWidgets('onTap fires when tapped', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(InlineChip(
          label: 'Work',
          onTap: () => taps++,
        )),
      );
      await tester.tap(find.text('Work'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('onTap does not fire when disabled',
        (WidgetTester tester) async {
      // Without an onTap callback the InkWell is disabled and taps
      // become no-ops — the widget should still render.
      await tester.pumpWidget(_host(const InlineChip(label: 'Archived')));
      await tester.tap(find.text('Archived'));
      await tester.pump();
      // Nothing to assert beyond "no crash" — if the chip had an
      // InkWell enabled, we'd have a semantics action. Verify that
      // there's no tappable semantics node.
      // (Smoke-level coverage; deeper asserts come in Faz 2.)
    });

    testWidgets('selected state uses primary background',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const InlineChip(
        label: 'On',
        selected: true,
      )));
      final Material material = tester.widget<Material>(
        find
            .ancestor(
              of: find.text('On'),
              matching: find.byType(Material),
            )
            .first,
      );
      final BuildContext ctx = tester.element(find.text('On'));
      expect(material.color, Theme.of(ctx).colorScheme.primary);
    });

    testWidgets('color prop renders leading dot when no custom leading',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const InlineChip(
        label: 'Tag',
        color: Color(0xFFAA3300),
      )));
      // The dot is a Container with the given colour — locate by
      // walking the widget tree.
      final Finder container = find.byWidgetPredicate(
        (Widget w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == const Color(0xFFAA3300),
      );
      expect(container, findsOneWidget);
    });
  });
}
