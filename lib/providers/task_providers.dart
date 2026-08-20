// lib/providers/task_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/notification.dart';
import 'repository_providers.dart';

// ============ LECTURE (GET) ============

// Toutes les tâches (triées par date décroissante puis heure de début)
final allTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final tasks = await repo.getAllTasks();
  tasks.sort((a, b) {
    final dateCompare = b.date.compareTo(a.date);
    if (dateCompare != 0) return dateCompare;
    return a.startTime.compareTo(b.startTime);
  });
  return tasks;
});

// Tâches d'aujourd'hui (non terminées par heure de début, puis terminées)
final todayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final tasks = await repo.getTodayTasks();
  return sortTodayTasks(tasks);
});

/// Tri : tâches actives par heure de début croissante, terminées à la fin.
List<Task> sortTodayTasks(List<Task> tasks) {
  final incomplete = tasks.where((t) => !t.isCompleted).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  final completed = tasks.where((t) => t.isCompleted).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  return [...incomplete, ...completed];
}

// Tâches pour une date spécifique (paramétré)
final tasksByDateProvider = FutureProvider.family<List<Task>, DateTime>((ref, date) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTasksForDate(date);
});

// Tâches pour une période (paramétré)
final tasksForPeriodProvider = FutureProvider.family<List<Task>, (DateTime, DateTime)>((ref, period) async {
  final repo = ref.read(taskRepositoryProvider);
  final (start, end) = period;
  return await repo.getTasksForPeriod(start, end);
});

// Tâches par catégorie (paramétré)
final tasksByCategoryProvider = FutureProvider.family<List<Task>, int>((ref, categoryId) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTasksByCategory(categoryId);
});

// Tâches par priorité (paramétré)
final tasksByPriorityProvider = FutureProvider.family<List<Task>, int>((ref, priorityId) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTasksByPriority(priorityId);
});

// Tâches par statut (paramétré)
final tasksByStatusProvider = FutureProvider.family<List<Task>, int>((ref, statusId) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTasksByStatus(statusId);
});

// Recherche par mot-clé (paramétré)
final searchTasksProvider = FutureProvider.family<List<Task>, String>((ref, keyword) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.searchTasks(keyword);
});

// Tâches en retard
final lateTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getLateTasks();
});

// Tâches avec rappels aujourd'hui
final tasksWithRemindersTodayProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTasksWithRemindersForToday();
});

// Tâche avec toutes ses relations (paramétré)
final taskWithRelationsProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTaskWithRelations(id);
});

// ============ STATISTIQUES ============

// Statistiques globales
// lib/providers/task_providers.dart

// Statistiques globales
final statisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final total = await repo.getTotalTasksCount();
  final completed = await repo.getCompletedTasksCount();
  final remaining = await repo.getRemainingTasksCount();
  final lateTasks = await repo.getLateTasks();
  
  // Correction : on force le cast en double et on gère la division par zéro
  double successRate = 0.0;
  if (total > 0) {
    successRate = (completed / total) * 100;
  }
  
  return {
    'total': total,
    'completed': completed,
    'remaining': remaining,
    'late': lateTasks.length,
    'successRate': successRate, // C'est bien un double maintenant
  };
});

// Statistiques pour une période (paramétré)
final statisticsForPeriodProvider = FutureProvider.family<Map<String, dynamic>, (DateTime, DateTime)>((ref, period) async {
  final repo = ref.read(taskRepositoryProvider);
  final (start, end) = period;
  final tasks = await repo.getTasksForPeriod(start, end);
  final completed = tasks.where((t) => t.idStatus == 3).length; // 3 = Terminé
  final successRate = tasks.isNotEmpty ? (completed / tasks.length) * 100 : 0;
  
  return {
    'total': tasks.length,
    'completed': completed,
    'remaining': tasks.length - completed,
    'successRate': successRate,
  };
});

// Tâches par jour (pour graphiques) (paramétré)
final tasksPerDayProvider = FutureProvider.family<Map<DateTime, int>, (DateTime, DateTime)>((ref, period) async {
  final repo = ref.read(taskRepositoryProvider);
  final (start, end) = period;
  return await repo.getTasksPerDay(start, end);
});

// Tâches terminées par jour (pour graphiques) (paramétré)
final completedTasksPerDayProvider = FutureProvider.family<Map<DateTime, int>, (DateTime, DateTime)>((ref, period) async {
  final repo = ref.read(taskRepositoryProvider);
  final (start, end) = period;
  return await repo.getCompletedTasksPerDay(start, end);
});

// ============ ÉCRITURE (POST/PUT/DELETE) ============

// Ajouter une tâche
final addTaskProvider = FutureProvider.family<void, Task>((ref, task) async {
  final repo = ref.read(taskRepositoryProvider);
  await repo.saveTask(task);
  // Rafraîchir les données
  ref.invalidate(allTasksProvider);
  ref.invalidate(todayTasksProvider);
  ref.invalidate(statisticsProvider);
});

// Mettre à jour une tâche
final updateTaskProvider = FutureProvider.family<void, Task>((ref, task) async {
  final repo = ref.read(taskRepositoryProvider);
  await repo.updateTask(task);
  ref.invalidate(allTasksProvider);
  ref.invalidate(todayTasksProvider);
  ref.invalidate(statisticsProvider);
});

// Supprimer une tâche
final deleteTaskProvider = FutureProvider.family<void, int>((ref, id) async {
  final repo = ref.read(taskRepositoryProvider);
  await repo.deleteTask(id);
  ref.invalidate(allTasksProvider);
  ref.invalidate(todayTasksProvider);
  ref.invalidate(statisticsProvider);
});

// ============ RAPPELS (NOTIFICATIONS) ============

// Récupérer les notifications d'une tâche (paramétré)
final notificationsForTaskProvider = FutureProvider.family<List<Notification>, int>((ref, taskId) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getNotificationsForTask(taskId);
});

// Ajouter un rappel à une tâche
final addNotificationToTaskProvider = FutureProvider.family<void, Notification>((ref, notification) async {
  final notifRepo = ref.read(notificationRepositoryProvider);
  await notifRepo.saveNotification(notification);
  ref.invalidate(notificationsForTaskProvider(notification.idTasks));
});

// ============ ACTIONS ============

typedef ToggleTaskCompletion = Future<void> Function(Task task);

final toggleTaskCompletionProvider = Provider<ToggleTaskCompletion>((ref) {
  return (Task task) async {
    final repo = ref.read(taskRepositoryProvider);
    task.idStatus = task.isCompleted ? 1 : 3;
    await repo.updateTask(task);
    ref.invalidate(allTasksProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(statisticsProvider);
  };
});

void invalidateTaskProviders(WidgetRef ref) {
  ref.invalidate(allTasksProvider);
  ref.invalidate(todayTasksProvider);
  ref.invalidate(statisticsProvider);
}