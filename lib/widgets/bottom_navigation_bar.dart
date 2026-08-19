// lib/widgets/bottom_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============ ÉNUMÉRATION DES ONGLETS ============

enum AppTab {
  home,
  calendar,
  stats,
  settings,
}

extension AppTabExtension on AppTab {
  String get label {
    switch (this) {
      case AppTab.home:
        return 'Accueil';
      case AppTab.calendar:
        return 'Calendrier';
      case AppTab.stats:
        return 'Stats';
      case AppTab.settings:
        return 'Réglages';
    }
  }

  IconData get icon {
    switch (this) {
      case AppTab.home:
        return Icons.home_rounded;
      case AppTab.calendar:
        return Icons.calendar_today_rounded;
      case AppTab.stats:
        return Icons.bar_chart_rounded;
      case AppTab.settings:
        return Icons.settings_rounded;
    }
  }
}

// ============ STATE PROVIDER ============

final selectedTabProvider = StateProvider<AppTab>((ref) {
  return AppTab.home;
});

// Provider pour le contrôle du FAB (bouton +)
final fabVisibleProvider = StateProvider<bool>((ref) {
  return true;
});

// ============ WIDGET PRINCIPAL ============

class ChronosBottomNavigationBar extends ConsumerWidget {
  const ChronosBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Couleurs personnalisées depuis le thème
    final primaryColor = theme.primaryColor;
    final inactiveColor = isDark ? Colors.grey[600] : Colors.grey[400];

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
              // Onglet 1 - Accueil
              _buildNavItem(
                context: context,
                ref: ref,
                tab: AppTab.home,
                selectedTab: selectedTab,
                primaryColor: primaryColor,
                inactiveColor: inactiveColor,
              ),
              
              // Onglet 2 - Calendrier
              _buildNavItem(
                context: context,
                ref: ref,
                tab: AppTab.calendar,
                selectedTab: selectedTab,
                primaryColor: primaryColor,
                inactiveColor: inactiveColor,
              ),
              
              // BOUTON CENTRAL FLOTTANT (+)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Action pour créer une tâche
                    _showCreateTaskDialog(context, ref);
                  },
                  child: Container(
                    height: 64,
                    width: 64,
                    alignment: Alignment.center,
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Onglet 3 - Stats
              _buildNavItem(
                context: context,
                ref: ref,
                tab: AppTab.stats,
                selectedTab: selectedTab,
                primaryColor: primaryColor,
                inactiveColor: inactiveColor,
              ),
              
              // Onglet 4 - Réglages
              _buildNavItem(
                context: context,
                ref: ref,
                tab: AppTab.settings,
                selectedTab: selectedTab,
                primaryColor: primaryColor,
                inactiveColor: inactiveColor,
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
    required Color primaryColor,
    required Color? inactiveColor,
  }) {
    final isSelected = tab == selectedTab;
    final color = isSelected ? primaryColor : inactiveColor;

    return InkWell(
      onTap: () {
        ref.read(selectedTabProvider.notifier).state = tab;
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialogue pour créer une tâche (à remplacer par votre vraie logique)
  void _showCreateTaskDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle tâche'),
        content: const Text('Formulaire de création de tâche à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}