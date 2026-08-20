// lib/widgets/home/task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:chronos/models/task.dart';
import '../theme/theme_provider.dart';

class TaskList extends ConsumerWidget {
  final AsyncValue<List<Task>> tasksAsync;

  const TaskList({super.key, required this.tasksAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final textColor = theme.colorScheme.onBackground;
    final textColorSecondary = isDark 
        ? const Color(0xFF94A3B8) 
        : const Color(0xFF64748B);
    final cardColor = theme.cardColor;
    final borderColor = isDark 
        ? const Color(0xFF334155) 
        : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tâches du jour',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Naviguer vers le calendrier
              },
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: theme.primaryColor,
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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Aucune tâche pour aujourd\'hui 🎉',
                  style: TextStyle(color: textColorSecondary),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor.withOpacity(0.5)),
              ),
              padding: const EdgeInsets.all(4),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => Divider(
                  color: borderColor,
                  height: 1,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskItem(task, theme, textColorSecondary);
                },
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: theme.primaryColor),
          ),
          error: (_, __) => Center(
            child: Text('Erreur tâches', style: TextStyle(color: textColorSecondary)),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(Task task, ThemeData theme, Color textColorSecondary) {
    // Couleur de priorité
    Color priorityColor;
    if (task.idPriority == 3) priorityColor = const Color(0xFFEF4444); // Haute
    else if (task.idPriority == 2) priorityColor = const Color(0xFFF59E0B); // Moyenne
    else priorityColor = const Color(0xFF4F7CFF); // Basse

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
                color: task.idStatus == 3 ? Colors.green : theme.colorScheme.onSurface.withOpacity(0.3),
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
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
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
                      style: TextStyle(
                        color: textColorSecondary,
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