import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/features/reminders/domain/services/reminder_scheduler_service.dart';
import 'package:marky/features/reminders/presentation/providers/reminder_providers.dart';
import 'package:marky/features/reminders/presentation/widgets/reminder_bottom_sheet.dart';
import 'package:marky/shared/models/reminder.dart';

import '../../../fakes/fake_notification_service.dart';

// ─── Inline fakes for widget tests ──────────────────────────────────────

class _FakeReminderRepository implements ReminderRepository {
  final List<Reminder> _reminders = <Reminder>[];
  int _idCounter = 1;

  @override
  Future<Reminder?> getById(Id id) async {
    try {
      return _reminders.firstWhere((r) => r.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<List<Reminder>> getAll() async => List.unmodifiable(_reminders);

  @override
  Future<Id> insert(Reminder entity) async {
    entity.id = _idCounter++;
    _reminders.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(Reminder entity) async {
    final int index = _reminders.indexWhere((r) => r.id == entity.id);
    if (index >= 0) _reminders[index] = entity;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _reminders.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> clear() async => _reminders.clear();

  @override
  Future<List<Reminder>> getByBookmarkId(Id bookmarkId) async =>
      _reminders.where((r) => r.bookmarkId == bookmarkId).toList();

  @override
  Future<List<Reminder>> getPending() async =>
      _reminders.where((r) => r.status == 'pending').toList();
}

class _FakeReminderManagerNotifier extends ReminderManagerNotifier {
  _FakeReminderManagerNotifier()
      : super(
          service: ReminderSchedulerService(
            reminderRepository: _FakeReminderRepository(),
            notificationService: FakeNotificationService(),
          ),
          repository: _FakeReminderRepository(),
        );

  int createCallCount = 0;
  Map<String, dynamic>? lastCreateArgs;

  @override
  Future<Reminder> create({
    required int bookmarkId,
    required String title,
    String? body,
    required DateTime scheduledAt,
    String repeatMode = 'none',
    String? timezone,
  }) async {
    createCallCount++;
    lastCreateArgs = <String, dynamic>{
      'bookmarkId': bookmarkId,
      'title': title,
      'body': body,
      'scheduledAt': scheduledAt,
      'repeatMode': repeatMode,
      'timezone': timezone,
    };
    return Reminder(
      bookmarkId: bookmarkId,
      title: title,
      scheduledAt: scheduledAt,
      timezone: timezone ?? 'UTC',
      createdAt: DateTime.now(),
    )..id = 1;
  }
}

// ─── Test harness ───────────────────────────────────────────────────────

Widget _buildTestApp({_FakeReminderManagerNotifier? notifier}) {
  return ProviderScope(
    overrides: <Override>[
      notificationServiceProvider.overrideWith(
        (ref) => FakeNotificationService()..canScheduleExact = true,
      ),
      reminderManagerNotifierProvider.overrideWith(
        (ref) => notifier ?? _FakeReminderManagerNotifier(),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => ElevatedButton(
            onPressed: () => ReminderBottomSheet.show(
              context,
              bookmarkId: 42,
              bookmarkTitle: 'Test Bookmark',
            ),
            child: const Text('Show Sheet'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ReminderBottomSheet', () {
    Future<void> openSheet(WidgetTester tester) async {
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders all preset chips', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await openSheet(tester);

      expect(find.text('1 hour'), findsOneWidget);
      expect(find.text('This evening'), findsOneWidget);
      expect(find.text('Tomorrow 9am'), findsOneWidget);
      expect(find.text('1 week'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('tapping 1 hour chip enables save button',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await openSheet(tester);

      // Initially disabled.
      var button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Reminder'),
      );
      expect(button.onPressed, isNull);

      await tester.tap(find.text('1 hour'));
      await tester.pumpAndSettle();

      // Now enabled.
      button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Reminder'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping Custom chip and selecting date/time sets date',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await openSheet(tester);

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      // Date picker dialog should be open.
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Tap OK to accept the default date (tomorrow).
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Time picker dialog should be open.
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Tap OK to accept default time.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Back to bottom sheet, selected date text should appear.
      expect(
        find.textContaining(' at ', findRichText: true),
        findsOneWidget,
      );

      // Save should be enabled.
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Reminder'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping save calls create on notifier',
        (WidgetTester tester) async {
      final notifier = _FakeReminderManagerNotifier();

      await tester.pumpWidget(_buildTestApp(notifier: notifier));
      await openSheet(tester);

      // Select a preset.
      await tester.tap(find.text('1 hour'));
      await tester.pumpAndSettle();

      // Tap save.
      await tester.tap(find.text('Save Reminder'));
      await tester.pumpAndSettle();

      expect(notifier.createCallCount, 1);
      expect(notifier.lastCreateArgs?['bookmarkId'], 42);
      expect(notifier.lastCreateArgs?['title'], 'Test Bookmark');
      expect(notifier.lastCreateArgs?['repeatMode'], 'none');
      expect(notifier.lastCreateArgs?['scheduledAt'], isA<DateTime>());
    });

    testWidgets('save button is disabled when no date is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await openSheet(tester);

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Reminder'),
      );
      expect(button.onPressed, isNull);
    });
  });
}
