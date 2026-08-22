import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task.dart';
import '../../providers/calendar_providers.dart';
import '../../views/task_detail_screen.dart';
import '../theme/theme_provider.dart';

class ThreeDaysView extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const ThreeDaysView({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  ConsumerState<ThreeDaysView> createState() => _ThreeDaysViewState();
}

class _ThreeDaysViewState extends ConsumerState<ThreeDaysView> {
  static const double hourHeight = 60.0;
  static const double hourLabelWidth = 48.0;
  static const int daysCount = 3;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Comme pour la vue Semaine : on ouvre la grille un peu avant l'heure
    // actuelle pour tomber directement sur la partie utile de la journée.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final targetHour = (DateTime.now().hour - 1).clamp(0, 23);
        _scrollController.jumpTo(targetHour * hourHeight);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _stripTime(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final textColor = theme.colorScheme.onBackground;
    final textColorSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    // Comme pour la semaine : on affiche toujours "daysCount" jours
    // consécutifs à partir de la date sélectionnée (aujourd'hui par
    // défaut), et non un découpage fixe. Le premier jour affiché reste
    // donc "aujourd'hui" tant qu'on n'a pas navigué.
    final rangeStart = _stripTime(widget.selectedDate);
    final days = List.generate(daysCount, (i) => rangeStart.add(Duration(days: i)));
    final rangeEnd = rangeStart.add(const Duration(days: daysCount));

    final tasksAsync = ref.watch(tasksForPeriodProvider((rangeStart, rangeEnd)));

    return Column(
      children: [
        // Navigation période précédente / suivante (par pas de 3 jours)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => widget.onDateSelected(
                  rangeStart.subtract(const Duration(days: daysCount)),
                ),
              ),
              Text(
                '${days.first.day}/${days.first.month} - ${days.last.day}/${days.last.month}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => widget.onDateSelected(
                  rangeStart.add(const Duration(days: daysCount)),
                ),
              ),
            ],
          ),
        ),

        // En-tête des jours, alignée avec la colonne des heures en dessous
        _CalendarDaysHeader(
          days: days,
          hourLabelWidth: hourLabelWidth,
          textColor: textColor,
          textColorSecondary: textColorSecondary,
          primaryColor: theme.primaryColor,
        ),
        Container(height: 1, color: borderColor.withOpacity(0.5)),

        // Grille horaire (00h -> 23h), même système que la vue Semaine,
        // simplement avec moins de colonnes.
        Expanded(
          child: tasksAsync.when(
            data: (tasks) {
              final tasksByDay = <int, List<Task>>{};
              for (final task in tasks) {
                final key = task.date.year * 10000 +
                    task.date.month * 100 +
                    task.date.day;
                (tasksByDay[key] ??= []).add(task);
              }

              return SingleChildScrollView(
                controller: _scrollController,
                child: SizedBox(
                  height: 24 * hourHeight,
                  child: Stack(
                    children: [
                      // Lignes horaires + libellés des heures (00h -> 23h)
                      Column(
                        children: List.generate(24, (hour) {
                          return SizedBox(
                            height: hourHeight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: hourLabelWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2, right: 6),
                                    child: Text(
                                      '${hour.toString().padLeft(2, '0')}:00',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: textColorSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: theme.dividerColor,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      // Colonnes des jours avec les tâches
                      Positioned(
                        left: hourLabelWidth,
                        right: 0,
                        top: 0,
                        height: 24 * hourHeight,
                        child: Row(
                          children: days.map((day) {
                            final key =
                                day.year * 10000 + day.month * 100 + day.day;
                            final dayTasks = tasksByDay[key] ?? [];

                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: borderColor.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                                child: Stack(
                                  children: dayTasks.map<Widget>((task) {
                                    final start = task.startTime ??
                                        DateTime(day.year, day.month, day.day, 9);
                                    final end = task.endTime ??
                                        start.add(const Duration(hours: 1));
                                    final startValue =
                                        start.hour + start.minute / 60;
                                    final endValue =
                                        end.hour + end.minute / 60;

                                    return Positioned(
                                      left: 3,
                                      right: 3,
                                      top: startValue * hourHeight + 2,
                                      height: ((endValue - startValue) *
                                              hourHeight)
                                          .clamp(20.0, double.infinity),
                                      child: GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TaskDetailScreen(task: task),
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            task.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Erreur')),
          ),
        ),
      ],
    );
  }
}

/// En-tête horizontal affichant le nom court + le numéro de chaque jour,
/// avec le jour "aujourd'hui" mis en évidence. Même logique que dans
/// week_view.dart (dupliquée ici pour que le fichier reste autonome).
class _CalendarDaysHeader extends StatelessWidget {
  final List<DateTime> days;
  final double hourLabelWidth;
  final Color textColor;
  final Color textColorSecondary;
  final Color primaryColor;

  const _CalendarDaysHeader({
    required this.days,
    required this.hourLabelWidth,
    required this.textColor,
    required this.textColorSecondary,
    required this.primaryColor,
  });

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getDayName(int weekday) {
    const names = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    return names[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: hourLabelWidth),
          ...days.map((date) {
            final isToday = _isToday(date);
            return Expanded(
              child: Column(
                children: [
                  Text(
                    _getDayName(date.weekday),
                    style: TextStyle(
                      color: isToday ? primaryColor : textColorSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isToday ? primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday ? Colors.white : textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}