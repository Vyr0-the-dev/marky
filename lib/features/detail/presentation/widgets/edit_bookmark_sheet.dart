import 'package:flutter/material.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Editorial modal bottom sheet for editing a bookmark's title and description.
class EditBookmarkSheet extends StatefulWidget {
  const EditBookmarkSheet({
    required this.initialTitle,
    required this.initialDescription,
    super.key,
  });

  final String initialTitle;
  final String initialDescription;

  static Future<({String title, String description})?> show(
    BuildContext context, {
    required String initialTitle,
    required String initialDescription,
  }) {
    return showModalBottomSheet<({String title, String description})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (BuildContext ctx) => EditBookmarkSheet(
        initialTitle: initialTitle,
        initialDescription: initialDescription,
      ),
    );
  }

  @override
  State<EditBookmarkSheet> createState() => _EditBookmarkSheetState();
}

class _EditBookmarkSheetState extends State<EditBookmarkSheet> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.initialTitle,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(
    text: widget.initialDescription,
  );

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    Navigator.of(context).pop((
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final Color outlineColor = theme.colorScheme.outline;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ReadingRoomRadii.sheet),
          ),
          border: Border(
            top: BorderSide(color: outlineColor),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ReadingRoomSpacing.lg,
              vertical: ReadingRoomSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ── Handle bar ────────────────────────────────
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Header ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      l10n?.actionEdit ?? 'Edit Bookmark',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: ReadingRoomSpacing.lg),

                // ── Title Input ───────────────────────────────
                Text(
                  l10n?.captureTitleLabel ?? 'Title',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: ReadingRoomSpacing.xs),
                TextField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Enter title...',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(ReadingRoomRadii.standard),
                      borderSide: BorderSide(color: outlineColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(ReadingRoomRadii.standard),
                      borderSide: BorderSide(color: outlineColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(ReadingRoomRadii.standard),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: ReadingRoomSpacing.md,
                      vertical: ReadingRoomSpacing.sm,
                    ),
                  ),
                ),
                const SizedBox(height: ReadingRoomSpacing.md),

                // ── Description Input ─────────────────────────
                Text(
                  l10n?.detailDescriptionLabel ?? 'Description',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: ReadingRoomSpacing.xs),
                TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 6,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Add an optional description...',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(ReadingRoomRadii.standard),
                      borderSide: BorderSide(color: outlineColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(ReadingRoomRadii.standard),
                      borderSide: BorderSide(color: outlineColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(ReadingRoomRadii.standard),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: ReadingRoomSpacing.md,
                      vertical: ReadingRoomSpacing.sm,
                    ),
                  ),
                ),
                const SizedBox(height: ReadingRoomSpacing.xl),

                // ── Save Button ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _onSave,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(
                      l10n?.actionSave ?? 'Save Changes',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: ReadingRoomSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
