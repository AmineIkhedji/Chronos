// lib/widgets/home/task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronos/models/task.dart';
import '../../providers/task_providers.dart';
import '../../views/all_tasks_screen.dart';
import '../../views/task_form.dart';
import '../../views/task_detail_screen.dart';
import 'task_list_item.dart';
import '../theme/theme_provider.dart';

class TaskList extends ConsumerWidget {
  final AsyncValue<List<Task>> tasksAsync;

  const TaskList({super.key, required this.tasksAsync});

  Future<void> _openAllTasks(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllTasksScreen()),
    );
    invalidateTaskProviders(ref);
  }

  Future<void> _openTaskDetail(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
    invalidateTaskProviders(ref);
  }

  Future<void> _openTaskForm(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskForm(task: task)),
    );
    invalidateTaskProviders(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final textColor = theme.colorScheme.onSurface;
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final cardColor = theme.cardColor;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final toggleCompletion = ref.read(toggleTaskCompletionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Tâches du jour',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _openAllTasks(context, ref),
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
        LayoutBuilder(
          builder: (context, constraints) {
            return tasksAsync.when(
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
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.5),
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      for (var index = 0; index < tasks.length; index++) ...[
                        if (index > 0)
                          Divider(color: borderColor, height: 1, thickness: 1),
                        TaskListItem(
                          task: tasks[index],
                          onToggle: () => toggleCompletion(tasks[index]),
                          onTap: () =>
                              _openTaskDetail(context, ref, tasks[index]),
                          onLongPress: () =>
                              _openTaskForm(context, ref, tasks[index]),
                        ),
                      ],
                    ],
                  ),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: theme.primaryColor),
              ),
              error: (_, _) => Center(
                child: Text(
                  'Erreur tâches',
                  style: TextStyle(color: textColorSecondary),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
