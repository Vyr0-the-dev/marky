import 'package:flutter/foundation.dart';

String? debugOnlyErrorDetails(
  Object? error, {
  StackTrace? stackTrace,
  bool releaseMode = kReleaseMode,
}) {
  if (releaseMode) return null;
  if (error == null && stackTrace == null) return null;
  return <String>[
    if (error != null) error.toString(),
    if (stackTrace != null) stackTrace.toString(),
  ].join('\n');
}
