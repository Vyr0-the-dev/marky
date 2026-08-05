import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart';
import 'package:marky/features/capture/presentation/providers/capture_providers.dart';

/// Premium manual-add capture screen.
///
/// Allows the user to paste or type a URL and save it as a bookmark.
/// Provides real-time feedback via SnackBars for success, duplicate, and
/// error states.
///
/// When [initialUrl] is provided, the URL is pre-filled and auto-saved
/// after the first frame to ensure routing is ready.
class CaptureScreen extends ConsumerStatefulWidget {
  /// Creates the [CaptureScreen].
  const CaptureScreen({super.key, this.initialUrl});

  /// Optional URL to pre-fill and auto-save.
  final String? initialUrl;

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _didAutoSave = false;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);

    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      // Temporarily remove the listener so that setting the controller
      // text does not synchronously modify a provider during build.
      _urlController.removeListener(_onUrlChanged);
      _urlController.text = widget.initialUrl!;
      _urlController.selection = TextSelection.collapsed(
        offset: _urlController.text.length,
      );
      _urlController.addListener(_onUrlChanged);

      // Defer provider mutation and auto-save until after the frame
      // to avoid "Tried to modify a provider while the widget tree was
      // building" errors.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_didAutoSave) {
          _didAutoSave = true;
          ref.read(captureFormProvider.notifier).setUrl(widget.initialUrl!);
          ref.read(captureFormProvider.notifier).save();
        }
      });
    }
  }

  void _onUrlChanged() {
    ref.read(captureFormProvider.notifier).setUrl(_urlController.text);
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      _urlController.text = data.text!;
      _urlController.selection = TextSelection.collapsed(
        offset: _urlController.text.length,
      );
    }
  }

  void _clearField() {
    _urlController.clear();
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.body.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CaptureFormState>(captureFormProvider, (
      CaptureFormState? previous,
      CaptureFormState next,
    ) {
      final AsyncValue<SaveResult?> submission = next.submission;
      final SaveResult? previousResult =
          previous?.submission is AsyncData<SaveResult?>
              ? (previous!.submission as AsyncData<SaveResult?>).value
              : null;

      if (submission is AsyncData<SaveResult?>) {
        final SaveResult? result = submission.value;
        if (result is SaveSuccess && previousResult is! SaveSuccess) {
          _showSnackBar('Link saved', AppColors.success);
          _urlController.clear();
        } else if (result is SaveDuplicate && previousResult is! SaveDuplicate) {
          _showSnackBar('Link already saved', AppColors.warning);
        } else if (result is SaveInvalid && previousResult is! SaveInvalid) {
          _showSnackBar('Could not save link', AppColors.danger);
        }
      } else if (submission is AsyncError<SaveResult?>) {
        _showSnackBar('Could not save link', AppColors.danger);
      }
    });

    final CaptureFormState state = ref.watch(captureFormProvider);
    final bool canSave =
        state.url.trim().isNotEmpty && !state.submission.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Link'),
        backgroundColor: AppColors.base,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppShapes.screenPaddingInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Paste or type a URL...',
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: _urlController.text.isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearField,
                              tooltip: 'Clear',
                            ),
                            IconButton(
                              icon: const Icon(Icons.content_paste),
                              onPressed: _pasteFromClipboard,
                              tooltip: 'Paste',
                            ),
                          ],
                        )
                      : IconButton(
                          icon: const Icon(Icons.content_paste),
                          onPressed: _pasteFromClipboard,
                          tooltip: 'Paste',
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canSave
                      ? () => ref.read(captureFormProvider.notifier).save()
                      : null,
                  child: const Text('Save Link'),
                ),
              ),
              if (state.submission.isLoading) ...<Widget>[
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
