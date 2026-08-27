// lib/widgets/tasks/priority_badge.dart
import 'package:flutter/material.dart';
import '../../utils/priority_colors.dart';

class PriorityBadge extends StatelessWidget {
  final int priorityId;

  const PriorityBadge({super.key, required this.priorityId});

  @override
  Widget build(BuildContext context) {
    final color = PriorityColors.getColor(priorityId);
    final label = PriorityColors.getLabel(priorityId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
