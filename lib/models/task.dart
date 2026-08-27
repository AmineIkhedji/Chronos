// lib/models/task.dart
import 'package:flutter/material.dart' hide Notification;
import 'package:isar_community/isar.dart';

import '../database/app_database.dart';
import '../services/notification_service.dart';
import 'notification.dart';

part 'task.g.dart';

@collection
class Task {
  Id idTasks = Isar.autoIncrement;

  late String title;
  late String description;
  late DateTime date;
  DateTime? startTime;
  DateTime? endTime;
  late int color;
  late int idCategory;
  late int idPriority;
  late int idStatus;
}

// ============ EXTENSION DE TASK POUR LES NOTIFICATIONS ============

extension TaskExtension on Task {
  /// Calcule le temps de rappel en fonction des minutes avant la tâche
  DateTime getReminderTime(int minutesBefore) {
    final taskStartTime =
        startTime ?? DateTime(date.year, date.month, date.day, 9);
    return taskStartTime.subtract(Duration(minutes: minutesBefore));
  }

  /// Vérifie si la tâche a un rappel actif
  Future<bool> hasActiveReminder() async {
    final notifications = await AppDatabase.isar.notifications
        .filter()
        .idTaskEqualTo(idTasks)
        .enabledEqualTo(true)
        .findAll();
    return notifications.isNotEmpty;
  }

  /// Récupère les rappels actifs pour cette tâche
  Future<List<Notification>> getActiveReminders() async {
    return await AppDatabase.isar.notifications
        .filter()
        .idTaskEqualTo(idTasks)
        .enabledEqualTo(true)
        .findAll();
  }

  /// Annule tous les rappels pour cette tâche
  Future<void> cancelAllReminders() async {
    final notifications = await AppDatabase.isar.notifications
        .filter()
        .idTaskEqualTo(idTasks)
        .findAll();

    for (final notif in notifications) {
      // Annuler la notification système
      await NotificationService().cancelNotification(notif.idNotif);
      // Supprimer de la base
      await AppDatabase.isar.writeTxn(() async {
        await AppDatabase.isar.notifications.delete(notif.idNotif);
      });
    }
  }

  /// Planifie un rappel pour cette tâche
  Future<void> scheduleReminder({
    required int minutesBefore,
    required TimeOfDay reminderTime,
  }) async {
    final reminderDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    await NotificationService().scheduleTaskReminder(
      idTasks,
      title,
      description,
      reminderDateTime,
    );
  }

  /// Planifie un rappel avec délai automatique (minutes avant startTime)
  Future<void> scheduleAutomaticReminder(int minutesBefore) async {
    final reminderDateTime = getReminderTime(minutesBefore);
    // S'assurer que le rappel n'est pas dans le passé
    if (reminderDateTime.isBefore(DateTime.now())) {
      print('⚠️ Le rappel serait dans le passé, ignoré');
      return;
    }

    await NotificationService().scheduleTaskReminder(
      idTasks,
      title,
      description,
      reminderDateTime,
    );
  }

  /// Vérifie si une tâche est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Vérifie si la tâche est terminée
  bool get isCompleted {
    return idStatus == 3; // 3 = Terminé
  }

  /// Vérifie si la tâche est en retard
  bool get isLate {
    if (isCompleted) return false;
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Formate la date pour l'affichage
  String formatDate() {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Formate l'heure de début pour l'affichage
  String formatStartTime() {
    if (startTime == null) return 'Pas d\'heure';
    return '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
  }

  /// Formate l'heure de fin pour l'affichage
  String formatEndTime() {
    if (endTime == null) return 'Pas d\'heure';
    return '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
  }

  /// Formate la plage horaire complète
  String formatTimeRange() {
    if (startTime == null && endTime == null) return 'Toute la journée';
    if (startTime != null && endTime == null)
      return 'À partir de ${formatStartTime()}';
    if (startTime == null && endTime != null)
      return 'Jusqu\'à ${formatEndTime()}';
    return '${formatStartTime()} - ${formatEndTime()}';
  }
}

// ============ ENUM POUR LES STATUTS ============

enum TaskStatus {
  todo(1, 'À faire', 0xFF2196F3),
  inProgress(2, 'En cours', 0xFFFF9800),
  completed(3, 'Terminé', 0xFF4CAF50);

  final int id;
  final String label;
  final int color;

  const TaskStatus(this.id, this.label, this.color);

  static TaskStatus fromId(int id) {
    return values.firstWhere(
      (status) => status.id == id,
      orElse: () => TaskStatus.todo,
    );
  }
}

// ============ ENUM POUR LES PRIORITÉS ============

enum TaskPriority {
  low(1, 'Basse', 0xFF4F7CFF),
  medium(2, 'Moyenne', 0xFFF59E0B),
  high(3, 'Haute', 0xFFEF4444);

  final int id;
  final String label;
  final int color;

  const TaskPriority(this.id, this.label, this.color);

  static TaskPriority fromId(int id) {
    return values.firstWhere(
      (priority) => priority.id == id,
      orElse: () => TaskPriority.medium,
    );
  }
}
