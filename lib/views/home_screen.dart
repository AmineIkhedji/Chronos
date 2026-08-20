// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/home/home_header.dart';
import '../widgets/home/mini_calendar.dart';
import '../widgets/home/task_list.dart';
import '../widgets/home/habit_list.dart';
import '../widgets/home/home_greeting.dart';
import '../providers/task_providers.dart';
import '../providers/habit_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final todayHabitsAsync = ref.watch(todayHabitsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        color: theme.scaffoldBackgroundColor,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayTasksProvider);
            ref.invalidate(todayHabitsProvider);
            ref.invalidate(statisticsProvider);
            await Future.wait([
              ref.read(todayTasksProvider.future),
              ref.read(todayHabitsProvider.future),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeGreeting(),
                const SizedBox(height: 20),
                const HomeHeader(),
                const SizedBox(height: 24),
                const MiniCalendar(),
                const SizedBox(height: 24),
                TaskList(tasksAsync: todayTasksAsync),
                const SizedBox(height: 24),
                HabitList(habitsAsync: todayHabitsAsync),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
