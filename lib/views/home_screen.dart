// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/mini_calendar.dart';
import '../widgets/home/task_list.dart';
import '../widgets/home/habit_list.dart';
import '../providers/task_providers.dart';
import '../providers/habit_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On récupère les données depuis la BDD via les providers
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final todayHabitsAsync = ref.watch(todayHabitsProvider);

    // Couleur de fond spécifique au mode sombre (#0F172A)
    final backgroundColor = const Color(0xFF0F172A);

    return AppScaffold(
      appBar: const CustomAppBar(
        title: '',
        showBackButton: false,
        // On cache l'appBar par défaut pour un look plus clean, 
        // ou on la rend transparente.
        centerTitle: false,
      ),
      // On force le fond pour correspondre à la maquette
      child: Container(
        color: backgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Bonjour, Date, Cartes Stats)
              const HomeHeader(),
              
              const SizedBox(height: 24),
              
              // 2. Mini Calendrier
              const MiniCalendar(),
              
              const SizedBox(height: 24),
              
              // 3. Tâches du jour
              TaskList(tasksAsync: todayTasksAsync),
              
              const SizedBox(height: 24),
              
              // 4. Habitudes du jour
              HabitList(habitsAsync: todayHabitsAsync),
              
              // Espace pour le bas de page
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}