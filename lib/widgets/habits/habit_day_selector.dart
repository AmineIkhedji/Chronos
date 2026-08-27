// lib/widgets/habits/habit_day_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class HabitDaySelector extends StatelessWidget {
  final String repeatMode;
  final Set<int> selectedDays;
  final int selectedColor;
  final ValueChanged<String> onRepeatModeChanged;
  final ValueChanged<int> onDayToggle;

  static const _daysOfWeek = [
    (1, 'L'),
    (2, 'M'),
    (3, 'M'),
    (4, 'J'),
    (5, 'V'),
    (6, 'S'),
    (7, 'D'),
  ];

  const HabitDaySelector({
    super.key,
    required this.repeatMode,
    required this.selectedDays,
    required this.selectedColor,
    required this.onRepeatModeChanged,
    required this.onDayToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildRepeatModeButton(
                context: context,
                label: 'Tous les jours',
                icon: LucideIcons.calendar_days,
                isSelected: repeatMode == 'daily',
                onTap: () => onRepeatModeChanged('daily'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRepeatModeButton(
                context: context,
                label: 'Jours spécifiques',
                icon: LucideIcons.calendar_clock,
                isSelected: repeatMode == 'specific',
                onTap: () => onRepeatModeChanged('specific'),
              ),
            ),
          ],
        ),

        if (repeatMode == 'specific') ...[
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: _daysOfWeek.map((dayData) {
              final day = dayData.$1;
              final letter = dayData.$2;
              final isSelected = selectedDays.contains(day);

              return _buildDayBubble(
                context: context,
                day: day,
                letter: letter,
                isSelected: isSelected,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          if (selectedDays.isEmpty)
            Center(
              child: Text(
                'Sélectionnez au moins un jour',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildRepeatModeButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = Color(selectedColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.5)
                : theme.dividerColor.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? primaryColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBubble({
    required BuildContext context,
    required int day,
    required String letter,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final primaryColor = Color(selectedColor);

    return InkWell(
      onTap: () => onDayToggle(day),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? primaryColor.withValues(alpha: 0.2)
              : theme.cardColor,
          border: Border.all(
            color: isSelected
                ? primaryColor
                : theme.dividerColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: isSelected ? primaryColor : theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
