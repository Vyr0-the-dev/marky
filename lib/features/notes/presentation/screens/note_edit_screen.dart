import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/notes/domain/use_cases/manage_notes_use_case.dart';
import 'package:marky/features/notes/presentation/providers/note_providers.dart';
import 'package:marky/shared/models/note.dart';

/// Full-screen note editor for creating or editing a note on a bookmark.
///
/// [bookmarkId] is always required — it is the parent bookmark this note
/// belongs to. [noteId] is optional; when provided the screen loads the
/// existing note and operates in edit mode.
///
/// Pops with `true` if a change (create, update, or delete) was made so
/// the caller can refresh its state.
class NoteEditScreen extends ConsumerStatefulWidget {
  /// Creates a [NoteEditScreen].
  const NoteEditScreen({
    super.key,
    required this.bookmarkId,
    this.noteId,
  });

  /// The parent bookmark ID this note is attached to.
  final int bookmarkId;

  /// Optional note ID for edit mode. When `null`, a new note is created.
  final int? noteId;

  @override
  ConsumerState<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends ConsumerState<NoteEditScreen> {
  late final TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    if (widget.noteId != null) {
      _loadNote();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);
    final Note? note = await ref.read(noteByIdProvider(widget.noteId!).future);
    if (note != null && mounted) {
      _contentController.text = note.content;
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    final String content = _contentController.text.trim();
    if (content.isEmpty) {
      _showSnackBar('Note cannot be empty');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ManageNotesUseCase useCase = ref.read(manageNotesUseCaseProvider);

      if (widget.noteId != null) {
        // Update existing note.
        final Note? existing =
            await ref.read(noteByIdProvider(widget.noteId!).future);
        if (existing != null) {
          existing.content = content;
          await useCase.update(existing);
        }
      } else {
        // Create new note.
        await useCase.create(
          bookmarkId: widget.bookmarkId,
          content: content,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Failed to save note: $e');
      }
    }
  }

  Future<void> _delete() async {
    if (widget.noteId == null) {
      Navigator.of(context).pop(false);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: const Text(
          'Delete note?',
          style: AppTypography.sectionTitle,
        ),
        content: const Text(
          'This action cannot be undone.',
          style: AppTypography.body,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.label
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: AppTypography.label.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() => _isLoading = true);
      try {
        final ManageNotesUseCase useCase = ref.read(manageNotesUseCaseProvider);
        await useCase.delete(widget.noteId!);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } on Object catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar('Failed to delete note: $e');
        }
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.body),
        backgroundColor: AppColors.surface2,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.noteId != null;

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.surface1,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          isEditing ? 'Edit Note' : 'New Note',
          style: AppTypography.sectionTitle,
        ),
        actions: <Widget>[
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: _isLoading ? null : _delete,
            ),
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.accentPrimary),
            onPressed: _isLoading ? null : _save,
          ),
        ],
      ),
      body: _isLoading && _contentController.text.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentPrimary,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _contentController,
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Write your note…',
                  hintStyle: AppTypography.body
                      .copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: AppColors.surface2,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: null,
                minLines: 8,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                autofocus: !isEditing,
                enabled: !_isLoading,
              ),
            ),
    );
  }
}
