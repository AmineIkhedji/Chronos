// lib/providers/calendar_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/status.dart';
import '../models/priority.dart';
import 'repository_providers.dart';

// Provider pour le premier jour de la semaine
final firstDayOfWeekProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  final settings = await repo.getSettings();
  return settings?.firstDayWeek ?? DateTime.monday;
});

// Provider pour les tâches sur une période donnée
final tasksForPeriodProvider = FutureProvider.family<List<Task>, (DateTime, DateTime)>((ref, period) async {
  final repo = ref.read(taskRepositoryProvider);
  final (start, end) = period;
  return await repo.getTasksForPeriod(start, end);
});

// Provider pour les tâches du mois
final tasksForMonthProvider = FutureProvider.family<List<Task>, DateTime>((ref, month) async {
  final repo = ref.read(taskRepositoryProvider);
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  return await repo.getTasksForPeriod(start, end);
});

// Provider pour les tâches par date
final tasksByDateProvider = FutureProvider.family<List<Task>, DateTime>((ref, date) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTasksForDate(date);
});

// Provider pour tous les statuts
final allStatusesProvider = FutureProvider<List<Status>>((ref) async {
  final repo = ref.read(statusRepositoryProvider);
  return await repo.getAllStatus();
});

// Provider pour toutes les catégories
final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.read(categoryRepositoryProvider);
  return await repo.getAllCategories();
});

// Provider pour toutes les priorités
final allPrioritiesProvider = FutureProvider<List<Priority>>((ref) async {
  final repo = ref.read(priorityRepositoryProvider);
  return await repo.getAllPriorities();
});