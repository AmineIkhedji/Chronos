// lib/repositories/notification_repository.dart
import 'package:isar_community/isar.dart';
import '../database/app_database.dart';
import '../models/notification.dart';

class NotificationRepository {
  Future<List<Notification>> getAllNotifications() async {
    return await AppDatabase.isar.notifications.where().findAll();
  }

  Future<Notification?> getNotificationById(int id) async {
    return await AppDatabase.isar.notifications.get(id);
  }

  Future<void> saveNotification(Notification notification) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.notifications.put(notification);
    });
  }

  Future<void> deleteNotification(int id) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.notifications.delete(id);
    });
  }

  Future<List<Notification>> getNotificationsForTask(int taskId) async {
    return await AppDatabase.isar.notifications
        .filter()
        .idTasksEqualTo(taskId)
        .findAll();
  }

  Future<List<Notification>> getEnabledNotifications() async {
    return await AppDatabase.isar.notifications
        .filter()
        .enabledEqualTo(true)
        .findAll();
  }

  Future<List<Notification>> getPendingNotifications() async {
    final now = DateTime.now();
    final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
    
    return await AppDatabase.isar.notifications
        .filter()
        .enabledEqualTo(true)
        .remindAtBetween(fiveMinutesAgo, now)
        .findAll();
  }

  Future<void> deleteNotificationsForTask(int taskId) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.notifications
          .filter()
          .idTasksEqualTo(taskId)
          .deleteAll();
    });
  }

  Future<void> disableAllNotifications() async {
    await AppDatabase.isar.writeTxn(() async {
      final notifications = await AppDatabase.isar.notifications.where().findAll();
      for (var notif in notifications) {
        notif.enabled = false;
        await AppDatabase.isar.notifications.put(notif);
      }
    });
  }
}