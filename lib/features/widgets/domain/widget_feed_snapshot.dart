import 'package:flutter/foundation.dart';

@immutable
class WidgetFeedSnippet {
  const WidgetFeedSnippet({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

@immutable
class WidgetFeedSnapshot {
  const WidgetFeedSnapshot({
    required this.title,
    required this.subtitle,
    required this.snippets,
    required this.updatedAt,
  });

  final String title;
  final String subtitle;
  final List<WidgetFeedSnippet> snippets;
  final DateTime updatedAt;

  bool get isEmpty => snippets.isEmpty;
}
