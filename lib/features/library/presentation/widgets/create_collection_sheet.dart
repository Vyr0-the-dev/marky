import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/widgets/color_swatch_picker.dart';

/// Bottom sheet for creating a new collection.
class CreateCollectionSheet extends ConsumerStatefulWidget {
  const CreateCollectionSheet({super.key});

  @override
  ConsumerState<CreateCollectionSheet> createState() =>
      _CreateCollectionSheetState();
}

class _CreateCollectionSheetState extends ConsumerState<CreateCollectionSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _saving = false;
  int? _accentColorArgb;

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
            AppLocalizations.of(context)?.newCollection ?? 'New Collection',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          TextField(
            controller: _titleController,
            autofocus: true,
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
          const SizedBox(height: ReadingRoomSpacing.md),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(AppLocalizations.of(context)?.actionCreate ?? 'Create'),
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
      await ref.read(bookmarkCollectionRepositoryProvider).createFromTitle(
            title,
            accentColorArgb: _accentColorArgb,
          );
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
