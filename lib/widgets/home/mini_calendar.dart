// lib/widgets/home/mini_calendar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_providers.dart';

class MiniCalendar extends ConsumerWidget {
  const MiniCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final tasksAsync = ref.watch(todayTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        // Simulation des données pour la semaine (car on a que les tâches du jour)
        // Normalement, il faudrait un provider pour la semaine entière.
        // Ici, on utilise les tâches d'aujourd'hui pour l'exemple.
        final tasksByDay = <int, List<int>>{}; // Map : Jour (1=Lundi) -> Liste d'ID de statuts

        // On ajoute les tâches d'aujourd'hui
        tasksByDay[now.weekday] = tasks.map((t) => t.idStatus).toList();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final day = firstDayOfWeek.add(Duration(days: index));
            final isToday = day.day == now.day;
            final dayStatuses = tasksByDay[day.weekday] ?? [];

            return Column(
              children: [
                Text(
                  _getDayLetter(day.weekday),
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFF5B8DEF) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Points pour les tâches du jour
                _buildStatusDots(dayStatuses),
              ],
            );
          }),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Erreur calendrier')),
    );
  }

  String _getDayLetter(int weekday) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return days[weekday - 1];
  }

  Widget _buildStatusDots(List<int> statuses) {
    if (statuses.isEmpty) return const SizedBox(height: 6);

    // On limite à 2 points max pour l'affichage
    final dots = statuses.take(2).map((statusId) {
      Color color;
      if (statusId == 3) color = Colors.green; // Terminé
      else if (statusId == 2) color = Colors.orange; // En cours
      else color = Colors.blue; // À faire

      return Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }
}