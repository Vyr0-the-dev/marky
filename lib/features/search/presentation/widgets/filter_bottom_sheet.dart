import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/collections/presentation/providers/collection_providers.dart';
import 'package:marky/features/tags/presentation/providers/tag_providers.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/tag.dart';

/// A bottom sheet that exposes all available search filter operators
/// with toggles and a date-range picker.
///
/// Returns a [SearchFilterSelection] via Navigator.pop when the user
/// applies changes.
class FilterBottomSheet extends ConsumerStatefulWidget {
  /// Creates a [FilterBottomSheet].
  const FilterBottomSheet({
    this.initialFilters = const <String, List<String>>{},
    super.key,
  });

  /// The currently active operators, keyed by operator name.
  final Map<String, List<String>> initialFilters;

  /// Shows the sheet and returns the selected filters, or `null` if dismissed.
  static Future<Map<String, List<String>>?> show(
    BuildContext context, {
    Map<String, List<String>> initialFilters = const <String, List<String>>{},
  }) {
    return showModalBottomSheet<Map<String, List<String>>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface2,
      shape: AppShapes.bottomSheetShape,
      builder: (_) => FilterBottomSheet(initialFilters: initialFilters),
    );
  }

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late final Map<String, List<String>> _activeFilters;
  DateTime? _beforeDate;
  DateTime? _afterDate;

  static const List<_FilterOption> _filterOptions = <_FilterOption>[
    _FilterOption(label: 'Favorite', key: 'is', value: 'favorite'),
    _FilterOption(label: 'Archived', key: 'is', value: 'archived'),
    _FilterOption(label: 'Unread', key: 'is', value: 'unread'),
    _FilterOption(label: 'Has Note', key: 'has', value: 'note'),
    _FilterOption(label: 'In Vault', key: 'in', value: 'vault'),
  ];

  @override
  void initState() {
    super.initState();
    _activeFilters = <String, List<String>>{
      for (final MapEntry<String, List<String>> e
          in widget.initialFilters.entries)
        e.key: List<String>.from(e.value),
    };

    final List<String> beforeValues = widget.initialFilters['before'] ?? <String>[];
    if (beforeValues.isNotEmpty) {
      _beforeDate = DateTime.tryParse(beforeValues.first);
    }

    final List<String> afterValues = widget.initialFilters['after'] ?? <String>[];
    if (afterValues.isNotEmpty) {
      _afterDate = DateTime.tryParse(afterValues.first);
    }
  }

  bool _isActive(String key, String value) {
    return _activeFilters[key]?.contains(value) ?? false;
  }

  void _toggle(String key, String value) {
    setState(() {
      final List<String> values =
          List<String>.from(_activeFilters[key] ?? <String>[]);
      if (values.contains(value)) {
        values.remove(value);
        if (values.isEmpty) {
          _activeFilters.remove(key);
        } else {
          _activeFilters[key] = values;
        }
      } else {
        _activeFilters[key] = <String>[...values, value];
      }
    });
  }

  Future<void> _pickDate({required bool isBefore}) async {
    final DateTime now = DateTime.now();
    final DateTime initial = isBefore
        ? (_beforeDate ?? now)
        : (_afterDate ?? now);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentPrimary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.surface2,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBefore) {
          _beforeDate = picked;
          _activeFilters['before'] = <String>[
            picked.toIso8601String().split('T').first,
          ];
        } else {
          _afterDate = picked;
          _activeFilters['after'] = <String>[
            picked.toIso8601String().split('T').first,
          ];
        }
      });
    }
  }

  void _clearDate({required bool isBefore}) {
    setState(() {
      if (isBefore) {
        _beforeDate = null;
        _activeFilters.remove('before');
      } else {
        _afterDate = null;
        _activeFilters.remove('after');
      }
    });
  }

  bool _isTagActive(String slug) {
    return _activeFilters['tag']?.contains(slug) ?? false;
  }

  void _toggleTag(String slug) {
    setState(() {
      final List<String> values =
          List<String>.from(_activeFilters['tag'] ?? <String>[]);
      if (values.contains(slug)) {
        values.remove(slug);
        if (values.isEmpty) {
          _activeFilters.remove('tag');
        } else {
          _activeFilters['tag'] = values;
        }
      } else {
        _activeFilters['tag'] = <String>[...values, slug];
      }
    });
  }

  bool _isCollectionActive(String slug) {
    return _activeFilters['collection']?.contains(slug) ?? false;
  }

  void _toggleCollection(String slug) {
    setState(() {
      final List<String> values =
          List<String>.from(_activeFilters['collection'] ?? <String>[]);
      if (values.contains(slug)) {
        values.remove(slug);
        if (values.isEmpty) {
          _activeFilters.remove('collection');
        } else {
          _activeFilters['collection'] = values;
        }
      } else {
        _activeFilters['collection'] = <String>[...values, slug];
      }
    });
  }

  Widget _buildTagSection() {
    final AsyncValue<List<Tag>> tagsAsync = ref.watch(tagListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tags',
          style: AppTypography.sectionTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        tagsAsync.when(
          data: (List<Tag> tags) {
            if (tags.isEmpty) {
              return Text(
                'No tags available',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.textTertiary,
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((Tag tag) {
                final bool isActive = _isTagActive(tag.slug);
                return _TagFilterChip(
                  tag: tag,
                  isActive: isActive,
                  onTap: () => _toggleTag(tag.slug),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => Text(
            'Failed to load tags',
            style: AppTypography.metadata.copyWith(
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionSection() {
    final AsyncValue<List<BookmarkCollection>> collectionsAsync =
        ref.watch(collectionListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Collections',
          style: AppTypography.sectionTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        collectionsAsync.when(
          data: (List<BookmarkCollection> collections) {
            if (collections.isEmpty) {
              return Text(
                'No collections available',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.textTertiary,
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: collections.map((BookmarkCollection collection) {
                final bool isActive = _isCollectionActive(collection.slug);
                return _CollectionFilterChip(
                  collection: collection,
                  isActive: isActive,
                  onTap: () => _toggleCollection(collection.slug),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => Text(
            'Failed to load collections',
            style: AppTypography.metadata.copyWith(
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppShapes.screenPadding,
          vertical: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Header ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Filters',
                  style: AppTypography.sectionTitle,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _activeFilters.clear();
                      _beforeDate = null;
                      _afterDate = null;
                    });
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Toggle filters ────────────────────────────────────────
            ..._filterOptions.map(
              (_FilterOption option) => _FilterToggleTile(
                label: option.label,
                isActive: _isActive(option.key, option.value),
                onChanged: (_) => _toggle(option.key, option.value),
              ),
            ),

            const Divider(color: AppColors.border, height: 24),

            // ── Tag filters ───────────────────────────────────────────
            _buildTagSection(),

            const Divider(color: AppColors.border, height: 24),

            // ── Collection filters ────────────────────────────────────
            _buildCollectionSection(),

            const Divider(color: AppColors.border, height: 24),

            // ── Date range ────────────────────────────────────────────
            Text(
              'Date Range',
              style: AppTypography.sectionTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            _DatePickerTile(
              label: 'Before',
              date: _beforeDate,
              onTap: () => _pickDate(isBefore: true),
              onClear: () => _clearDate(isBefore: true),
            ),
            const SizedBox(height: 8),
            _DatePickerTile(
              label: 'After',
              date: _afterDate,
              onTap: () => _pickDate(isBefore: false),
              onClear: () => _clearDate(isBefore: false),
            ),

            const SizedBox(height: 24),

            // ── Apply button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_activeFilters),
                child: const Text('Apply Filters'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Internal models ───────────────────────────────────────────────────

class _FilterOption {
  const _FilterOption({
    required this.label,
    required this.key,
    required this.value,
  });

  final String label;
  final String key;
  final String value;
}

// ─── Internal widgets ──────────────────────────────────────────────────

class _FilterToggleTile extends StatelessWidget {
  const _FilterToggleTile({
    required this.label,
    required this.isActive,
    required this.onChanged,
  });

  final String label;
  final bool isActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTypography.body),
      trailing: Switch(
        value: isActive,
        onChanged: onChanged,
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final String displayText = date != null
        ? '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}'
        : 'Select date';

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(
        Radius.circular(AppShapes.radiusMini),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface3,
          borderRadius: BorderRadius.circular(AppShapes.radiusMini),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: AppTypography.metadata,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayText,
                    style: AppTypography.body.copyWith(
                      color: date != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (date != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                color: AppColors.textTertiary,
                onPressed: onClear,
                tooltip: 'Clear',
              )
            else
              const Icon(
                Icons.calendar_today,
                size: 18,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Tag filter chip ───────────────────────────────────────────────────

class _TagFilterChip extends StatelessWidget {
  const _TagFilterChip({
    required this.tag,
    required this.isActive,
    required this.onTap,
  });

  final Tag tag;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tagColor = _resolveColor(tag.color);

    return Material(
      color: isActive
          ? tagColor.withValues(alpha: 0.2)
          : AppColors.surface3.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tagColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                tag.name,
                style: AppTypography.metadata.copyWith(
                  color: isActive ? tagColor : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}

// ─── Collection filter chip ────────────────────────────────────────────

class _CollectionFilterChip extends StatelessWidget {
  const _CollectionFilterChip({
    required this.collection,
    required this.isActive,
    required this.onTap,
  });

  final BookmarkCollection collection;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _resolveColor(collection.accentColor);
    final IconData? iconData = _resolveIcon(collection.icon);

    return Material(
      color: isActive
          ? accentColor.withValues(alpha: 0.2)
          : AppColors.surface3.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                iconData ?? Icons.folder,
                size: 12,
                color: isActive ? accentColor : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                collection.title,
                style: AppTypography.metadata.copyWith(
                  color: isActive ? accentColor : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  IconData? _resolveIcon(String? iconCode) {
    if (iconCode == null || iconCode.isEmpty) {
      return null;
    }
    try {
      return IconData(
        int.parse(iconCode),
        fontFamily: 'MaterialIcons',
      );
    } catch (_) {
      return null;
    }
  }
}
