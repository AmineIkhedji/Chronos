// lib/widgets/bottom_navigation_bar.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/theme_colors.dart';
import 'theme/theme_provider.dart';
import '../providers/calendar_providers.dart';
import '../providers/task_providers.dart';
import '../providers/habit_providers.dart';
import '../providers/settings_providers.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'dialogs/create_options_dialog.dart';

// ============ ÉNUMÉRATION DES ONGLETS ============

enum AppTab { home, calendar, stats, settings }

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

final navigationLoadingProvider = StateProvider<bool>((ref) => false);

Future<void> navigateToTab(WidgetRef ref, AppTab tab) async {
  ref.read(selectedTabProvider.notifier).state = tab;

  unawaited(_refreshTabData(ref, tab));
}

Future<void> _refreshTabData(WidgetRef ref, AppTab tab) async {
  switch (tab) {
    case AppTab.home:
      ref.invalidate(todayTasksProvider);
      ref.invalidate(todayHabitsProvider);
      await Future.wait([
        ref.read(todayTasksProvider.future),
        ref.read(todayHabitsProvider.future),
      ]);
      break;
    case AppTab.calendar:
      ref.invalidate(firstDayOfWeekProvider);
      ref.invalidate(allCategoriesProvider);
      ref.invalidate(allStatusesProvider);
      await Future.wait([
        ref.read(firstDayOfWeekProvider.future),
        ref.read(allCategoriesProvider.future),
        ref.read(allStatusesProvider.future),
      ]);
      break;
    case AppTab.stats:
      ref.invalidate(globalStatisticsProvider);
      ref.invalidate(weeklyStatisticsProvider);
      ref.invalidate(todayDetailedStatsProvider);
      ref.invalidate(firstDayOfWeekProvider);
      await Future.wait([
        ref.read(globalStatisticsProvider.future),
        ref.read(weeklyStatisticsProvider.future),
        ref.read(todayDetailedStatsProvider.future),
        ref.read(firstDayOfWeekProvider.future),
      ]);
      break;
    case AppTab.settings:
      ref.invalidate(settingsProvider);
      await ref.read(settingsProvider.future);
      break;
  }
}

// ============ WIDGET PRINCIPAL ============

class ChronosBottomNavigationBar extends ConsumerWidget {
  const ChronosBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isDark = ref.watch(darkModeProvider);
    final userColor = ref.watch(userColorProvider);
    final primaryColor = Color(
      ThemeColors.userColors[userColor] ?? ThemeColors.defaultPrimary,
    );

    // ============ GLASSMORPHISM ============
    final glassColor = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.55)
        : const Color(0xFFFFFFFF).withValues(alpha: 0.65);

    final glassBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.5);

    final inactiveColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: glassColor,
            border: Border(top: BorderSide(color: glassBorderColor, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
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
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
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

    return GestureDetector(
      onTap: () {
        navigateToTab(ref, tab);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, color: color, size: 26),
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
