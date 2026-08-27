import 'package:flutter/material.dart';
import '../../models/task.dart';

class AllDayTasksRow extends StatelessWidget {
  final List<DateTime> days;
  final Map<int, List<Task>> tasksByDay;
  final double hourLabelWidth;
  final Color textColorSecondary;
  final Color borderColor;
  final ValueChanged<Task> onTaskTap;

  const AllDayTasksRow({
    super.key,
    required this.days,
    required this.tasksByDay,
    required this.hourLabelWidth,
    required this.textColorSecondary,
    required this.borderColor,
    required this.onTaskTap,
  });

  int _dayKey(DateTime day) => day.year * 10000 + day.month * 100 + day.day;

  @override
  Widget build(BuildContext context) {
    final maxTaskCount = days
        .map((day) => tasksByDay[_dayKey(day)]?.length ?? 0)
        .fold<int>(0, (maximum, count) => count > maximum ? count : maximum);

    if (maxTaskCount == 0) return const SizedBox.shrink();

    final rowHeight = maxTaskCount * 32.0 + 9.0;

    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: hourLabelWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, right: 6),
              child: Text(
                'Journée',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: textColorSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ...days.map((day) {
            final tasks = tasksByDay[_dayKey(day)] ?? [];

            return Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(3, 4, 3, 4),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: borderColor.withValues(alpha: 0.4)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: tasks.map((task) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: GestureDetector(
                        onTap: () => onTaskTap(task),
                        child: Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Color(task.color),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
