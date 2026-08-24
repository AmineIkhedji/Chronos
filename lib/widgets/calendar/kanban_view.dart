// lib/widgets/calendar/kanban_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_providers.dart' hide tasksForPeriodProvider;
import '../../providers/calendar_providers.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../models/status.dart';
import '../../utils/priority_colors.dart';
import '../../utils/status_colors.dart';
import '../../views/task_detail_screen.dart';

class KanbanView extends ConsumerWidget {
  const KanbanView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusesAsync = ref.watch(allStatusesProvider);
    final tasksAsync = ref.watch(todayTasksProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    return tasksAsync.when(
      data: (tasks) {
        return statusesAsync.when(
          data: (statuses) {
            return categoriesAsync.when(
              data: (categories) {
                final categoryColors = <int, Color>{
                  for (final cat in categories)
                    cat.idCategory: Color(cat.color),
                };
                final categoryNames = <int, String>{
                  for (final cat in categories) cat.idCategory: cat.name,
                };

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Largeur de colonne fixe, quel que soit l'écran, pour que
                    // les cartes ne s'étirent jamais démesurément quand il y a
                    // peu de statuts sur un écran large. On scroll horizontalement
                    // au lieu d'étirer les colonnes en Expanded.
                    const columnWidth = 280.0;
                    final totalColumnsWidth =
                        statuses.length * (columnWidth + 8);
                    final shouldCenter =
                        totalColumnsWidth < constraints.maxWidth;

                    final row = Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: statuses.map((status) {
                        final statusTasks = tasks
                            .where((t) => t.idStatus == status.idStatus)
                            .toList();

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SizedBox(
                            width: columnWidth,
                            child: _buildKanbanColumn(
                              context,
                              ref,
                              status: status,
                              tasks: statusTasks,
                              categoryColors: categoryColors,
                              categoryNames: categoryNames,
                              onTaskDropped: (task, newStatusId) async {
                                await _updateTaskStatus(ref, task, newStatusId);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );

                    final scrollable = SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: row,
                    );

                    return shouldCenter
                        ? Center(child: scrollable)
                        : scrollable;
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Erreur')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Erreur')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Erreur')),
    );
  }

  Future<void> _updateTaskStatus(
    WidgetRef ref,
    Task task,
    int newStatusId,
  ) async {
    final controller = TaskController();
    task.idStatus = newStatusId;
    await controller.updateTask(task);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(tasksForPeriodProvider);
    ref.invalidate(tasksForMonthProvider);
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    WidgetRef ref, {
    required Status status,
    required List<Task> tasks,
    required Map<int, Color> categoryColors,
    required Map<int, String> categoryNames,
    required Future<void> Function(Task, int) onTaskDropped,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = StatusColors.getColor(status.idStatus);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? statusColor
                  : borderColor.withOpacity(0.5),
              width: candidateData.isNotEmpty ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Header de la colonne
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: statusColor.withOpacity(0.3)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status.name,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Liste des tâches (zone de drop)
              Expanded(
                child: DragTarget<int>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) {
                    onTaskDropped(
                      _getTaskById(ref, details.data),
                      status.idStatus,
                    );
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      color: candidateData.isNotEmpty
                          ? statusColor.withOpacity(0.1)
                          : null,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _buildTaskCard(
                            context,
                            ref,
                            task: task,
                            categoryColors: categoryColors,
                            categoryNames: categoryNames,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Task _getTaskById(WidgetRef ref, int taskId) {
    // Récupérer la tâche depuis le provider
    final tasks = ref.read(todayTasksProvider).value ?? [];
    return tasks.firstWhere((t) => t.idTasks == taskId);
  }

  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref, {
    required Task task,
    required Map<int, Color> categoryColors,
    required Map<int, String> categoryNames,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = Color(task.color);
    final categoryName = categoryNames[task.idCategory] ?? 'Catégorie';
    final priorityColor = PriorityColors.getColor(task.idPriority);
    final priorityLabel = PriorityColors.getLabel(task.idPriority);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Draggable<int>(
      data: task.idTasks,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: categoryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildTaskCardContent(
            context,
            task: task,
            categoryColor: categoryColor,
            categoryName: categoryName,
            priorityColor: priorityColor,
            priorityLabel: priorityLabel,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTaskCardContent(
          context,
          task: task,
          categoryColor: categoryColor,
          categoryName: categoryName,
          priorityColor: priorityColor,
          priorityLabel: priorityLabel,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildTaskCardContent(
            context,
            task: task,
            categoryColor: categoryColor,
            categoryName: categoryName,
            priorityColor: priorityColor,
            priorityLabel: priorityLabel,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCardContent(
    BuildContext context, {
    required Task task,
    required Color categoryColor,
    required String categoryName,
    required Color priorityColor,
    required String priorityLabel,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom de la tâche
        Text(
          task.title,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Catégorie
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                categoryName,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Priorité
        Row(
          children: [
            Icon(Icons.flag_rounded, size: 12, color: priorityColor),
            const SizedBox(width: 4),
            Text(
              priorityLabel,
              style: TextStyle(
                color: priorityColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
