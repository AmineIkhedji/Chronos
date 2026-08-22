// lib/widgets/calendar/month_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/calendar_providers.dart';
import '../../models/task.dart';
import '../theme/theme_provider.dart';
import '../../views/all_tasks_screen.dart';

class MonthView extends ConsumerWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const MonthView({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstDayOfWeek = ref.watch(firstDayOfWeekProvider).value ?? DateTime.monday;
    final tasksAsync = ref.watch(tasksForMonthProvider(selectedDate));
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final textColor = theme.colorScheme.onBackground;
    final textColorSecondary = isDark 
        ? const Color(0xFF94A3B8) 
        : const Color(0xFF64748B);
    final primaryColor = theme.primaryColor;

    // Calculer les jours du mois
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final daysInMonth = lastDay.day;

    // Calculer le décalage pour le premier jour
    final firstWeekday = firstDay.weekday;
    final offset = (firstWeekday - firstDayOfWeek + 7) % 7;

    final totalCells = ((offset + daysInMonth + 6) ~/ 7) * 7;
    final cells = List.generate(totalCells, (index) {
      if (index < offset) return null;
      final day = index - offset + 1;
      if (day > daysInMonth) return null;
      return DateTime(selectedDate.year, selectedDate.month, day);
    });

    return Column(
      children: [
        // Header du mois avec navigation
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  onDateSelected(DateTime(selectedDate.year, selectedDate.month - 1, 1));
                },
              ),
              Text(
                _getMonthName(selectedDate.month) + ' ' + selectedDate.year.toString(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  onDateSelected(DateTime(selectedDate.year, selectedDate.month + 1, 1));
                },
              ),
            ],
          ),
        ),
        
        // Jours de la semaine
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(7, (index) {
              final day = (index + firstDayOfWeek - 1) % 7 + 1;
              return Expanded(
                child: Center(
                  child: Text(
                    _getDayShortName(day),
                    style: TextStyle(
                      color: textColorSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        
        // Grille du mois
        Expanded(
          child: categoriesAsync.when(
            data: (categories) {
              final categoryColors = <int, Color>{
                for (final cat in categories) cat.idCategory: Color(cat.color),
              };

              return tasksAsync.when(
                data: (tasks) {
                  final tasksByDay = <int, List<Task>>{};
                  for (final task in tasks) {
                    final dateKey = task.date.year * 10000 + task.date.month * 100 + task.date.day;
                    if (!tasksByDay.containsKey(dateKey)) {
                      tasksByDay[dateKey] = [];
                    }
                    tasksByDay[dateKey]!.add(task);
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 600;
                      final cellAspectRatio = isCompact ? 0.68 : 0.9;

                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: cellAspectRatio,
                        ),
                        itemCount: cells.length,
                        itemBuilder: (context, index) {
                          final date = cells[index];
                          if (date == null) return const SizedBox.shrink();

                          final isToday = date.year == DateTime.now().year &&
                              date.month == DateTime.now().month &&
                              date.day == DateTime.now().day;
                          final isSelected = date.year == selectedDate.year &&
                              date.month == selectedDate.month &&
                              date.day == selectedDate.day;

                          final dateKey = date.year * 10000 + date.month * 100 + date.day;
                          final dayTasks = tasksByDay[dateKey] ?? [];

                          return GestureDetector(
                            onTap: () {
                              onDateSelected(date);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllTasksScreen(date: date),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor.withOpacity(0.2) : null,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected 
                                    ? Border.all(color: primaryColor, width: 2)
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: isToday ? primaryColor : null,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        color: isToday ? Colors.white : textColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Indicateurs de tâches (hauteur fixe pour ne jamais dépasser)
                                  SizedBox(
                                    height: 8,
                                    child: dayTasks.isEmpty
                                        ? null
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ...dayTasks.take(2).map((task) {
                                                final color = categoryColors[task.idCategory] ?? Colors.grey;
                                                return Container(
                                                  width: 6,
                                                  height: 6,
                                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                );
                                              }),
                                              if (dayTasks.length > 2)
                                                Text(
                                                  '+${dayTasks.length - 2}',
                                                  style: TextStyle(
                                                    color: textColorSecondary,
                                                    fontSize: 8,
                                                  ),
                                                ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Erreur')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Erreur')),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 
                    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return months[month - 1];
  }

  String _getDayShortName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }
}