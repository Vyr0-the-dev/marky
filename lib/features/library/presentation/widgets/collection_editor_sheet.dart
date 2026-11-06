import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/widgets/color_swatch_picker.dart';

/// Bottom sheet for creating or editing a collection.
///
/// Pass [initial] to edit an existing collection; leave it null for
/// create mode.  Edit mode keeps id + slug + createdAt + itemCount
/// unchanged and only updates title/description/accentColor/updatedAt.
class CollectionEditorSheet extends ConsumerStatefulWidget {
  const CollectionEditorSheet({this.initial, super.key});

  final BookmarkCollection? initial;

  bool get isEdit => initial != null;

  @override
  ConsumerState<CollectionEditorSheet> createState() =>
      _CollectionEditorSheetState();
}

class _CollectionEditorSheetState extends ConsumerState<CollectionEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  bool _saving = false;
  int? _accentColorArgb;
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _descController =
        TextEditingController(text: widget.initial?.description ?? '');
    _accentColorArgb = widget.initial?.accentColorArgb;
    _isPinned = widget.initial?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: ReadingRoomSpacing.lg,
        right: ReadingRoomSpacing.lg,
        top: ReadingRoomSpacing.lg,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + ReadingRoomSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            widget.isEdit
                ? (AppLocalizations.of(context)?.editCollection ??
                    'Edit Collection')
                : (AppLocalizations.of(context)?.newCollection ??
                    'New Collection'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          TextField(
            controller: _titleController,
            autofocus: !widget.isEdit,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.collectionNameHint ??
                  'Collection name',
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: ReadingRoomSpacing.sm),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(context)?.collectionDescriptionHint ??
                      'Description (optional)',
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          ColorSwatchPicker(
            title: 'Renk paleti',
            selected: _accentColorArgb,
            onChanged: (int? argb) => setState(() => _accentColorArgb = argb),
          ),
          const SizedBox(height: ReadingRoomSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              size: 18,
            ),
            title: Text(AppLocalizations.of(context)?.pinToTop ?? 'Pin to top'),
            value: _isPinned,
            onChanged: (bool v) => setState(() => _isPinned = v),
          ),
          const SizedBox(height: ReadingRoomSpacing.sm),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.isEdit
                    ? (AppLocalizations.of(context)?.actionSave ?? 'Save')
                    : (AppLocalizations.of(context)?.actionCreate ?? 'Create')),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);
    try {
      if (widget.isEdit) {
        final BookmarkCollection old = widget.initial!;
        final String? desc = _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim();
        // Construct explicitly so a null _accentColorArgb actually
        // clears the color (copyWith uses `??` and can't reach null).
        final BookmarkCollection updated = BookmarkCollection(
          id: old.id,
          title: title,
          slug: old.slug,
          description: desc,
          icon: old.icon,
          accentColorArgb: _accentColorArgb,
          isPinned: _isPinned,
          isArchived: old.isArchived,
          itemCount: old.itemCount,
          sortMode: old.sortMode,
          orderIndex: old.orderIndex,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
        );
        await ref.read(bookmarkCollectionRepositoryProvider).save(updated);
      } else {
        final BookmarkCollection created = await ref
            .read(bookmarkCollectionRepositoryProvider)
            .createFromTitle(title, accentColorArgb: _accentColorArgb);
        // Apply pin if requested at creation time.
        if (_isPinned && created.id != null) {
          await ref
              .read(bookmarkCollectionRepositoryProvider)
              .save(created.copyWith(isPinned: true));
        }
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Failed: $e')));
        setState(() => _saving = false);
      }
    }
  }
}
