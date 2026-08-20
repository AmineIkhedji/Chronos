// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/mini_calendar.dart';
import '../widgets/home/task_list.dart';
import '../widgets/home/habit_list.dart';
import '../providers/task_providers.dart';
import '../providers/habit_providers.dart';

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

    final backgroundColor = const Color(0xFF0F172A);

    return AppScaffold(
      appBar: null,
      backgroundColor: backgroundColor,
      // ✅ On retire removeTopPadding, le SafeArea de AppScaffold fera son travail
      
      child: Container(
        width: double.infinity, // On garde juste la largeur
        color: backgroundColor,
        child: SingleChildScrollView(
          // ✅ Espacement contrôlé avec un padding simple (20px en haut)
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SALUTATION ET DATE
              Text(
                '${_getGreeting()}, Amine ${_getEmoji()}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Aujourd'hui",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getFormattedDate(),
                style: const TextStyle(
                  color: Colors.white54,
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