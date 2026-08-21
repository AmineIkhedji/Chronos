// lib/widgets/home/habit_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronos/models/habit.dart';
import '../../views/habits_management_screen.dart';
import '../../providers/habit_providers.dart';
import 'habit_chip.dart';
import '../theme/theme_provider.dart';

class HabitList extends ConsumerWidget {
  final AsyncValue<List<Habit>> habitsAsync;

  const HabitList({super.key, required this.habitsAsync});

  Future<void> _openHabitsManagement(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HabitsManagementScreen(),
      ),
    );
    ref.invalidate(todayHabitsProvider);
    ref.invalidate(allHabitsManagementProvider);
  }

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
            Flexible(
              child: Text(
                'Habitudes',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _openHabitsManagement(context, ref),
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

            return LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: 48,
                  width: constraints.maxWidth,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: habits.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return HabitChip(
                        habit: habit,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        onTap: () => _openHabitsManagement(context, ref),
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: theme.primaryColor),
          ),
          error: (_, __) => Center(
            child: Text(
              'Erreur habitudes',
              style: TextStyle(color: textColorSecondary),
            ),
          ),
        ),
      ],
    );
  }
}