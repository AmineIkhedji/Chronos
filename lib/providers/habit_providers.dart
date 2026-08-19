// lib/providers/habit_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../models/task.dart';
import 'repository_providers.dart';

// Toutes les habitudes
final allHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repo = ref.read(habitRepositoryProvider);
  return await repo.getAllHabits();
});

// Habitudes d'aujourd'hui
final todayHabitsProvider = FutureProvider<List<Map<Habit, Task>>>((ref) async {
  final repo = ref.read(habitRepositoryProvider);
  return await repo.getHabitsForToday();
});

// Habitudes pour un jour spécifique (paramétré)
final habitsForDayProvider = FutureProvider.family<List<Habit>, int>((ref, dayOfWeek) async {
  final repo = ref.read(habitRepositoryProvider);
  return await repo.getHabitsForDay(dayOfWeek);
});

// Habitudes quotidiennes (tous les jours)
final dailyHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repo = ref.read(habitRepositoryProvider);
  return await repo.getDailyHabits();
});

// Toutes les habitudes avec leurs tâches
final allHabitsWithTasksProvider = FutureProvider<List<Map<Habit, Task>>>((ref) async {
  final repo = ref.read(habitRepositoryProvider);
  return await repo.getAllHabitsWithTasks();
});

// Habitude avec sa tâche (paramétré)
final habitWithTaskProvider = FutureProvider.family<Map<Habit, Task>?, int>((ref, habitId) async {
  final repo = ref.read(habitRepositoryProvider);
  return await repo.getHabitWithTask(habitId);
});

// Jours d'une habitude (paramétré)
final habitDaysProvider = FutureProvider.family<List<int>, int>((ref, habitId) async {
  final repo = ref.read(habitRepositoryProvider);
  return await repo.getDaysForHabit(habitId);
});

// ============ ÉCRITURE ============

// Ajouter une habitude
final addHabitProvider = FutureProvider.family<void, Habit>((ref, habit) async {
  final repo = ref.read(habitRepositoryProvider);
  await repo.saveHabit(habit);
  ref.invalidate(allHabitsProvider);
  ref.invalidate(todayHabitsProvider);
});

// Mettre à jour une habitude
final updateHabitProvider = FutureProvider.family<void, Habit>((ref, habit) async {
  final repo = ref.read(habitRepositoryProvider);
  await repo.saveHabit(habit);
  ref.invalidate(allHabitsProvider);
  ref.invalidate(todayHabitsProvider);
});

// Supprimer une habitude
final deleteHabitProvider = FutureProvider.family<void, int>((ref, id) async {
  final repo = ref.read(habitRepositoryProvider);
  await repo.deleteHabit(id);
  ref.invalidate(allHabitsProvider);
  ref.invalidate(todayHabitsProvider);
});

// Ajouter des jours à une habitude (paramétré)
final addDaysToHabitProvider = FutureProvider.family<void, (int, List<int>)>((ref, params) async {
  final repo = ref.read(habitRepositoryProvider);
  final (habitId, daysOfWeek) = params;
  await repo.addDaysToHabit(habitId, daysOfWeek);
  ref.invalidate(habitDaysProvider(habitId));
  ref.invalidate(todayHabitsProvider);
});