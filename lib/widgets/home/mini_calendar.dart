// lib/widgets/home/mini_calendar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_providers.dart';
import '../theme/theme_colors.dart';
import '../theme/theme_provider.dart';

class MiniCalendar extends ConsumerWidget {
  const MiniCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final tasksAsync = ref.watch(todayTasksProvider);
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final userColor = ref.watch(userColorProvider);
    final primaryColor = Color(ThemeColors.userColors[userColor] ?? ThemeColors.defaultPrimary);

    final textColor = theme.colorScheme.onBackground;
    final textColorSecondary = isDark 
        ? const Color(0xFF94A3B8) 
        : const Color(0xFF64748B);

    return tasksAsync.when(
      data: (tasks) {
        final tasksByDay = <int, List<int>>{};
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
                _buildStatusDots(dayStatuses),
              ],
            );
          }),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: theme.primaryColor),
      ),
      error: (_, __) => Center(
        child: Text('Erreur calendrier', style: TextStyle(color: textColorSecondary)),
      ),
    );
  }

  String _getDayLetter(int weekday) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return days[weekday - 1];
  }

  Widget _buildStatusDots(List<int> statuses) {
    if (statuses.isEmpty) return const SizedBox(height: 6);

    final dots = statuses.take(2).map((statusId) {
      Color color;
      if (statusId == 3) color = Colors.green;
      else if (statusId == 2) color = Colors.orange;
      else color = Colors.blue;

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