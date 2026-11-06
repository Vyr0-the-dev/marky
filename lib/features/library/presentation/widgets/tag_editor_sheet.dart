import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/widgets/color_swatch_picker.dart';

/// Bottom sheet for creating or editing a tag.
///
/// Pass [initial] to edit an existing tag; leave it null for create
/// mode.  Edit mode keeps the tag's id + slug + createdAt unchanged
/// and only updates name/color/updatedAt.
class TagEditorSheet extends ConsumerStatefulWidget {
  const TagEditorSheet({this.initial, super.key});

  final Tag? initial;

  bool get isEdit => initial != null;

  @override
  ConsumerState<TagEditorSheet> createState() => _TagEditorSheetState();
}

class _TagEditorSheetState extends ConsumerState<TagEditorSheet> {
  late final TextEditingController _controller;
  bool _saving = false;
  int? _colorArgb;
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial?.name ?? '');
    _colorArgb = widget.initial?.colorArgb;
    _isPinned = widget.initial?.isPinned ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
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
                ? (AppLocalizations.of(context)?.editTag ?? 'Edit Tag')
                : (AppLocalizations.of(context)?.newTag ?? 'New Tag'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.tagNameHint ?? 'Tag name',
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          ColorSwatchPicker(
            title: 'Renk paleti',
            selected: _colorArgb,
            onChanged: (int? argb) => setState(() => _colorArgb = argb),
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
    final String name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      if (widget.isEdit) {
        final Tag old = widget.initial!;
        // Construct explicitly so a null _colorArgb actually clears
        // the color (Tag.copyWith uses `??` and can't reach null).
        final Tag updated = Tag(
          id: old.id,
          name: name,
          slug: old.slug,
          colorArgb: _colorArgb,
          icon: old.icon,
          description: old.description,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
          usageCount: old.usageCount,
          isPinned: _isPinned,
          orderIndex: old.orderIndex,
        );
        await ref.read(tagRepositoryProvider).save(updated);
      } else {
        final Tag created = await ref
            .read(tagRepositoryProvider)
            .createFromName(name, colorArgb: _colorArgb);
        // Apply pin if requested at creation time.
        if (_isPinned && created.id != null) {
          await ref
              .read(tagRepositoryProvider)
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
