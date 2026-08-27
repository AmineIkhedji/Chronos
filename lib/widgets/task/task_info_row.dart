// lib/widgets/tasks/task_info_row.dart
import 'package:flutter/material.dart';

class TaskInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const TaskInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final textSecondary = theme.colorScheme.onBackground.withOpacity(0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primaryColor),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: textSecondary, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
