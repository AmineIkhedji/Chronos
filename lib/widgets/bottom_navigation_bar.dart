// lib/widgets/bottom_navigation_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/theme_colors.dart';
import 'theme/theme_provider.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'dialogs/create_options_dialog.dart';

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
        return LucideIcons.house;
      case AppTab.calendar:
        return LucideIcons.calendar;
      case AppTab.stats:
        return LucideIcons.chart_spline;
      case AppTab.settings:
        return LucideIcons.settings;
    }
  }
}

// ============ STATE PROVIDER ============

final selectedTabProvider = StateProvider<AppTab>((ref) {
  return AppTab.home;
});

// ============ WIDGET PRINCIPAL ============

class ChronosBottomNavigationBar extends ConsumerWidget {
  const ChronosBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isDark = ref.watch(darkModeProvider);
    final userColor = ref.watch(userColorProvider);
    final primaryColor =
        Color(ThemeColors.userColors[userColor] ?? ThemeColors.defaultPrimary);

    // ============ GLASSMORPHISM ============
    final glassColor = isDark
        ? const Color(0xFF1E293B).withOpacity(0.55)
        : const Color(0xFFFFFFFF).withOpacity(0.65);

    final glassBorderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.5);

    final inactiveColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: glassColor,
            border: Border(
              top: BorderSide(color: glassBorderColor, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
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
                        showDialog(
                          context: context,
                          builder: (context) => const CreateOptionsDialog(),
                        );
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
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
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
    required Color inactiveColor,
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
}