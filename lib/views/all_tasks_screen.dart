// lib/views/all_tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';
import '../utils/date_formatters.dart';
import '../views/task_form.dart';
import 'task_detail_screen.dart';
import '../widgets/home/task_list_item.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_state.dart';

class AllTasksScreen extends ConsumerWidget {
  const AllTasksScreen({super.key, this.date});

  final DateTime? date;

  Future<void> _openTaskForm(BuildContext context, WidgetRef ref, {Task? task}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskForm(task: task)),
    );
    invalidateTaskProviders(ref);
  }

  Future<void> _openTaskDetail(BuildContext context, WidgetRef ref, Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
    invalidateTaskProviders(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = date == null
      ? ref.watch(allTasksProvider)
      : ref.watch(tasksByDateProvider(date!));
    final toggleCompletion = ref.read(toggleTaskCompletionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(date == null ? 'Toutes les tâches' : 'Tâches du jour'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nouvelle tâche',
            onPressed: () => _openTaskForm(context, ref),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'Aucune tâche',
              message: 'Créez votre première tâche pour commencer.',
              actionText: 'Créer une tâche',
              onActionPressed: () => _openTaskForm(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (date == null) {
                ref.invalidate(allTasksProvider);
                await ref.read(allTasksProvider.future);
              } else {
                ref.invalidate(tasksByDateProvider(date!));
                await ref.read(tasksByDateProvider(date!).future);
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = tasks[index];
                final showDateHeader = index == 0 ||
                    !_isSameDay(task.date, tasks[index - 1].date);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDateHeader) ...[
                      if (index > 0) const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          _formatDateHeader(task.date),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    Material(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      child: TaskListItem(
                        task: task,
                        onToggle: () => toggleCompletion(task),
                        onTap: () => _openTaskDetail(context, ref, task),
                        onLongPress: () => _openTaskForm(context, ref, task: task),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'Impossible de charger les tâches',
          onRetry: () => ref.invalidate(allTasksProvider),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);

    if (taskDay == today) return "Aujourd'hui";
    if (taskDay == today.subtract(const Duration(days: 1))) return 'Hier';
    if (taskDay == today.add(const Duration(days: 1))) return 'Demain';

    return DateFormatters.formatFullDate(date);
  }
}