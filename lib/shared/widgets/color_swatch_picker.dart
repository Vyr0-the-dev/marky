import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

abstract final class MarkyAccentPalette {
  static const List<int?> values = <int?>[
    null,
    0xFF8A8A82,
    0xFF7A6E63,
    0xFFA37553,
    0xFFB58A3C,
    0xFFD7B56D,
    0xFF6E8B5C,
    0xFF2F9E74,
    0xFF4F8893,
    0xFF3F6F95,
    0xFF6B7CC1,
    0xFF8E6BB5,
    0xFFB0566F,
    0xFFD0648A,
    0xFF7D5A50,
    0xFF5C677D,
  ];
}

class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    required this.selected,
    required this.onChanged,
    this.title,
    super.key,
  });

  final int? selected;
  final ValueChanged<int?> onChanged;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null) ...<Widget>[
          Text(
            title!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.sm),
        ],
        Wrap(
          spacing: ReadingRoomSpacing.sm,
          runSpacing: ReadingRoomSpacing.sm,
          children: <Widget>[
            for (final int? argb in MarkyAccentPalette.values)
              _SwatchDot(
                color: argb == null ? null : Color(argb),
                isSelected: argb == selected,
                theme: theme,
                onTap: () => onChanged(argb),
              ),
            _CustomColorDot(
              currentCustom: _isCustomColor(selected) ? Color(selected!) : null,
              isSelected: _isCustomColor(selected),
              theme: theme,
              onPicked: (Color c) => onChanged(c.toARGB32()),
            ),
          ],
        ),
      ],
    );
  }
}

class _SwatchDot extends StatelessWidget {
  const _SwatchDot({
    required this.color,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  final Color? color;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = theme.colorScheme;
    final Color borderColor =
        isSelected ? scheme.onSurface : scheme.outlineVariant;
    final double borderWidth = isSelected ? 2.5 : 1;

    return Semantics(
      button: true,
      selected: isSelected,
      label: color == null ? 'No color' : 'Accent color',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          enableFeedback: false,
          child: AnimatedContainer(
            duration: ReadingRoomMotion.quick,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: isSelected
                  ? <BoxShadow>[
                      BoxShadow(
                        color:
                            (color ?? scheme.primary).withValues(alpha: 0.28),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: color == null && !isSelected
                ? Icon(
                    Icons.format_color_reset_outlined,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  )
                : isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: color == null
                            ? scheme.onSurface
                            : _readableContrast(color!),
                      )
                    : null,
          ),
        ),
      ),
    );
  }

  static Color _readableContrast(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

bool _isCustomColor(int? argb) {
  if (argb == null) return false;
  return !MarkyAccentPalette.values.contains(argb);
}

class _CustomColorDot extends StatelessWidget {
  const _CustomColorDot({
    required this.currentCustom,
    required this.isSelected,
    required this.theme,
    required this.onPicked,
  });

  final Color? currentCustom;
  final bool isSelected;
  final ThemeData theme;
  final ValueChanged<Color> onPicked;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = theme.colorScheme;
    final Color displayColor = currentCustom ?? scheme.onSurfaceVariant;
    final Color borderColor =
        isSelected ? scheme.onSurface : scheme.outlineVariant;
    final double borderWidth = isSelected ? 2.5 : 1;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Custom color',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _openPicker(context),
          customBorder: const CircleBorder(),
          enableFeedback: false,
          child: AnimatedContainer(
            duration: ReadingRoomMotion.quick,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: currentCustom,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: isSelected && currentCustom != null
                  ? <BoxShadow>[
                      BoxShadow(
                        color: currentCustom!.withValues(alpha: 0.28),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: isSelected && currentCustom != null
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: _SwatchDot._readableContrast(currentCustom!),
                  )
                : Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: currentCustom != null
                        ? _SwatchDot._readableContrast(currentCustom!)
                        : displayColor,
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    Color pickerColor = currentCustom ?? const Color(0xFFD7B56D);

    final Color? result = await showDialog<Color>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Custom color',
            style: theme.textTheme.titleMedium,
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color c) => pickerColor = c,
              enableAlpha: false,
              labelTypes: const <ColorLabelType>[],
              pickerAreaBorderRadius: BorderRadius.circular(12),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(pickerColor),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      onPicked(result);
    }
  }
}
