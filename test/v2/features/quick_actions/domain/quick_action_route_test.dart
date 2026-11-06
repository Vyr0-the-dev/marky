import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/features/quick_actions/domain/quick_action_route.dart';

void main() {
  group('QuickActionRoute', () {
    test('normalizes supported routes', () {
      expect(QuickActionRoute.normalize(' /home '), Routes.home);
      expect(QuickActionRoute.normalize(' /add '), Routes.add);
      expect(QuickActionRoute.normalize('/search'), Routes.search);
      expect(QuickActionRoute.normalize('/home/unread'), Routes.homeUnread);
      expect(QuickActionRoute.normalize('/reminders'), Routes.reminders);
    });

    test('rejects unsupported values', () {
      expect(QuickActionRoute.normalize('/settings'), isNull);
      expect(QuickActionRoute.normalize(''), isNull);
      expect(QuickActionRoute.normalize(null), isNull);
      expect(QuickActionRoute.normalize(42), isNull);
    });
  });
}
