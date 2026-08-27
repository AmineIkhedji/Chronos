// lib/views/all_tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/calendar_providers.dart'
    show allCategoriesProvider, allStatusesProvider;
import '../providers/task_providers.dart';
import '../utils/date_formatters.dart';
import '../views/task_form.dart';
import 'task_detail_screen.dart';
import '../widgets/home/task_list_item.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_state.dart';

enum _TaskFilterType {
  day('Jour'),
  category('Catégorie'),
  status('Statut');

  final String label;
  const _TaskFilterType(this.label);
}

class AllTasksScreen extends ConsumerStatefulWidget {
  const AllTasksScreen({super.key, this.date});

  final DateTime? date;

  @override
  ConsumerState<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends ConsumerState<AllTasksScreen> {
  _TaskFilterType _filterType = _TaskFilterType.day;
  String _filterValue = 'all';

  Future<void> _openTaskForm(
    BuildContext context,
    WidgetRef ref, {
    Task? task,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskForm(task: task)),
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

  @override
  Widget build(BuildContext context) {
    final tasksAsync = widget.date == null
        ? ref.watch(allTasksProvider)
        : ref.watch(tasksByDateProvider(widget.date!));
    final categories = ref.watch(allCategoriesProvider).value ?? [];
    final statuses = ref.watch(allStatusesProvider).value ?? [];
    final toggleCompletion = ref.read(toggleTaskCompletionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.date == null ? 'Toutes les tâches' : 'Tâches du jour',
        ),
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
          final filteredTasks = _filterTasks(tasks);

          return Column(
            children: [
              _buildFilterBar(tasks, categories, statuses),
              Expanded(
                child: filteredTasks.isEmpty
                    ? EmptyState(
                        icon: Icons.task_alt_rounded,
                        title: tasks.isEmpty
                            ? 'Aucune tâche'
                            : 'Aucun résultat',
                        message: tasks.isEmpty
                            ? 'Créez votre première tâche pour commencer.'
                            : 'Aucune tâche ne correspond à ce filtre.',
                        actionText: tasks.isEmpty ? 'Créer une tâche' : null,
                        onActionPressed: tasks.isEmpty
                            ? () => _openTaskForm(context, ref)
                            : null,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (widget.date == null) {
                            ref.invalidate(allTasksProvider);
                            await ref.read(allTasksProvider.future);
                          } else {
                            ref.invalidate(tasksByDateProvider(widget.date!));
                            await ref.read(
                              tasksByDateProvider(widget.date!).future,
                            );
                          }
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTasks.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            final showDateHeader =
                                index == 0 ||
                                !_isSameDay(
                                  task.date,
                                  filteredTasks[index - 1].date,
                                );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showDateHeader) ...[
                                  if (index > 0) const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8,
                                      left: 4,
                                    ),
                                    child: Text(
                                      _formatDateHeader(task.date),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
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
                                    onTap: () =>
                                        _openTaskDetail(context, ref, task),
                                    onLongPress: () =>
                                        _openTaskForm(context, ref, task: task),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'Impossible de charger les tâches',
          onRetry: () => ref.invalidate(
            widget.date == null
                ? allTasksProvider
                : tasksByDateProvider(widget.date!),
          ),
        ),
      ),
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    if (_filterValue == 'all') return tasks;

    return tasks.where((task) {
      switch (_filterType) {
        case _TaskFilterType.day:
          return _dateKey(task.date) == _filterValue;
        case _TaskFilterType.category:
          return task.idCategory.toString() == _filterValue;
        case _TaskFilterType.status:
          return task.idStatus.toString() == _filterValue;
      }
    }).toList();
  }

  Widget _buildFilterBar(List<Task> tasks, List categories, List statuses) {
    final options = _filterOptions(tasks, categories, statuses);
    final selectedValue = options.any((option) => option.value == _filterValue)
        ? _filterValue
        : 'all';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<_TaskFilterType>(
            initialValue: _filterType,
            decoration: const InputDecoration(labelText: 'Filtrer par'),
            items: _TaskFilterType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.label)),
                )
                .toList(),
            onChanged: (type) {
              if (type == null) return;
              setState(() {
                _filterType = type;
                _filterValue = 'all';
              });
            },
          ),
          const SizedBox(width: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedValue,
            decoration: InputDecoration(labelText: _filterType.label),
            items: options,
            onChanged: (value) {
              if (value != null) setState(() => _filterValue = value);
            },
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _filterOptions(
    List<Task> tasks,
    List categories,
    List statuses,
  ) {
    switch (_filterType) {
      case _TaskFilterType.day:
        final dates = tasks.map((task) => task.date).toList()
          ..sort((a, b) => a.compareTo(b));
        final uniqueDates = <String>{};
        return [
          const DropdownMenuItem(value: 'all', child: Text('Tous les jours')),
          ...dates
              .where((date) => uniqueDates.add(_dateKey(date)))
              .map(
                (date) => DropdownMenuItem(
                  value: _dateKey(date),
                  child: Text(_formatDateHeader(date)),
                ),
              ),
        ];
      case _TaskFilterType.category:
        return [
          const DropdownMenuItem(
            value: 'all',
            child: Text('Toutes les catégories'),
          ),
          ...categories.map<DropdownMenuItem<String>>(
            (category) => DropdownMenuItem(
              value: category.idCategory.toString(),
              child: Text(category.name),
            ),
          ),
        ];
      case _TaskFilterType.status:
        return [
          const DropdownMenuItem(value: 'all', child: Text('Tous les statuts')),
          ...statuses.map<DropdownMenuItem<String>>(
            (status) => DropdownMenuItem(
              value: status.idStatus.toString(),
              child: Text(status.name),
            ),
          ),
        ];
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

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
