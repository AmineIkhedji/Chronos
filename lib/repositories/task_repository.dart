// lib/repositories/task_repository.dart
import 'package:isar_community/isar.dart';
import '../database/app_database.dart';
import '../models/task.dart';
import '../models/notification.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../models/status.dart';

class TaskRepository {
  // ============ CRUD DE BASE ============

  Future<List<Task>> getAllTasks() async {
    return await AppDatabase.isar.tasks.where().findAll();
  }

  Future<Task?> getTaskById(int id) async {
    return await AppDatabase.isar.tasks.get(id);
  }

  /// Récupère une tâche avec toutes ses relations (catégorie, priorité, statut)
  Future<Map<String, dynamic>?> getTaskWithRelations(int id) async {
    final task = await getTaskById(id);
    if (task == null) return null;

    final category = await AppDatabase.isar.categorys.get(task.idCategory);
    final priority = await AppDatabase.isar.prioritys.get(task.idPriority);
    final status = await AppDatabase.isar.status.get(task.idStatus);
    final notifications = await AppDatabase.isar.notifications
        .filter()
        .idTaskEqualTo(id)
        .findAll();

    return {
      'task': task,
      'category': category,
      'priority': priority,
      'status': status,
      'notifications': notifications,
    };
  }

  Future<void> saveTask(Task task) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.tasks.put(task);
    });
  }

  Future<void> updateTask(Task task) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.tasks.put(task);
    });
  }

  Future<void> deleteTask(int id) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.notifications
          .filter()
          .idTaskEqualTo(id)
          .deleteAll();
      await AppDatabase.isar.tasks.delete(id);
    });
  }

  // ============ RECHERCHES PAR DATE ============

  Future<List<Task>> getTodayTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return await AppDatabase.isar.tasks
        .filter()
        .dateBetween(today, tomorrow, includeUpper: false)
        .findAll();
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return await AppDatabase.isar.tasks
        .filter()
        .dateBetween(start, end, includeUpper: false)
        .sortByStartTime()
        .findAll();
  }

  Future<List<Task>> getTasksForPeriod(DateTime start, DateTime end) async {
    return await AppDatabase.isar.tasks
        .filter()
        .dateBetween(start, end, includeUpper: true)
        .sortByDate()
        .findAll();
  }

  // ============ RECHERCHES AVEC RELATIONS ============

  Future<List<Task>> getTasksByStatus(int statusId) async {
    return await AppDatabase.isar.tasks
        .filter()
        .idStatusEqualTo(statusId)
        .findAll();
  }

  Future<List<Task>> getTasksByPriority(int priorityId) async {
    return await AppDatabase.isar.tasks
        .filter()
        .idPriorityEqualTo(priorityId)
        .findAll();
  }

  Future<List<Task>> getTasksByCategory(int categoryId) async {
    return await AppDatabase.isar.tasks
        .filter()
        .idCategoryEqualTo(categoryId)
        .findAll();
  }

  /// Récupère toutes les tâches avec leurs catégories, priorités et statuts
  Future<List<Map<String, dynamic>>> getAllTasksWithRelations() async {
    final tasks = await getAllTasks();
    final List<Map<String, dynamic>> result = [];

    for (var task in tasks) {
      final category = await AppDatabase.isar.categorys.get(task.idCategory);
      final priority = await AppDatabase.isar.prioritys.get(task.idPriority);
      final status = await AppDatabase.isar.status.get(task.idStatus);

      result.add({
        'task': task,
        'category': category,
        'priority': priority,
        'status': status,
      });
    }

    return result;
  }

  // ============ STATISTIQUES ============

  Future<int> getTotalTasksCount() async {
    return await AppDatabase.isar.tasks.count();
  }

  Future<int> getCompletedTasksCount() async {
    final statusTermine = await _getStatusIdByName('Terminé');
    if (statusTermine == null) return 0;

    return await AppDatabase.isar.tasks
        .filter()
        .idStatusEqualTo(statusTermine)
        .count();
  }

  Future<List<Task>> getLateTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final statusTermine = await _getStatusIdByName('Terminé');

    final allLate = await AppDatabase.isar.tasks
        .filter()
        .dateLessThan(today)
        .findAll();

    if (statusTermine == null) return allLate;
    return allLate.where((task) => task.idStatus != statusTermine).toList();
  }

  Future<int> getRemainingTasksCount() async {
    final total = await getTotalTasksCount();
    final completed = await getCompletedTasksCount();
    return total - completed;
  }

  Future<double> getSuccessRateForPeriod(DateTime start, DateTime end) async {
    final tasks = await getTasksForPeriod(start, end);
    if (tasks.isEmpty) return 0.0;

    final statusTermine = await _getStatusIdByName('Terminé');
    if (statusTermine == null) return 0.0;

    int completed = 0;
    for (var task in tasks) {
      if (task.idStatus == statusTermine) {
        completed++;
      }
    }

    return (completed / tasks.length) * 100;
  }

  Future<Map<DateTime, int>> getTasksPerDay(
    DateTime start,
    DateTime end,
  ) async {
    final tasks = await getTasksForPeriod(start, end);
    final Map<DateTime, int> stats = {};

    for (var task in tasks) {
      final date = DateTime(task.date.year, task.date.month, task.date.day);
      stats[date] = (stats[date] ?? 0) + 1;
    }

    return stats;
  }

  Future<Map<DateTime, int>> getCompletedTasksPerDay(
    DateTime start,
    DateTime end,
  ) async {
    final statusTermine = await _getStatusIdByName('Terminé');
    if (statusTermine == null) return {};

    final tasks = await AppDatabase.isar.tasks
        .filter()
        .idStatusEqualTo(statusTermine)
        .dateBetween(start, end, includeUpper: true)
        .findAll();

    final Map<DateTime, int> stats = {};
    for (var task in tasks) {
      final date = DateTime(task.date.year, task.date.month, task.date.day);
      stats[date] = (stats[date] ?? 0) + 1;
    }

    return stats;
  }

  // ============ METHODES UTILITAIRES ============

  Future<int?> _getStatusIdByName(String name) async {
    final status = await AppDatabase.isar.status
        .filter()
        .nameEqualTo(name)
        .findFirst();
    return status?.idStatus;
  }

  Future<List<Task>> searchTasks(String keyword) async {
    return await AppDatabase.isar.tasks
        .filter()
        .titleContains(keyword, caseSensitive: false)
        .findAll();
  }

  Future<List<Notification>> getNotificationsForTask(int taskId) async {
    return await AppDatabase.isar.notifications
        .filter()
        .idTaskEqualTo(taskId)
        .findAll();
  }

  Future<List<Task>> getTasksWithRemindersForToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final notifications = await AppDatabase.isar.notifications
        .filter()
        .enabledEqualTo(true)
        .findAll();

    if (notifications.isEmpty) return [];

    final List<Task> result = [];
    for (var notif in notifications) {
      final task = notif.idTask == null
          ? null
          : await AppDatabase.isar.tasks.get(notif.idTask!);
      if (task != null &&
          task.date.isAfter(today) &&
          task.date.isBefore(tomorrow)) {
        result.add(task);
      }
    }

    return result;
  }

  Future<Status?> getStatusByName(String name) async {
    return await AppDatabase.isar.status.filter().nameEqualTo(name).findFirst();
  }
}
