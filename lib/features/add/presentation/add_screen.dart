import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/url/url_extractor.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/widgets/marky_top_toast.dart';

/// Add tab — paste or type a URL to capture it.
class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({super.key});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _capturing = false;
  CaptureResult? _lastResult;
  String? _clipboardSuggestion;

  @override
  void initState() {
    super.initState();
    _peekClipboardForUrl();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Peeks at the clipboard once on mount.  If it contains a URL,
  /// surface it as a one-tap suggestion above the text field.
  ///
  /// Reads silently — no prompts, no permission asks (the Flutter
  /// Clipboard API is permissionless on Android).
  Future<void> _peekClipboardForUrl() async {
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      final String? text = data?.text;
      if (text == null || text.isEmpty) return;
      final String? url = const UrlExtractor().extractFirst(text);
      if (url == null || !mounted) return;
      setState(() => _clipboardSuggestion = url);
    } catch (_) {
      // Clipboard access can fail on some platforms — silently ignore.
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.navigationAdd ?? 'Add')),
      body: ListView(
        padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
        children: <Widget>[
          Text(
            l10n?.addIntroTitle ?? 'Paste, share, or type a link',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n?.captureUrlLabel ?? 'URL',
              hintText: l10n?.captureUrlHint ?? 'Paste a link',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste),
                tooltip: l10n?.addPasteTooltip ?? 'Paste from clipboard',
                onPressed: _pasteClipboard,
              ),
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _capture(),
            onChanged: (_) {
              // Hide the suggestion once the user starts typing.
              if (_clipboardSuggestion != null) {
                setState(() => _clipboardSuggestion = null);
              }
            },
          ),
          if (_clipboardSuggestion != null &&
              _controller.text.isEmpty) ...<Widget>[
            const SizedBox(height: ReadingRoomSpacing.sm),
            _ClipboardSuggestionChip(
              url: _clipboardSuggestion!,
              label: l10n?.clipboardBannerTitle ?? 'Use clipboard link',
              onApply: () {
                _controller.text = _clipboardSuggestion!;
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
                setState(() => _clipboardSuggestion = null);
              },
              onDismiss: () => setState(() => _clipboardSuggestion = null),
            ),
          ],
          const SizedBox(height: ReadingRoomSpacing.md),
          FilledButton.icon(
            onPressed: _capturing ? null : _capture,
            icon: _capturing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_link_rounded),
            label: Text(l10n?.captureTitle ?? 'Capture'),
          ),
          const SizedBox(height: ReadingRoomSpacing.lg),
          AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> anim) {
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              );
            },
            child: _lastResult == null
                ? const SizedBox.shrink(key: ValueKey<String>('empty'))
                : _ResultCard(
                    key: ValueKey<int>(_lastResult.hashCode),
                    result: _lastResult!,
                    onViewDetail: _goToDetail,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pasteClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  Future<void> _capture() async {
    final String input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _capturing = true;
      _lastResult = null;
    });

    try {
      final CaptureResult result =
          await ref.read(captureServiceProvider).captureFromText(input);
      if (mounted) {
        setState(() {
          _capturing = false;
          _lastResult = result;
        });
        if (result.isSaved) {
          _controller.clear();
        }
        _showCaptureToast(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _capturing = false;
          _lastResult = CaptureResult.error(e.toString());
        });
      }
    }
  }

  void _goToDetail() {
    final int? id = _lastResult?.bookmark?.id;
    if (id != null) {
      context.push(Routes.bookmarkDetailPath(id));
    }
  }

  void _showCaptureToast(CaptureResult result) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final int? bookmarkId = result.bookmark?.id;
    final String? actionLabel =
        bookmarkId == null ? null : (l10n?.shareOpenBookmark ?? 'Open');
    final VoidCallback? onAction = bookmarkId == null ? null : _goToDetail;
    switch (result.status) {
      case CaptureStatus.saved:
        MarkyTopToast.show(
          context,
          icon: Icons.bookmark_added_rounded,
          message: l10n?.addSavedTitle ?? 'Saved!',
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;
      case CaptureStatus.duplicate:
        MarkyTopToast.show(
          context,
          icon: Icons.bookmark_added_outlined,
          message: l10n?.addDuplicateTitle ?? 'Already saved',
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;
      case CaptureStatus.invalidUrl:
        MarkyTopToast.show(
          context,
          icon: Icons.link_off_rounded,
          message: l10n?.addInvalidTitle ?? 'Invalid URL',
          iconColor: Theme.of(context).colorScheme.error,
        );
        break;
      case CaptureStatus.error:
        MarkyTopToast.show(
          context,
          icon: Icons.error_outline_rounded,
          message: l10n?.addErrorTitle ?? 'Error',
          iconColor: Theme.of(context).colorScheme.error,
        );
        break;
    }
  }
}

// ─── Result card ────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.onViewDetail,
    super.key,
  });

  final CaptureResult result;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    final (IconData icon, Color color, String title, String subtitle) =
        switch (result.status) {
      CaptureStatus.saved => (
          Icons.check_circle,
          Colors.green,
          l10n?.addSavedTitle ?? 'Saved!',
          result.bookmark?.displayTitle ??
              l10n?.addSavedSubtitle ??
              'New bookmark captured.',
        ),
      CaptureStatus.duplicate => (
          Icons.copy_all,
          Colors.orange,
          l10n?.addDuplicateTitle ?? 'Already saved',
          result.bookmark?.displayTitle ??
              l10n?.addDuplicateSubtitle ??
              'This URL is in your library.',
        ),
      CaptureStatus.invalidUrl => (
          Icons.error_outline,
          theme.colorScheme.error,
          l10n?.addInvalidTitle ?? 'Invalid URL',
          l10n?.addInvalidSubtitle ??
              'Could not find a valid link in the input.',
        ),
      CaptureStatus.error => (
          Icons.warning_amber_rounded,
          theme.colorScheme.error,
          l10n?.addErrorTitle ?? 'Error',
          result.errorMessage ??
              l10n?.addErrorSubtitle ??
              'Something went wrong.',
        ),
    };

    return Card(
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: result.bookmark != null
            ? IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                onPressed: onViewDetail,
                tooltip: l10n?.addViewDetailTooltip ?? 'View detail',
              )
            : null,
      ),
    );
  }
}

// ─── Clipboard suggestion chip ──────────────────────────────────

class _ClipboardSuggestionChip extends StatelessWidget {
  const _ClipboardSuggestionChip({
    required this.url,
    required this.label,
    required this.onApply,
    required this.onDismiss,
  });

  final String url;
  final String label;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: '$label, $url',
      child: ExcludeSemantics(
        child: Material(
          color: scheme.primary.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
            side: BorderSide(
              color: scheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: InkWell(
            onTap: onApply,
            borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ReadingRoomSpacing.md,
                vertical: ReadingRoomSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.content_paste_go,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: ReadingRoomSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    tooltip: AppLocalizations.of(context)?.actionDismiss ??
                        'Dismiss',
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
