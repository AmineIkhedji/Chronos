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
    return (a.startTime ?? DateTime(2100)).compareTo(
      b.startTime ?? DateTime(2100),
    );
  });
  return tasks;
});

final taskByIdProvider = FutureProvider.family<Task?, int>((ref, taskId) async {
  final repo = ref.read(taskRepositoryProvider);
  return repo.getTaskById(taskId);
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
    ..sort(
      (a, b) => (a.startTime ?? DateTime(2100)).compareTo(
        b.startTime ?? DateTime(2100),
      ),
    );
  final completed = tasks.where((t) => t.isCompleted).toList()
    ..sort(
      (a, b) => (a.startTime ?? DateTime(2100)).compareTo(
        b.startTime ?? DateTime(2100),
      ),
    );
  return [...incomplete, ...completed];
}

// Tâches pour une date spécifique (paramétré)
final tasksByDateProvider = FutureProvider.family<List<Task>, DateTime>((
  ref,
  date,
) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTasksForDate(date);
});

// Tâches pour une période (paramétré)
final tasksForPeriodProvider =
    FutureProvider.family<List<Task>, (DateTime, DateTime)>((
      ref,
      period,
    ) async {
      final repo = ref.read(taskRepositoryProvider);
      final (start, end) = period;
      return await repo.getTasksForPeriod(start, end);
    });

// Tâches par catégorie (paramétré)
final tasksByCategoryProvider = FutureProvider.family<List<Task>, int>((
  ref,
  categoryId,
) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTasksByCategory(categoryId);
});

// Tâches par priorité (paramétré)
final tasksByPriorityProvider = FutureProvider.family<List<Task>, int>((
  ref,
  priorityId,
) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTasksByPriority(priorityId);
});

// Tâches par statut (paramétré)
final tasksByStatusProvider = FutureProvider.family<List<Task>, int>((
  ref,
  statusId,
) async {
  final repo = ref.read(taskRepositoryProvider);
  return await repo.getTasksByStatus(statusId);
});

// Recherche par mot-clé (paramétré)
final searchTasksProvider = FutureProvider.family<List<Task>, String>((
  ref,
  keyword,
) async {
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
final taskWithRelationsProvider =
    FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
      final repo = ref.read(taskRepositoryProvider);
      return await repo.getTaskWithRelations(id);
    });

// ============ STATISTIQUES ============

// Statistiques globales
final statisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final total = await repo.getTotalTasksCount();
  final completed = await repo.getCompletedTasksCount();
  final remaining = await repo.getRemainingTasksCount();
  final lateTasks = await repo.getLateTasks();

  double successRate = 0.0;
  if (total > 0) {
    successRate = (completed / total) * 100;
  }

  return {
    'total': total,
    'completed': completed,
    'remaining': remaining,
    'late': lateTasks.length,
    'successRate': successRate,
  };
});

// Statistiques pour aujourd'hui
final todayStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repo = ref.read(taskRepositoryProvider);
  final todayTasks = await repo.getTodayTasks();

  final total = todayTasks.length;
  final completed = todayTasks.where((t) => t.isCompleted).length;
  final remaining = total - completed;

  double successRate = 0.0;
  if (total > 0) {
    successRate = (completed / total) * 100;
  }

  return {
    'total': total,
    'completed': completed,
    'remaining': remaining,
    'successRate': successRate,
  };
});

// Statistiques pour une période (paramétré)
final statisticsForPeriodProvider =
    FutureProvider.family<Map<String, dynamic>, (DateTime, DateTime)>((
      ref,
      period,
    ) async {
      final repo = ref.read(taskRepositoryProvider);
      final (start, end) = period;
      final tasks = await repo.getTasksForPeriod(start, end);
      final completed = tasks
          .where((t) => t.idStatus == 3)
          .length; // 3 = Terminé
      final successRate = tasks.isNotEmpty
          ? (completed / tasks.length) * 100
          : 0;

      return {
        'total': tasks.length,
        'completed': completed,
        'remaining': tasks.length - completed,
        'successRate': successRate,
      };
    });

// Tâches par jour (pour graphiques) (paramétré)
final tasksPerDayProvider =
    FutureProvider.family<Map<DateTime, int>, (DateTime, DateTime)>((
      ref,
      period,
    ) async {
      final repo = ref.read(taskRepositoryProvider);
      final (start, end) = period;
      return await repo.getTasksPerDay(start, end);
    });

// Tâches terminées par jour (pour graphiques) (paramétré)
final completedTasksPerDayProvider =
    FutureProvider.family<Map<DateTime, int>, (DateTime, DateTime)>((
      ref,
      period,
    ) async {
      final repo = ref.read(taskRepositoryProvider);
      final (start, end) = period;
      return await repo.getCompletedTasksPerDay(start, end);
    });

// ============ ÉCRITURE (POST/PUT/DELETE) ============

// Ajouter une tâche
final addTaskProvider = FutureProvider.family<void, Task>((ref, task) async {
  final repo = ref.read(taskRepositoryProvider);
  await repo.saveTask(task);
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
final notificationsForTaskProvider =
    FutureProvider.family<List<Notification>, int>((ref, taskId) async {
      final repo = ref.read(taskRepositoryProvider);
      return await repo.getNotificationsForTask(taskId);
    });

// Ajouter un rappel à une tâche
final addNotificationToTaskProvider = FutureProvider.family<void, Notification>(
  (ref, notification) async {
    final notifRepo = ref.read(notificationRepositoryProvider);
    await notifRepo.saveNotification(notification);
    if (notification.idTask != null) {
      ref.invalidate(notificationsForTaskProvider(notification.idTask!));
    }
  },
);

// ============ ACTIONS ============

typedef ToggleTaskCompletion = Future<void> Function(Task task);

final toggleTaskCompletionProvider = Provider<ToggleTaskCompletion>((ref) {
  return (Task task) async {
    final controller = ref.read(taskControllerProvider);

    task.idStatus = task.isCompleted ? 1 : 3;
    await controller.updateTask(task);
    ref.invalidate(taskByIdProvider(task.idTasks));
    await ref.read(taskByIdProvider(task.idTasks).future);

    if (task.isCompleted) {
      await controller.cancelAllReminders(task.idTasks);
    }

    ref.invalidate(allTasksProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(statisticsProvider);
    ref.invalidate(todayStatisticsProvider);
    ref.invalidate(notificationsForTaskProvider(task.idTasks));
    ref.invalidate(taskWithRelationsProvider(task.idTasks));
  };
});

void invalidateTaskProviders(WidgetRef ref) {
  ref.invalidate(allTasksProvider);
  ref.invalidate(todayTasksProvider);
  ref.invalidate(statisticsProvider);
  ref.invalidate(todayStatisticsProvider);
}

// Statistiques globales complètes
final globalStatisticsProvider = FutureProvider<GlobalStatistics>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final allTasks = await repo.getAllTasks();
  final completedStatus = await repo.getStatusByName('Terminé');

  final total = allTasks.length;
  final completed = allTasks
      .where((t) => t.idStatus == (completedStatus?.idStatus ?? 3))
      .length;
  final now = DateTime.now();

  // Tâches restantes = tâches futures non terminées
  final remaining = allTasks.where((t) {
    final isCompleted = t.idStatus == (completedStatus?.idStatus ?? 3);
    final isFuture = t.date.isAfter(DateTime(now.year, now.month, now.day));
    return !isCompleted && (isFuture || t.date.isAfter(now));
  }).length;

  // Tâches en retard = tâches passées non terminées
  final late = allTasks.where((t) {
    final isCompleted = t.idStatus == (completedStatus?.idStatus ?? 3);
    final isPast = t.date.isBefore(DateTime(now.year, now.month, now.day));
    return !isCompleted && isPast;
  }).length;

  final successRate = total > 0 ? (completed / total) * 100 : 0.0;

  return GlobalStatistics(
    total: total,
    completed: completed,
    remaining: remaining,
    late: late,
    successRate: successRate,
  );
});

// Statistiques hebdomadaires (tâches terminées par jour)
final weeklyStatisticsProvider = FutureProvider<Map<DateTime, int>>((
  ref,
) async {
  final repo = ref.read(taskRepositoryProvider);
  final settings = await ref.read(settingsRepositoryProvider).getSettings();
  final firstDay = settings?.firstDayWeek ?? DateTime.monday;

  final now = DateTime.now();
  // Calculer le début de la semaine selon le premier jour configuré
  final today = DateTime(now.year, now.month, now.day);
  final currentWeekday = today.weekday;
  final diff = (currentWeekday - firstDay + 7) % 7;
  final weekStart = today.subtract(Duration(days: diff));

  final weekEnd = weekStart.add(const Duration(days: 7));
  final tasks = await repo.getTasksForPeriod(weekStart, weekEnd);
  final completedStatus = await repo.getStatusByName('Terminé');
  final completedStatusId = completedStatus?.idStatus ?? 3;

  // Grouper par jour
  final stats = <DateTime, int>{};
  for (var i = 0; i < 7; i++) {
    final day = weekStart.add(Duration(days: i));
    stats[DateTime(day.year, day.month, day.day)] = 0;
  }

  for (final task in tasks) {
    if (task.idStatus == completedStatusId) {
      final day = DateTime(task.date.year, task.date.month, task.date.day);
      stats[day] = (stats[day] ?? 0) + 1;
    }
  }

  return stats;
});

// Statistiques du jour actuel (pour la barre de progression)
final todayDetailedStatsProvider = FutureProvider<TodayStats>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final tasks = await repo.getTodayTasks();
  final completedStatus = await repo.getStatusByName('Terminé');
  final completedStatusId = completedStatus?.idStatus ?? 3;

  final total = tasks.length;
  final completed = tasks.where((t) => t.idStatus == completedStatusId).length;
  final successRate = total > 0 ? (completed / total) * 100 : 0.0;

  return TodayStats(
    total: total,
    completed: completed,
    successRate: successRate,
  );
});

// ============ CLASSES DE DONNÉES ============

class GlobalStatistics {
  final int total;
  final int completed;
  final int remaining;
  final int late;
  final double successRate;

  const GlobalStatistics({
    required this.total,
    required this.completed,
    required this.remaining,
    required this.late,
    required this.successRate,
  });
}

class TodayStats {
  final int total;
  final int completed;
  final double successRate;

  const TodayStats({
    required this.total,
    required this.completed,
    required this.successRate,
  });
}
