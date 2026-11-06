import 'dart:async';

import 'package:flutter/foundation.dart';

@immutable
class AutomationDebugLogEntry {
  const AutomationDebugLogEntry({
    required this.timestamp,
    required this.bookmarkId,
    required this.ruleId,
    required this.ruleName,
    required this.message,
  });

  final DateTime timestamp;
  final int? bookmarkId;
  final int? ruleId;
  final String ruleName;
  final String message;
}

class AutomationDebugLogController {
  AutomationDebugLogController({this.maxEntries = 100});

  final int maxEntries;
  final List<AutomationDebugLogEntry> _entries = <AutomationDebugLogEntry>[];
  final StreamController<List<AutomationDebugLogEntry>> _controller =
      StreamController<List<AutomationDebugLogEntry>>.broadcast();

  List<AutomationDebugLogEntry> get entries =>
      List<AutomationDebugLogEntry>.unmodifiable(_entries);

  Stream<List<AutomationDebugLogEntry>> watch() async* {
    yield entries;
    yield* _controller.stream;
  }

  void add(AutomationDebugLogEntry entry) {
    _entries.insert(0, entry);
    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }
    _controller.add(entries);
  }

  void clear() {
    _entries.clear();
    _controller.add(entries);
  }

  void dispose() {
    _controller.close();
  }
}
