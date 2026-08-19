// lib/widgets/home/task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:chronos/models/task.dart';

class TaskList extends ConsumerWidget {
  final AsyncValue<List<Task>> tasksAsync;

  const TaskList({super.key, required this.tasksAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tâches du jour',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Naviguer vers le calendrier
                // ref.read(selectedTabProvider.notifier).state = AppTab.calendar;
              },
              child: const Text(
                'Voir tout',
                style: TextStyle(
                  color: Color(0xFF5B8DEF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        tasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Aucune tâche pour aujourd\'hui 🎉',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const Divider(
                  color: Colors.white10,
                  height: 1,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskItem(task);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Erreur tâches')),
        ),
      ],
    );
  }

  Widget _buildTaskItem(Task task) {
    // Couleur de priorité (simulée selon l'ID)
    Color priorityColor;
    if (task.idPriority == 3) priorityColor = Colors.red; // Haute
    else if (task.idPriority == 2) priorityColor = Colors.orange; // Moyenne
    else priorityColor = Colors.blue; // Basse

    // Formatage de l'heure
    final timeFormat = DateFormat('HH:mm');
    final start = timeFormat.format(task.startTime);
    final end = timeFormat.format(task.endTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Checkbox personnalisée
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.idStatus == 3 ? Colors.green : Colors.white24,
                width: 2,
              ),
              color: task.idStatus == 3 ? Colors.green : Colors.transparent,
            ),
            child: task.idStatus == 3
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$start - $end',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}