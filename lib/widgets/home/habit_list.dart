// lib/widgets/home/habit_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronos/models/habit.dart';
import 'package:chronos/models/task.dart';

class HabitList extends ConsumerWidget {
  final AsyncValue<List<Map<Habit, Task>>> habitsAsync;

  const HabitList({super.key, required this.habitsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Habitudes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Naviguer vers la page des habitudes
                // ref.read(selectedTabProvider.notifier).state = AppTab.habits;
              },
              child: const Text(
                'Gérer',
                style: TextStyle(
                  color: Color(0xFF5B8DEF),
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
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Aucune habitude pour aujourd\'hui',
                  style: TextStyle(color: Colors.white54),
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
                  return _buildHabitChip(task);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Erreur habitudes')),
        ),
      ],
    );
  }

  Widget _buildHabitChip(Task task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bolt_rounded, // Icône par défaut
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