// lib/widgets/bottom_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============ ÉNUMÉRATION DES ONGLETS ============

enum AppTab {
  home,
  calendar,
  tasks,
  habits,
  settings,
}

extension AppTabExtension on AppTab {
  String get label {
    switch (this) {
      case AppTab.home:
        return 'Accueil';
      case AppTab.calendar:
        return 'Calendrier';
      case AppTab.tasks:
        return 'Tâches';
      case AppTab.habits:
        return 'Habitudes';
      case AppTab.settings:
        return 'Paramètres';
    }
  }

  IconData get icon {
    switch (this) {
      case AppTab.home:
        return Icons.home_rounded;
      case AppTab.calendar:
        return Icons.calendar_today_rounded;
      case AppTab.tasks:
        return Icons.checklist_rounded;
      case AppTab.habits:
        return Icons.repeat_rounded;
      case AppTab.settings:
        return Icons.settings_rounded;
    }
  }
}

// ============ STATE PROVIDER ============

final selectedTabProvider = StateProvider<AppTab>((ref) {
  return AppTab.home; // Onglet par défaut
});

// ============ WIDGET ============

class ChronosBottomNavigationBar extends ConsumerWidget {
  const ChronosBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                ref: ref,
                tab: AppTab.home,
                selectedTab: selectedTab,
              ),
              _buildNavItem(
                context: context,
                ref: ref,
                tab: AppTab.calendar,
                selectedTab: selectedTab,
              ),
              _buildNavItem(
                context: context,
                ref: ref,
                tab: AppTab.tasks,
                selectedTab: selectedTab,
              ),
              _buildNavItem(
                context: context,
                ref: ref,
                tab: AppTab.habits,
                selectedTab: selectedTab,
              ),
              _buildNavItem(
                context: context,
                ref: ref,
                tab: AppTab.settings,
                selectedTab: selectedTab,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required AppTab tab,
    required AppTab selectedTab,
  }) {
    final isSelected = tab == selectedTab;
    final theme = Theme.of(context);
    final color = isSelected 
        ? theme.primaryColor 
        : (theme.brightness == Brightness.dark 
            ? Colors.grey[600] 
            : Colors.grey[400]);

    return InkWell(
      onTap: () {
        ref.read(selectedTabProvider.notifier).state = tab;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}