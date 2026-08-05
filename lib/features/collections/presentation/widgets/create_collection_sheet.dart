import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/collections/presentation/providers/collection_providers.dart';
import 'package:marky/shared/models/collection.dart';

/// Bottom sheet for creating a new collection or editing an existing one.
///
/// Shows a title text field, description text field, a preset color grid,
/// a preset icon grid, and a cover mode toggle between 'color' and 'gradient'.
/// When [existingCollection] is provided, fields are pre-filled for editing.
class CreateCollectionSheet extends ConsumerStatefulWidget {
  /// Creates a [CreateCollectionSheet] for creating a new collection.
  const CreateCollectionSheet({super.key}) : existingCollection = null;

  /// Creates a [CreateCollectionSheet] for editing an existing [collection].
  const CreateCollectionSheet.edit({required BookmarkCollection collection, super.key})
      : existingCollection = collection;

  /// The collection to edit, or `null` for creation mode.
  final BookmarkCollection? existingCollection;

  /// Shows the sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context, {BookmarkCollection? collection}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: AppShapes.bottomSheetShape,
      isScrollControlled: true,
      builder: (BuildContext ctx) => collection != null
          ? CreateCollectionSheet.edit(collection: collection)
          : const CreateCollectionSheet(),
    );
  }

  @override
  ConsumerState<CreateCollectionSheet> createState() => _CreateCollectionSheetState();
}

class _CreateCollectionSheetState extends ConsumerState<CreateCollectionSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _selectedColor;
  String? _selectedIcon;
  String _coverMode = 'color';
  bool _isSaving = false;

  static const List<String> _presetColors = <String>[
    '#7C5CFF', // accentPrimary
    '#35C2FF', // accentSecondary
    '#FF8A3D', // accentTertiary
    '#D6B25E', // accentLuxe
    '#35D07F', // success
    '#FF5D73', // danger
    '#FFB84D', // warning
    '#F5F7FA', // textPrimary
  ];

  static const List<IconData> _presetIcons = <IconData>[
    Icons.folder,
    Icons.folder_special,
    Icons.bookmark,
    Icons.favorite,
    Icons.star,
    Icons.work,
    Icons.school,
    Icons.code,
    Icons.article,
    Icons.collections_bookmark,
  ];

  bool get _isEditing => widget.existingCollection != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingCollection?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingCollection?.description ?? '',
    );
    _selectedColor = widget.existingCollection?.accentColor;
    _selectedIcon = widget.existingCollection?.icon;
    _coverMode = widget.existingCollection?.coverMode ?? 'color';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _titleController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── Drag handle ─────────────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Title ───────────────────────────────────────────────
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: Text(
                  _isEditing ? 'Edit Collection' : 'Create Collection',
                  style: AppTypography.sectionTitle,
                ),
              ),
              const SizedBox(height: 16),

              // ── Title field ─────────────────────────────────────────
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: TextField(
                  controller: _titleController,
                  style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Collection title',
                    hintStyle: AppTypography.body
                        .copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 12),

              // ── Description field ───────────────────────────────────
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: TextField(
                  controller: _descriptionController,
                  style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    hintStyle: AppTypography.body
                        .copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  maxLines: 3,
                  minLines: 2,
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(height: 20),

              // ── Color picker ────────────────────────────────────────
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: Text(
                  'Accent Color',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _presetColors.map(_buildColorOption).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // ── Icon picker ─────────────────────────────────────────
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: Text(
                  'Icon',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _presetIcons.map(_buildIconOption).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // ── Cover mode toggle ───────────────────────────────────
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: Text(
                  'Cover Style',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: _buildCoverModeToggle(),
              ),
              const SizedBox(height: 24),

              // ── Save button ─────────────────────────────────────────
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isValid && !_isSaving ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: AppColors.textPrimary,
                      disabledBackgroundColor: AppColors.surface3,
                      disabledForegroundColor: AppColors.textTertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppShapes.radiusStandard),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Save Changes' : 'Create Collection',
                            style: AppTypography.label,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(String hex) {
    final bool isSelected = _selectedColor == hex;
    final Color color = _parseColor(hex);

    return GestureDetector(
      onTap: () => setState(() => _selectedColor = hex),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppColors.textPrimary, width: 2.5)
              : null,
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                size: 18,
                color: AppColors.base,
              )
            : null,
      ),
    );
  }

  Widget _buildIconOption(IconData icon) {
    final bool isSelected = _selectedIcon == icon.codePoint.toString();

    return GestureDetector(
      onTap: () => setState(
        () => _selectedIcon = icon.codePoint.toString(),
      ),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimary : AppColors.surface2,
          borderRadius: BorderRadius.circular(AppShapes.radiusMini),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCoverModeToggle() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _CoverModeOption(
            label: 'Color',
            isSelected: _coverMode == 'color',
            onTap: () => setState(() => _coverMode = 'color'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CoverModeOption(
            label: 'Gradient',
            isSelected: _coverMode == 'gradient',
            onTap: () => setState(() => _coverMode = 'gradient'),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);

    final notifier = ref.read(collectionManagerNotifierProvider.notifier);
    final String? description = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : null;

    if (_isEditing) {
      final BookmarkCollection collection = widget.existingCollection!;
      collection.title = title;
      collection.description = description;
      collection.accentColor = _selectedColor;
      collection.icon = _selectedIcon;
      collection.coverMode = _coverMode;
      await notifier.update(collection);
    } else {
      await notifier.create(
        title,
        description: description,
        accentColor: _selectedColor,
        icon: _selectedIcon,
        coverMode: _coverMode,
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
    }
  }

  Color _parseColor(String hex) {
    final String sanitized = hex.replaceAll('#', '');
    if (sanitized.length == 6) {
      return Color(int.parse('FF$sanitized', radix: 16));
    }
    return Color(int.parse(sanitized, radix: 16));
  }
}

/// Compact selectable option for cover mode.
class _CoverModeOption extends StatelessWidget {
  const _CoverModeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimary : AppColors.surface2,
          borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
