// lib/widgets/home/habit_chip.dart
import 'package:flutter/material.dart';
import 'package:chronos/models/habit.dart';

class HabitChip extends StatelessWidget {
  final Habit habit;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const HabitChip({
    super.key,
    required this.habit,
    required this.cardColor,
    required this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted =
        habit.color == Colors.green.value; // Vérification simplifiée

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(habit.color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Color(habit.color).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.bolt_rounded,
              size: 16,
              color: Color(habit.color),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                habit.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
