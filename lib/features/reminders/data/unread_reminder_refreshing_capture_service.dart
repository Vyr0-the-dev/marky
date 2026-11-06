import 'dart:async';

import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/capture/domain/capture_service.dart';
import 'package:marky/features/reminders/domain/unread_reminder_scheduler.dart';

class UnreadReminderRefreshingCaptureService implements CaptureService {
  const UnreadReminderRefreshingCaptureService({
    required CaptureService delegate,
    required AppSettings Function() settings,
    required UnreadReminderScheduler Function() scheduler,
  })  : _delegate = delegate,
        _settings = settings,
        _scheduler = scheduler;

  final CaptureService _delegate;
  final AppSettings Function() _settings;
  final UnreadReminderScheduler Function() _scheduler;

  @override
  Future<CaptureResult> capture(
    String rawInput, {
    BookmarkSourceType sourceType = BookmarkSourceType.manual,
  }) async {
    final CaptureResult result = await _delegate.capture(
      rawInput,
      sourceType: sourceType,
    );
    _refreshIfNeeded(<CaptureResult>[result]);
    return result;
  }

  @override
  Future<List<CaptureResult>> captureAllFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  }) async {
    final List<CaptureResult> results = await _delegate.captureAllFromText(
      text,
      sourceType: sourceType,
    );
    _refreshIfNeeded(results);
    return results;
  }

  @override
  Future<CaptureResult> captureFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  }) async {
    final CaptureResult result = await _delegate.captureFromText(
      text,
      sourceType: sourceType,
    );
    _refreshIfNeeded(<CaptureResult>[result]);
    return result;
  }

  void _refreshIfNeeded(List<CaptureResult> results) {
    if (!results.any((CaptureResult r) => r.status == CaptureStatus.saved)) {
      return;
    }
    final AppSettings settings;
    try {
      settings = _settings();
    } on Object {
      return;
    }
    final UnreadReminderCadence cadence = settings.unreadReminderCadence;
    if (cadence == UnreadReminderCadence.off) return;
    unawaited(
      _refresh(
        cadence,
        weekday: settings.unreadReminderWeekday,
        hour: settings.unreadReminderHour,
        minute: settings.unreadReminderMinute,
      ),
    );
  }

  Future<void> _refresh(
    UnreadReminderCadence cadence, {
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    try {
      await _scheduler().schedule(
        cadence,
        weekday: weekday,
        hour: hour,
        minute: minute,
      );
    } on Object {
      return;
    }
  }
}
