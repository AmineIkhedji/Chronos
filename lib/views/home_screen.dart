import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/home/home_header.dart';
import '../widgets/home/mini_calendar.dart';
import '../widgets/home/task_list.dart';
import '../widgets/home/habit_list.dart';
import '../widgets/home/home_greeting.dart';
import '../providers/task_providers.dart';
import '../providers/habit_providers.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/onboarding_tutorial.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // IMPORTANT : ces GlobalKey doivent être créées UNE SEULE FOIS et vivre
  // dans le State. Avant, elles étaient créées à chaque build() de
  // HomeScreen (widget "stateless"), donc à chaque rebuild (ex: refresh
  // d'un provider) le tutoriel se retrouvait avec des clés obsolètes et ne
  // savait plus retrouver les widgets à surligner.
  final _welcomeKey = GlobalKey();
  final _statsKey = GlobalKey();
  final _calendarKey = GlobalKey();
  final _tasksKey = GlobalKey();
  final _habitsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final todayHabitsAsync = ref.watch(todayHabitsProvider);
    final theme = Theme.of(context);

    final homeContent = Scaffold(
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
                HomeGreeting(key: _welcomeKey),
                const SizedBox(height: 20),
                HomeHeader(key: _statsKey),
                const SizedBox(height: 24),
                GestureDetector(
                  key: _calendarKey,
                  onTap: () {
                    ref.read(selectedTabProvider.notifier).state = AppTab.calendar;
                  },
                  child: const MiniCalendar(),
                ),
                const SizedBox(height: 24),
                TaskList(key: _tasksKey, tasksAsync: todayTasksAsync),
                const SizedBox(height: 24),
                HabitList(key: _habitsKey, habitsAsync: todayHabitsAsync),
              ],
            ),
          ),
        ),
      ),
    );

    return OnboardingTutorial(
      welcomeKey: _welcomeKey,
      statsKey: _statsKey,
      calendarKey: _calendarKey,
      tasksKey: _tasksKey,
      habitsKey: _habitsKey,
      child: homeContent,
    );
  }
}