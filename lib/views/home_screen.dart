// lib/views/home_screen.dart (CORRIGÉ)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../widgets/home/home_header.dart';
import '../widgets/home/mini_calendar.dart';
import '../widgets/home/task_list.dart';
import '../widgets/home/habit_list.dart';
import '../providers/task_providers.dart';
import '../providers/habit_providers.dart';
import '../widgets/theme/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    return 'Bonsoir';
  }

  String _getEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    return '🌙';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    try {
      final formatter = DateFormat('EEEE d MMMM', 'fr_FR');
      return formatter.format(now);
    } catch (e) {
      final formatter = DateFormat('EEEE d MMMM', 'en_US');
      return formatter.format(now);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final todayHabitsAsync = ref.watch(todayHabitsProvider);
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);

    final textColor = theme.colorScheme.onBackground;
    final textColorSecondary = isDark 
        ? const Color(0xFF94A3B8) 
        : const Color(0xFF64748B);

    // ✅ PLUS DE AppScaffold ici
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        color: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SALUTATION ET DATE (Remplace l'AppBar)
              Text(
                '${_getGreeting()}, Amine ${_getEmoji()}',
                style: TextStyle(
                  color: textColorSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Aujourd'hui",
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getFormattedDate(),
                style: TextStyle(
                  color: textColorSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // 2. CARTES DE STATISTIQUES
              const HomeHeader(),

              const SizedBox(height: 24),

              // 3. MINI CALENDRIER
              const MiniCalendar(),

              const SizedBox(height: 24),

              // 4. TÂCHES DU JOUR
              TaskList(tasksAsync: todayTasksAsync),

              const SizedBox(height: 24),

              // 5. HABITUDES DU JOUR
              HabitList(habitsAsync: todayHabitsAsync),
            ],
          ),
        ),
      ),
    );
  }
}