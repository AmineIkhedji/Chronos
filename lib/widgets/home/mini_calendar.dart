// lib/widgets/home/mini_calendar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_providers.dart';
import '../bottom_navigation_bar.dart';
import '../theme/theme_colors.dart';
import '../theme/theme_provider.dart';
import '../../providers/repository_providers.dart';
import '../../models/task.dart';
import '../../models/category.dart';

class MiniCalendar extends ConsumerWidget {
  const MiniCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final tasksAsync = ref.watch(allTasksProvider);
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final userColor = ref.watch(userColorProvider);
    final primaryColor = Color(ThemeColors.userColors[userColor] ?? ThemeColors.defaultPrimary);

    final textColor = theme.colorScheme.onBackground;
    final textColorSecondary = isDark 
        ? const Color(0xFF94A3B8) 
        : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        // Navigation vers la page Calendrier via le provider
        ref.read(selectedTabProvider.notifier).state = AppTab.calendar;
      },
      child: tasksAsync.when(
        data: (allTasks) {
          return FutureBuilder<List<Category>>(
            future: ref.read(categoryRepositoryProvider).getAllCategories(),
            builder: (context, categorySnapshot) {
              final categories = categorySnapshot.data ?? [];
              final categoryColors = <int, Color>{
                for (final cat in categories) cat.idCategory: Color(cat.color),
              };

              // Générer les 7 jours à partir d'aujourd'hui
              final daysToShow = List.generate(7, (index) {
                return DateTime(now.year, now.month, now.day + index);
              });

              // Grouper les tâches par jour (clé : année*10000 + mois*100 + jour)
              final tasksByDay = <int, List<Task>>{};
              for (final task in allTasks) {
                final dateKey = task.date.year * 10000 + task.date.month * 100 + task.date.day;
                if (!tasksByDay.containsKey(dateKey)) {
                  tasksByDay[dateKey] = [];
                }
                tasksByDay[dateKey]!.add(task);
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: daysToShow.map((day) {
                  final isToday = day.day == now.day && 
                                  day.month == now.month && 
                                  day.year == now.year;
                  final dateKey = day.year * 10000 + day.month * 100 + day.day;
                  final dayTasks = tasksByDay[dateKey] ?? [];

                  return Column(
                    children: [
                      Text(
                        _getDayLetter(day.weekday),
                        style: TextStyle(
                          color: isToday ? textColor : textColorSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isToday ? primaryColor : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isToday ? Colors.white : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildTaskIndicators(dayTasks, categoryColors),
                    ],
                  );
                }).toList(),
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
        error: (_, __) => Center(
          child: Text('Erreur calendrier', style: TextStyle(color: textColorSecondary)),
        ),
      ),
    );
  }

  String _getDayLetter(int weekday) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return days[weekday - 1];
  }

  Widget _buildTaskIndicators(List<Task> tasks, Map<int, Color> categoryColors) {
    if (tasks.isEmpty) return const SizedBox(height: 6);

    final visibleTasks = tasks.take(2).toList();
    final hasMore = tasks.length > 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visibleTasks.map((task) {
          final taskColor = categoryColors[task.idCategory] ?? Colors.grey;
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: taskColor,
              shape: BoxShape.circle,
            ),
          );
        }),
        if (hasMore)
          Text(
            '+',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}