import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Full-width bottom bar: dark background, white icons; the selected tab sits in a
/// white horizontal pill with a dark icon — aligned with app typography colors.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color _barBg = AppTheme.textDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _barBg,
      elevation: 12,
      shadowColor: Colors.black38,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: [
                _NavSlot(
                  selected: currentIndex == 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  onTap: () => _handleTap(0),
                ),
                _NavSlot(
                  selected: currentIndex == 1,
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month,
                  onTap: () => _handleTap(1),
                ),
                _NavSlot(
                  selected: currentIndex == 2,
                  icon: Icons.volunteer_activism_outlined,
                  activeIcon: Icons.volunteer_activism,
                  onTap: () => _handleTap(2),
                ),
                _NavSlot(
                  selected: currentIndex == 3,
                  icon: Icons.medical_information_outlined,
                  activeIcon: Icons.medical_information,
                  onTap: () => _handleTap(3),
                ),
                _NavSlot(
                  selected: currentIndex == 4,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  onTap: () => _handleTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(int index) {
    if (index == currentIndex) return;
    HapticFeedback.selectionClick();
    onTap(index);
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.selected,
    required this.icon,
    required this.activeIcon,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData activeIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          splashColor: Colors.white24,
          highlightColor: Colors.white12,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: selected ? 18 : 10,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              selected ? activeIcon : icon,
              size: 24,
              color: selected
                  ? AppTheme.textDark
                  : Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}
