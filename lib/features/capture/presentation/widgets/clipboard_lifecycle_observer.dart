import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/features/capture/domain/services/clipboard_monitor.dart';
import 'package:marky/features/capture/presentation/providers/clipboard_providers.dart';

/// Observes app lifecycle changes and checks the clipboard for URLs.
///
/// On [initState] (cold start) and every [AppLifecycleState.resumed]
/// event, this widget reads the [AppSettings.clipboardDetectionEnabled]
/// flag. If enabled, it asks [ClipboardMonitor] to check the clipboard.
/// When a valid URL is found that has not been seen this session, the
/// [clipboardUrlProvider] is updated so the UI can show a banner / sheet.
///
/// Usage: wrap the root [MaterialApp] or [MaterialApp.router]:
/// ```dart
/// ClipboardLifecycleObserver(
///   child: MaterialApp.router(...),
/// )
/// ```
class ClipboardLifecycleObserver extends ConsumerStatefulWidget {
  /// Creates the observer wrapping [child].
  const ClipboardLifecycleObserver({
    required this.child,
    super.key,
  });

  /// The widget tree to observe lifecycle changes for.
  final Widget child;

  @override
  ConsumerState<ClipboardLifecycleObserver> createState() =>
      _ClipboardLifecycleObserverState();
}

class _ClipboardLifecycleObserverState
    extends ConsumerState<ClipboardLifecycleObserver>
    with WidgetsBindingObserver {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _logger.d('ClipboardLifecycleObserver: initState — checking clipboard');
    _checkClipboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _logger.d('ClipboardLifecycleObserver: dispose');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _logger.d('ClipboardLifecycleObserver: app resumed — checking clipboard');
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    final bool enabled = ref.read(appSettingsProvider).clipboardDetectionEnabled;
    if (!enabled) {
      _logger.d('ClipboardLifecycleObserver: clipboard detection disabled');
      return;
    }

    final ClipboardMonitor monitor = ref.read(clipboardMonitorProvider);
    final ClipboardCheckResult? result = await monitor.checkClipboard();

    if (result != null) {
      ref
          .read(clipboardUrlProvider.notifier)
          .setDetectedUrl(result.url, result.hash);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
