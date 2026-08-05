import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/shared/models/tag.dart';

/// A compact, tappable chip displaying a tag name with optional color.
///
/// Suitable for horizontal lists inside bookmark cards or detail sheets.
/// When [tag.color] is set, the chip uses that color at low opacity as
/// background; otherwise it shows a small colored dot next to the name.
class TagChip extends StatelessWidget {
  /// Creates a [TagChip].
  const TagChip({
    required this.tag,
    this.onTap,
    this.isSelected = false,
    this.showCheckbox = false,
    super.key,
  });

  /// The tag to display.
  final Tag tag;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  /// Whether the chip is in a selected state (e.g. for assignment sheets).
  final bool isSelected;

  /// Whether to show a checkbox instead of just the color dot.
  final bool showCheckbox;

  static const double _chipHeight = 32;
  static const double _dotSize = 8;
  static const double _horizontalPadding = 12;

  @override
  Widget build(BuildContext context) {
    final Color tagColor = _resolveColor(tag.color);

    return Material(
      color: _backgroundColor(tagColor),
      borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
        child: Container(
          height: _chipHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (showCheckbox) ...<Widget>[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: onTap != null
                        ? (_) => onTap!()
                        : null,
                    activeColor: tagColor,
                    checkColor: AppColors.base,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: isSelected ? tagColor : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...<Widget>[
                Container(
                  width: _dotSize,
                  height: _dotSize,
                  decoration: BoxDecoration(
                    color: tagColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                tag.name,
                style: AppTypography.metadata.copyWith(
                  color: isSelected ? tagColor : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parses a hex color string or falls back to the default accent.
  Color _resolveColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return AppColors.accentPrimary;
    }
    try {
      final String sanitized = hex.replaceAll('#', '');
      if (sanitized.length == 6) {
        return Color(int.parse('FF$sanitized', radix: 16));
      }
      if (sanitized.length == 8) {
        return Color(int.parse(sanitized, radix: 16));
      }
    } catch (_) {
      // Fall through to default.
    }
    return AppColors.accentPrimary;
  }

  /// Computes a subtle background color from the tag color.
  Color _backgroundColor(Color color) {
    if (isSelected) {
      return color.withValues(alpha: 0.15);
    }
    return AppColors.surface3.withValues(alpha: 0.6);
  }
}
