// lib/controllers/task_controller.dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/priority_repository.dart';
import '../repositories/status_repository.dart';
import '../services/notification_service.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../models/status.dart';
import '../utils/validators.dart';

class TaskController {
  final TaskRepository _taskRepo = TaskRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final PriorityRepository _priorityRepo = PriorityRepository();
  final StatusRepository _statusRepo = StatusRepository();
  final NotificationService _notificationService = NotificationService();

  // ============ VALIDATIONS ============

  String? validateTitle(String? value) => Validators.validateTitle(value);

  String? validateDescription(String? value) =>
      Validators.validateDescription(value);

  String? validateCategory(int? categoryId) =>
      Validators.validateCategory(categoryId);

  String? validatePriority(int? priorityId) =>
      Validators.validatePriority(priorityId);

  String? validateStatus(int? statusId) => Validators.validateStatus(statusId);

  /// Valide la date (obligatoire, pas dans le passé pour une nouvelle tâche)
  String? validateDate(DateTime? date, {bool isNewTask = true}) {
    if (date == null) {
      return 'La date est obligatoire';
    }
    if (isNewTask) {
      final today = DateTime.now();
      final dateOnly = DateTime(date.year, date.month, date.day);
      final todayOnly = DateTime(today.year, today.month, today.day);
      if (dateOnly.isBefore(todayOnly)) {
        return 'La date ne peut pas être dans le passé';
      }
    }
    return null;
  }

  /// Valide les heures (optionnelles, mais cohérentes si présentes)
  String? validateTimes(DateTime? startTime, DateTime? endTime) {
    if (startTime != null && endTime != null) {
      if (endTime.isBefore(startTime)) {
        return 'L\'heure de fin doit être après l\'heure de début';
      }
    }
    return null;
  }

  // ============ CRUD ============

  Future<void> saveTask(Task task) async {
    await _taskRepo.saveTask(task);
  }

  Future<void> updateTask(Task task) async {
    final previousTask = await _taskRepo.getTaskById(task.idTasks);
    await _taskRepo.updateTask(task);

    if (previousTask != null && !previousTask.isCompleted && task.isCompleted) {
      await _notificationService.showTaskCompletedNotification(task.title);
    }
  }

  Future<void> deleteTask(int id) async {
    await cancelAllReminders(id);
    await _taskRepo.deleteTask(id);
  }

  // ============ RECHERCHES ============

  Future<List<Task>> getAllTasks() async {
    return await _taskRepo.getAllTasks();
  }

  Future<List<Task>> getTodayTasks() async {
    return await _taskRepo.getTodayTasks();
  }

  Future<Task?> getTaskById(int id) async {
    return await _taskRepo.getTaskById(id);
  }

  // ============ RAPPELS ============

  Future<void> scheduleReminder({
    required Task task,
    required int minutesBefore,
  }) async {
    if (task.startTime == null) {
      throw Exception('Impossible de planifier un rappel sans heure de début');
    }

    final remindAt = task.startTime!.subtract(Duration(minutes: minutesBefore));
    await _notificationService.scheduleTaskReminder(
      task.idTasks,
      task.title,
      task.description,
      remindAt,
    );
  }

  Future<void> cancelAllReminders(int taskId) async {
    final task = await _taskRepo.getTaskById(taskId);
    if (task != null) {
      await task.cancelAllReminders();
    }
  }

  // ============ MÉTHODES UTILITAIRES ============

  Future<List<Category>> getCategories() async {
    return await _categoryRepo.getAllCategories();
  }

  Future<List<Priority>> getPriorities() async {
    return await _priorityRepo.getAllPriorities();
  }

  Future<List<Status>> getStatuses() async {
    return await _statusRepo.getAllStatus();
  }

  List<DropdownMenuItem<int>> getReminderOptions() {
    return [
      const DropdownMenuItem(value: 5, child: Text('5 minutes avant')),
      const DropdownMenuItem(value: 10, child: Text('10 minutes avant')),
      const DropdownMenuItem(value: 15, child: Text('15 minutes avant')),
      const DropdownMenuItem(value: 30, child: Text('30 minutes avant')),
      const DropdownMenuItem(value: 45, child: Text('45 minutes avant')),
      const DropdownMenuItem(value: 60, child: Text('1 heure avant')),
      const DropdownMenuItem(value: 120, child: Text('2 heures avant')),
      const DropdownMenuItem(value: 180, child: Text('3 heures avant')),
      const DropdownMenuItem(value: 240, child: Text('4 heures avant')),
      const DropdownMenuItem(value: 360, child: Text('6 heures avant')),
      const DropdownMenuItem(value: 720, child: Text('12 heures avant')),
      const DropdownMenuItem(value: 1440, child: Text('1 jour avant')),
      const DropdownMenuItem(value: 2880, child: Text('2 jours avant')),
    ];
  }

  String formatReminderTime(int minutes) {
    if (minutes < 60) {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours heure${hours > 1 ? 's' : ''}';
      }
      return '$hours h $remainingMinutes min';
    } else {
      final days = minutes ~/ 1440;
      return '$days jour${days > 1 ? 's' : ''}';
    }
  }
}
