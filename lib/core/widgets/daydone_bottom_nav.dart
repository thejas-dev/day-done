import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';

/// Figma bottom navigation: 68px height, top hairline, icon in 56×28 pill when selected.
///
/// Five tabs plus a centered 56px FAB spacer (matches `primitives.jsx` slot `i === 2`).
/// Tab indices: 0 Today, 1 Calendar, 2 Backlog, 3 Reports (disabled Phase 2), 4 Settings.
class DayDoneBottomNav extends StatelessWidget {
  const DayDoneBottomNav({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// Shell branch index (`StatefulNavigationShell.currentIndex`).
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final border = isLight ? AppColors.dividerLight : AppColors.dividerDark;
    final navBg = isLight ? AppColors.navLight : AppColors.navDark;
    final indicator = isLight
        ? AppColors.navIndicatorLight
        : AppColors.navIndicatorDark;
    final primary = theme.colorScheme.primary;
    final muted = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return Material(
      color: navBg,
      child: SafeArea(
        top: false,
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: border)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  selected: currentIndex == 0,
                  icon: Icons.today_outlined,
                  selectedIcon: Icons.today,
                  label: 'Today',
                  primary: primary,
                  muted: muted,
                  indicator: indicator,
                  onTap: () => onDestinationSelected(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  selected: currentIndex == 1,
                  icon: Icons.calendar_month_outlined,
                  selectedIcon: Icons.calendar_month,
                  label: 'Calendar',
                  primary: primary,
                  muted: muted,
                  indicator: indicator,
                  onTap: () => onDestinationSelected(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  selected: currentIndex == 2,
                  icon: Icons.list_alt_outlined,
                  selectedIcon: Icons.list_alt,
                  label: 'Backlog',
                  primary: primary,
                  muted: muted,
                  indicator: indicator,
                  onTap: () => onDestinationSelected(2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  selected: currentIndex == 3,
                  icon: Icons.bar_chart_outlined,
                  selectedIcon: Icons.bar_chart,
                  label: 'Reports',
                  primary: primary,
                  muted: muted,
                  indicator: indicator,
                  disabled: true,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _NavItem(
                  selected: currentIndex == 4,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Settings',
                  primary: primary,
                  muted: muted,
                  indicator: indicator,
                  onTap: () => onDestinationSelected(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.primary,
    required this.muted,
    required this.indicator,
    required this.onTap,
    this.disabled = false,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color primary;
  final Color muted;
  final Color indicator;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 28,
                decoration: BoxDecoration(
                  color: selected ? indicator : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: 20,
                  color: selected ? primary : muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: selected ? primary : muted,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: IgnorePointer(ignoring: disabled, child: content),
    );
  }
}
