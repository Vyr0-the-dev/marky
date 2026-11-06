import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// Bottom navigation for Marky v2.
///
/// Design decisions:
/// - No floating / elevated nav. A 1px top border separates it from the
///   scroll region without using a shadow (Reading Room is flat).
/// - The center quick-add action uses a floating rounded-square plus button.
///
/// The widget is stateless w.r.t. navigation; it reads the current
/// shell index from its owning [StatefulNavigationShell] and delegates
/// the actual branch swap back to the shell.
class MarkyBottomNav extends StatelessWidget {
  const MarkyBottomNav({
    required this.navigationShell,
    required this.items,
    this.onQuickAddTap,
    super.key,
  });

  /// The shell owning this nav. Swapping branches through
  /// [StatefulNavigationShell.goBranch] is the idiomatic way to keep
  /// each tab's back-stack alive across tab switches.
  final StatefulNavigationShell navigationShell;

  /// Tab definitions.
  final List<MarkyNavItem> items;
  final VoidCallback? onQuickAddTap;

  int _branchIndexForItem(int itemIndex) {
    var branchIndex = 0;
    for (var i = 0; i < itemIndex; i++) {
      if (items[i].role == MarkyNavItemRole.branch) {
        branchIndex += 1;
      }
    }
    return branchIndex;
  }

  bool _isSelected(int itemIndex) {
    final MarkyNavItem item = items[itemIndex];
    if (item.role != MarkyNavItemRole.branch) return false;
    return _branchIndexForItem(itemIndex) == navigationShell.currentIndex;
  }

  void _onTap(int index) {
    final MarkyNavItem item = items[index];
    if (item.role == MarkyNavItemRole.quickAdd) {
      onQuickAddTap?.call();
      return;
    }
    final int branchIndex = _branchIndexForItem(index);
    // `initialLocation: true` resets the branch's back-stack *only*
    // when re-tapping the already-active tab — matches Instagram /
    // Twitter muscle memory.
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int branchCount = items
        .where((MarkyNavItem item) => item.role == MarkyNavItemRole.branch)
        .length;
    assert(branchCount > 0, 'Bottom nav requires at least one branch tab');

    final ThemeData theme = Theme.of(context);
    final double navHeight =
        MediaQuery.textScalerOf(context).scale(56).clamp(56, 72).toDouble();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.72),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: navHeight,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: _isSelected(i),
                    onTap: () => _onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({
    required this.item,
    required this.onTap,
    required this.reduceMotion,
  });

  final MarkyNavItem item;
  final VoidCallback onTap;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        enableFeedback: false,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform.translate(
                offset: const Offset(0, -12),
                child: AnimatedSwitcher(
                  duration:
                      reduceMotion ? Duration.zero : ReadingRoomMotion.quick,
                  child: DecoratedBox(
                    key: const ValueKey<String>('quick_add_button'),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.add_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single tab's icon + label pair.
class MarkyNavItem {
  const MarkyNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.role = MarkyNavItemRole.branch,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final MarkyNavItemRole role;

  bool get isQuickAdd => role == MarkyNavItemRole.quickAdd;
}

enum MarkyNavItemRole {
  branch,
  quickAdd,
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final MarkyNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    if (item.isQuickAdd) {
      return _QuickAddButton(
        item: item,
        onTap: onTap,
        reduceMotion: reduceMotion,
      );
    }
    final Color color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        enableFeedback: false,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Center(
          child: AnimatedContainer(
            duration: reduceMotion ? Duration.zero : ReadingRoomMotion.quick,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: ReadingRoomSpacing.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedSwitcher(
                  duration:
                      reduceMotion ? Duration.zero : ReadingRoomMotion.quick,
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    key: ValueKey<bool>(selected),
                    size: selected ? 23 : 22,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                ExcludeSemantics(
                  child: Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
