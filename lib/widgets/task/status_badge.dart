// lib/widgets/tasks/status_badge.dart
import 'package:flutter/material.dart';
import '../../utils/status_colors.dart';

class StatusBadge extends StatelessWidget {
  final int statusId;

  const StatusBadge({super.key, required this.statusId});

  @override
  Widget build(BuildContext context) {
    final color = StatusColors.getColor(statusId);
    final label = StatusColors.getLabel(statusId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusId == 3 ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 14,
            color: color,
          ),
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