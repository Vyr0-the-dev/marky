import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/theme/theme.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Custom bottom navigation bar for Marky.
///
/// Integrates with [StatefulNavigationShell] to provide tab switching
/// with a "pitch black luxury" design language.
class MarkyBottomNav extends StatelessWidget {
  /// Creates the [MarkyBottomNav].
  const MarkyBottomNav({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell that manages branch state.
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) => navigationShell.goBranch(index);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final int currentIndex = navigationShell.currentIndex;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        border: Border(
          top: BorderSide(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _StandardNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: l10n?.navigationFeed ?? 'Feed',
                  semanticLabel: l10n?.navigationFeed ?? 'Feed',
                  isSelected: currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
              ),
              Expanded(
                child: _StandardNavItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: l10n?.navigationSearch ?? 'Search',
                  semanticLabel: l10n?.navigationSearch ?? 'Search',
                  isSelected: currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
              ),
              Expanded(
                child: Center(
                  child: _AddButton(
                    semanticLabel: l10n?.navigationAdd ?? 'Add',
                    onTap: () => _onTap(2),
                  ),
                ),
              ),
              Expanded(
                child: _StandardNavItem(
                  icon: Icons.folder_outlined,
                  activeIcon: Icons.folder,
                  label: l10n?.navigationCollections ?? 'Collections',
                  semanticLabel: l10n?.navigationCollections ?? 'Collections',
                  isSelected: currentIndex == 3,
                  onTap: () => _onTap(3),
                ),
              ),
              Expanded(
                child: _StandardNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: l10n?.navigationProfile ?? 'Profile',
                  semanticLabel: l10n?.navigationProfile ?? 'Profile',
                  isSelected: currentIndex == 4,
                  onTap: () => _onTap(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandardNavItem extends StatelessWidget {
  const _StandardNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.semanticLabel,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String semanticLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? AppColors.accentPrimary
                      : AppColors.textTertiary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.accentPrimary
                        : AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.semanticLabel,
    required this.onTap,
  });

  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentPrimary,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
