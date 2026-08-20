// lib/widgets/home/habit_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronos/models/habit.dart';
import 'package:chronos/models/task.dart';
import '../theme/theme_provider.dart';

class HabitList extends ConsumerWidget {
  final AsyncValue<List<Map<Habit, Task>>> habitsAsync;

  const HabitList({super.key, required this.habitsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final textColor = theme.colorScheme.onBackground;
    final textColorSecondary = isDark 
        ? const Color(0xFF94A3B8) 
        : const Color(0xFF64748B);
    final cardColor = theme.cardColor;
    final borderColor = isDark 
        ? const Color(0xFF334155) 
        : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Habitudes',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Naviguer vers la page des habitudes
              },
              child: Text(
                'Gérer',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        habitsAsync.when(
          data: (habits) {
            if (habits.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Aucune habitude pour aujourd\'hui',
                  style: TextStyle(color: textColorSecondary),
                ),
              );
            }

            return SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: habits.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final habitData = habits[index];
                  final task = habitData.values.first;
                  return _buildHabitChip(task, cardColor, borderColor);
                },
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: theme.primaryColor),
          ),
          error: (_, __) => Center(
            child: Text('Erreur habitudes', style: TextStyle(color: textColorSecondary)),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitChip(Task task, Color cardColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bolt_rounded,
            size: 16,
            color: Colors.white70,
          ),
          const SizedBox(width: 8),
          Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}