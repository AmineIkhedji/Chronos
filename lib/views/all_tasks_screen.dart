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

  // Breakpoint above which the filter row goes side-by-side instead of stacked.
  static const double _wideBreakpoint = 560;

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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        title: Text(
          widget.date == null ? 'Toutes les tâches' : 'Tâches du jour',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle tâche'),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final filteredTasks = _filterTasks(tasks);

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= _wideBreakpoint;
                final horizontalPadding = constraints.maxWidth >= 900
                    ? (constraints.maxWidth - 900) / 2 + 16
                    : 16.0;

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        4,
                      ),
                      child: _buildFilterBar(
                        context,
                        tasks,
                        categories,
                        statuses,
                        isWide,
                      ),
                    ),
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
                              actionText:
                                  tasks.isEmpty ? 'Créer une tâche' : null,
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
                                  ref.invalidate(
                                    tasksByDateProvider(widget.date!),
                                  );
                                  await ref.read(
                                    tasksByDateProvider(widget.date!).future,
                                  );
                                }
                              },
                              child: ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  8,
                                  horizontalPadding,
                                  96,
                                ),
                                itemCount: filteredTasks.length,
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];
                                  final showDateHeader =
                                      index == 0 ||
                                      !_isSameDay(
                                        task.date,
                                        filteredTasks[index - 1].date,
                                      );

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (showDateHeader) ...[
                                        if (index > 0)
                                          const SizedBox(height: 20),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                            left: 2,
                                          ),
                                          child: _DateHeaderChip(
                                            label: _formatDateHeader(
                                              task.date,
                                            ),
                                          ),
                                        ),
                                      ] else
                                        const SizedBox(height: 8),
                                      Material(
                                        color: colorScheme.surfaceContainer,
                                        borderRadius: BorderRadius.circular(
                                          16,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: TaskListItem(
                                          task: task,
                                          onToggle: () =>
                                              toggleCompletion(task),
                                          onTap: () => _openTaskDetail(
                                            context,
                                            ref,
                                            task,
                                          ),
                                          onLongPress: () => _openTaskForm(
                                            context,
                                            ref,
                                            task: task,
                                          ),
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
            ),
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

  Widget _buildFilterBar(
    BuildContext context,
    List<Task> tasks,
    List categories,
    List statuses,
    bool isWide,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final options = _filterOptions(tasks, categories, statuses);
    final selectedValue = options.any((option) => option.value == _filterValue)
        ? _filterValue
        : 'all';

    final typeField = DropdownButtonFormField<_TaskFilterType>(
      initialValue: _filterType,
      icon: const Icon(Icons.expand_more_rounded),
      decoration: _filterFieldDecoration(colorScheme, 'Filtrer par'),
      items: _TaskFilterType.values
          .map(
            (type) => DropdownMenuItem(value: type, child: Text(type.label)),
          )
          .toList(),
      onChanged: (type) {
        if (type == null) return;
        setState(() {
          _filterType = type;
          _filterValue = 'all';
        });
      },
    );

    final valueField = DropdownButtonFormField<String>(
      initialValue: selectedValue,
      icon: const Icon(Icons.expand_more_rounded),
      decoration: _filterFieldDecoration(colorScheme, _filterType.label),
      items: options,
      onChanged: (value) {
        if (value != null) setState(() => _filterValue = value);
      },
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.filter_list_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: isWide
                ? Row(
                    children: [
                      Expanded(child: typeField),
                      const SizedBox(width: 12),
                      Expanded(child: valueField),
                    ],
                  )
                : Column(
                    children: [
                      typeField,
                      const SizedBox(height: 10),
                      valueField,
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _filterFieldDecoration(ColorScheme colorScheme, String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
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

/// A small pill-shaped chip used as a date section header in the task list.
class _DateHeaderChip extends StatelessWidget {
  const _DateHeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}