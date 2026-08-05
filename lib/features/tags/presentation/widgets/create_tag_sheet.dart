import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/tags/presentation/providers/tag_providers.dart';
import 'package:marky/shared/models/tag.dart';

/// Bottom sheet for creating a new tag or editing an existing one.
///
/// Shows a name text field, a preset color grid, and a preset icon grid.
/// When [existingTag] is provided, fields are pre-filled for editing.
class CreateTagSheet extends ConsumerStatefulWidget {
  /// Creates a [CreateTagSheet] for creating a new tag.
  const CreateTagSheet({super.key}) : existingTag = null;

  /// Creates a [CreateTagSheet] for editing an existing [tag].
  const CreateTagSheet.edit({required Tag tag, super.key})
      : existingTag = tag;

  /// The tag to edit, or `null` for creation mode.
  final Tag? existingTag;

  /// Shows the sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context, {Tag? tag}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: AppShapes.bottomSheetShape,
      isScrollControlled: true,
      builder: (BuildContext ctx) => tag != null
          ? CreateTagSheet.edit(tag: tag)
          : const CreateTagSheet(),
    );
  }

  @override
  ConsumerState<CreateTagSheet> createState() => _CreateTagSheetState();
}

class _CreateTagSheetState extends ConsumerState<CreateTagSheet> {
  late final TextEditingController _nameController;
  String? _selectedColor;
  String? _selectedIcon;
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
    Icons.label,
    Icons.bookmark,
    Icons.favorite,
    Icons.star,
    Icons.work,
    Icons.school,
    Icons.code,
    Icons.article,
  ];

  bool get _isEditing => widget.existingTag != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingTag?.name ?? '',
    );
    _selectedColor = widget.existingTag?.color;
    _selectedIcon = widget.existingTag?.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _nameController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
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
                _isEditing ? 'Edit Tag' : 'Create Tag',
                style: AppTypography.sectionTitle,
              ),
            ),
            const SizedBox(height: 16),

            // ── Name field ──────────────────────────────────────────
            Padding(
              padding: AppShapes.horizontalScreenPadding,
              child: TextField(
                controller: _nameController,
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tag name',
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
                textInputAction: TextInputAction.done,
                onSubmitted: isValid && !_isSaving ? (_) => _save() : null,
              ),
            ),
            const SizedBox(height: 20),

            // ── Color picker ────────────────────────────────────────
            Padding(
              padding: AppShapes.horizontalScreenPadding,
              child: Text(
                'Color',
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
                          _isEditing ? 'Save Changes' : 'Create Tag',
                          style: AppTypography.label,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
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

  Future<void> _save() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);

    final notifier = ref.read(tagManagerNotifierProvider.notifier);

    if (_isEditing) {
      final Tag tag = widget.existingTag!;
      tag.name = name;
      tag.color = _selectedColor;
      tag.icon = _selectedIcon;
      await notifier.update(tag);
    } else {
      await notifier.create(
        name,
        color: _selectedColor,
        icon: _selectedIcon,
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
