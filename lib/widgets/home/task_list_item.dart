import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chronos/models/task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const TaskListItem({
    super.key,
    required this.task,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final isCompleted = task.isCompleted;
    final priorityColor = _priorityColor(task.idPriority);

    final timeFormat = DateFormat('HH:mm');
    final timeRange =
        '${timeFormat.format(task.startTime)} - ${timeFormat.format(task.endTime)}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 320;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 12,
              vertical: isCompact ? 10 : 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? Colors.green
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                        width: 2,
                      ),
                      color: isCompleted ? Colors.green : Colors.transparent,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(width: isCompact ? 12 : 16),
                Expanded(
                  child: isCompact
                      ? _buildCompactContent(
                          theme,
                          textColorSecondary,
                          isCompleted,
                          priorityColor,
                          timeRange,
                        )
                      : _buildRegularContent(
                          theme,
                          textColorSecondary,
                          isCompleted,
                          priorityColor,
                          timeRange,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegularContent(
    ThemeData theme,
    Color textColorSecondary,
    bool isCompleted,
    Color priorityColor,
    String timeRange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(
              isCompleted ? 0.5 : 1.0,
            ),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration:
                isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: priorityColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                timeRange,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColorSecondary.withOpacity(
                    isCompleted ? 0.5 : 1.0,
                  ),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactContent(
    ThemeData theme,
    Color textColorSecondary,
    bool isCompleted,
    Color priorityColor,
    String timeRange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(
              isCompleted ? 0.5 : 1.0,
            ),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration:
                isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: priorityColor,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              timeRange,
              style: TextStyle(
                color: textColorSecondary.withOpacity(
                  isCompleted ? 0.5 : 1.0,
                ),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _priorityColor(int priorityId) {
    if (priorityId == 3) return const Color(0xFFEF4444);
    if (priorityId == 2) return const Color(0xFFF59E0B);
    return const Color(0xFF4F7CFF);
  }
}
