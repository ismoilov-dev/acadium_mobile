import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Bitta navigatsiya elementi (Student va Parent oqimi uchun umumiy).
class NavItem {
  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Ota-ona ilovasining tablari.
enum ParentTab {
  home(Icons.home_rounded, Icons.home_outlined, 'Bosh sahifa'),
  children(Icons.family_restroom_rounded, Icons.family_restroom_outlined,
      'Farzandlar'),
  payments(Icons.payments_rounded, Icons.payments_outlined, "To'lovlar"),
  profile(Icons.person_rounded, Icons.person_outline_rounded, 'Profil');

  const ParentTab(this.activeIcon, this.icon, this.label);

  final IconData activeIcon;
  final IconData icon;
  final String label;

  NavItem get item => NavItem(icon: icon, activeIcon: activeIcon, label: label);
}

/// O'quvchi ilovasining tablari.
enum AppTab {
  home(Icons.home_rounded, Icons.home_outlined, 'Bosh sahifa'),
  schedule(
      Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Jadval'),
  homework(Icons.assignment_rounded, Icons.assignment_outlined, 'Vazifa'),
  arena(Icons.emoji_events_rounded, Icons.emoji_events_outlined, 'Arena'),
  profile(Icons.person_rounded, Icons.person_outline_rounded, 'Profil');

  const AppTab(this.activeIcon, this.icon, this.label);

  final IconData activeIcon;
  final IconData icon;
  final String label;

  NavItem get item => NavItem(icon: icon, activeIcon: activeIcon, label: label);
}

/// Maxsus bottom navigation bar (element soni [items] orqali beriladi).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x14101828),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: List<Widget>.generate(items.length, (int index) {
              final NavItem tab = items[index];
              final bool isActive = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryLight
                              : Colors.transparent,
                          borderRadius: AppRadius.chip,
                        ),
                        child: Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          size: 22,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 10.5,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
