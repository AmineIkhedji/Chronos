// lib/widgets/calendar/day_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/calendar_providers.dart';
import '../../models/task.dart';
import '../theme/theme_provider.dart';

class DayView extends ConsumerWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;

  const DayView({
    super.key,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByDateProvider(date));
    final categoriesAsync = ref.watch(allCategoriesProvider);
    return Column(
      children: [
        // Header avec la date et navigation
        _buildDateHeader(context, ref),
        // Contenu principal
        Expanded(
          child: categoriesAsync.when(
            data: (categories) {
              final categoryColors = <int, Color>{
                for (final cat in categories) cat.idCategory: Color(cat.color),
              };

              return tasksAsync.when(
                data: (tasks) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildTimeline(
                        context,
                        ref: ref,
                        tasks: tasks,
                        categoryColors: categoryColors,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: Text('Erreur de chargement'),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
              child: Text('Erreur'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final textColor = theme.colorScheme.onBackground;
    final textColorSecondary = isDark 
        ? const Color(0xFF94A3B8) 
        : const Color(0xFF64748B);
    final primaryColor = theme.primaryColor;

    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            _getDayName(date.weekday),
            style: TextStyle(
              color: isToday ? primaryColor : textColorSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isToday ? primaryColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isToday ? Colors.white : textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  onDateSelected(date.subtract(const Duration(days: 1)));
                },
              ),
              TextButton.icon(
                onPressed: () {
                  onDateSelected(DateTime.now());
                },
                icon: const Icon(Icons.today_rounded, size: 16),
                label: const Text("Aujourd'hui"),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  onDateSelected(date.add(const Duration(days: 1)));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(
    BuildContext context, {
    required WidgetRef ref,
    required List<Task> tasks,
    required Map<int, Color> categoryColors,
  }) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final textColor = theme.colorScheme.onBackground;
    final lineColor = isDark 
        ? const Color(0xFF1E293B) 
        : const Color(0xFFF1F5F9);

    // Heures de début et fin de la journée
    const startHour = 0;
    const endHour = 24;
    const hourHeight = 60.0;

    // Positions des tâches
    final taskPositions = <_TaskPosition>[];
    for (final task in tasks) {
      final startTime = task.startTime ?? DateTime(task.date.year, task.date.month, task.date.day, 9);
      final endTime = task.endTime ?? startTime.add(const Duration(hours: 1));
      
      final startHourDouble = startTime.hour + startTime.minute / 60;
      final endHourDouble = endTime.hour + endTime.minute / 60;
      
      final top = (startHourDouble - startHour) * hourHeight;
      final height = (endHourDouble - startHourDouble) * hourHeight;
      
      taskPositions.add(_TaskPosition(
        task: task,
        top: top,
        height: height,
        startHour: startHourDouble,
        endHour: endHourDouble,
      ));
    }

    return SingleChildScrollView(
      child: SizedBox(
        height: (endHour - startHour) * hourHeight,
        child: Stack(
          children: [
            // Lignes horizontales (heures)
            Column(
              children: List.generate(endHour - startHour, (index) {
                final hour = startHour + index;
                return SizedBox(
                  height: hourHeight,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${hour.toString().padLeft(2, '0')}:00',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: textColor.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: lineColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // Ligne verticale courante
            if (_isToday(date))
              Positioned(
                left: 56,
                right: 0,
                top: _getCurrentTimePosition(hourHeight, startHour) - 4,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 2,
                      color: Colors.red,
                    ),
                    Positioned(
                      left: -5,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Tâches
            ...taskPositions.map((position) {
              final task = position.task;
              final color = categoryColors[task.idCategory] ?? theme.primaryColor;
              
              return Positioned(
                left: 64,
                right: 8,
                top: position.top + 2,
                height: position.height - 4,
                child: GestureDetector(
                  onTap: () {
                    // Navigation vers détail de la tâche
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _TaskDetailPlaceholder(task: task),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (position.height > 40)
                          Text(
                            '${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  double _getCurrentTimePosition(double hourHeight, int startHour) {
    final now = DateTime.now();
    final currentHour = now.hour + now.minute / 60;
    return (currentHour - startHour) * hourHeight;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getDayName(int weekday) {
    const days = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    return days[weekday - 1];
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _TaskPosition {
  final Task task;
  final double top;
  final double height;
  final double startHour;
  final double endHour;

  const _TaskPosition({
    required this.task,
    required this.top,
    required this.height,
    required this.startHour,
    required this.endHour,
  });
}

// Placeholder pour le détail de la tâche
class _TaskDetailPlaceholder extends StatelessWidget {
  final Task task;
  const _TaskDetailPlaceholder({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: Center(
        child: Text(
          'Détails de la tâche: ${task.title}',
          style: TextStyle(color: theme.colorScheme.onBackground),
        ),
      ),
    );
  }
}