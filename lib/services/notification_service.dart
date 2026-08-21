// lib/services/notification_service.dart - VERSION CORRIGÉE
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../repositories/settings_repository.dart';
import '../repositories/notification_repository.dart';
import '../models/notification.dart' as notif_model;
import '../models/task.dart';
import '../models/habit.dart';
import '../database/app_database.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final SettingsRepository _settingsRepo = SettingsRepository();
  final NotificationRepository _notifRepo = NotificationRepository();

  static const String _channelId = 'chronos_notifications';
  static const String _channelName = 'Rappels Chronos';
  static const String _channelDescription =
      'Notifications pour vos tâches et habitudes';

  bool _isInitialized = false;
  int _lastNotificationId = 0;

  // ============ GESTION DES IDS 32 BITS ============

  int _generateSafeId() {
    // Générer un ID dans la plage 32 bits signée [-2^31, 2^31 - 1]
    _lastNotificationId++;
    if (_lastNotificationId >= 2147483647) {
      _lastNotificationId = 1;
    }
    return _lastNotificationId;
  }

  Future<int> _getNextAvailableId() async {
    // Récupérer le dernier ID utilisé en base
    final notifications = await _notifRepo.getAllNotifications();
    if (notifications.isEmpty) {
      return 1;
    }

    // Trouver le plus grand ID
    int maxId = 0;
    for (final notif in notifications) {
      if (notif.idNotif > maxId) {
        maxId = notif.idNotif;
      }
    }

    return maxId + 1 <= 2147483647 ? maxId + 1 : 1;
  }

  // ============ INITIALISATION ============

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (!kIsWeb) {
      await _createNotificationChannel();
    }

    _isInitialized = true;
    print('🔔 Service de notifications initialisé');
  }

  Future<void> _createNotificationChannel() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
          playSound: true,
        ),
      );
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final payload = response.payload!.split('|');
      final type = payload[0];
      final id = int.parse(payload[1]);
      print('🔔 Tap sur notification: $type, ID: $id');
    }
  }

  // ============ PERMISSIONS ============

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin == null) return false;

      final notificationsGranted =
          await androidPlugin.requestNotificationsPermission() ?? false;
      final exactAlarmsGranted =
          await androidPlugin.requestExactAlarmsPermission() ?? false;
      return notificationsGranted && exactAlarmsGranted;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return status ?? false;
    }

    return false;
  }

  Future<bool> areNotificationsEnabled() async {
    final settings = await _settingsRepo.getSettings();
    return settings?.notificationsEnabled ?? true;
  }

  // ============ PLANIFICATION ============

  Future<void> scheduleTaskReminder(
    int taskId,
    String title,
    String description,
    DateTime remindAt,
  ) async {
    if (!await areNotificationsEnabled()) {
      print('🔔 Notifications désactivées - rappel non planifié');
      return;
    }

    // Vérifier que le rappel est dans le futur
    if (remindAt.isBefore(DateTime.now())) {
      print('⚠️ L\'heure planifiée est déjà passée, notification ignorée');
      return;
    }

    try {
      final existingNotifications = await _notifRepo.getNotificationsForTask(
        taskId,
      );
      for (final existingNotification in existingNotifications) {
        await cancelNotification(existingNotification.idNotif);
      }
      await _notifRepo.deleteNotificationsForTask(taskId);

      // Générer un ID valide 32 bits
      final id = await _getNextAvailableId();

      final notification = notif_model.Notification()
        ..idNotif = id
        ..idTask = taskId
        ..remindAt = remindAt
        ..enabled = true;

      await _notifRepo.saveNotification(notification);

      await _scheduleNotification(
        id: id,
        title: '🔔 Rappel: $title',
        body: 'Il est temps de commencer cette tâche !',
        scheduledTime: remindAt,
        payload: 'task|$taskId',
      );

      print(
        '✅ Rappel planifié pour la tâche "$title" à ${remindAt.toLocal()} (ID: $id)',
      );
    } catch (e) {
      print('❌ Erreur lors de la planification du rappel : $e');
    }
  }

  Future<void> scheduleHabitReminder(
    int habitId,
    String title,
    DateTime scheduledTime,
  ) async {
    if (!await areNotificationsEnabled()) {
      print('🔔 Notifications désactivées - rappel d\'habitude non planifié');
      return;
    }

    if (scheduledTime.isBefore(DateTime.now())) {
      print('⚠️ L\'heure planifiée est déjà passée, notification ignorée');
      return;
    }

    try {
      final id = await _getNextAvailableId();

      final notification = notif_model.Notification()
        ..idNotif = id
        ..idHabit = habitId
        ..remindAt = scheduledTime
        ..enabled = true;

      await _notifRepo.saveNotification(notification);

      await _scheduleNotification(
        id: id,
        title: '🌱 Habitude: $title',
        body: 'C\'est l\'heure de votre habitude quotidienne !',
        scheduledTime: scheduledTime,
        payload: 'habit|$habitId',
      );

      print(
        '✅ Rappel d\'habitude planifié pour "$title" à ${scheduledTime.toLocal()} (ID: $id)',
      );
    } catch (e) {
      print('❌ Erreur lors de la planification du rappel d\'habitude : $e');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    final tzTime = _toTZDateTime(scheduledTime);

    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print('⚠️ L\'heure planifiée est déjà passée, notification ignorée');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      playSound: true,
      styleInformation: const BigTextStyleInformation(''),
    );

    final darwinDetails = DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  tz.TZDateTime _toTZDateTime(DateTime date) {
    final tzLocation = tz.local;
    return tz.TZDateTime.from(date.toLocal(), tzLocation);
  }

  // ============ MÉTHODES UTILES ============

  Future<void> cancelNotification(int id, {bool logCancellation = true}) async {
    await _notifications.cancel(id);
    if (logCancellation) {
      print('🔔 Notification annulée (ID: $id)');
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🔔 Toutes les notifications annulées');
  }

  Future<void> rescheduleAllActiveNotifications() async {
    if (!await areNotificationsEnabled()) {
      await cancelAllNotifications();
      return;
    }

    final notifications = await _notifRepo.getEnabledNotifications();
    final rescheduledNotificationIds = <int>{};
    await _notifications.cancelAll();

    for (final notif in notifications) {
      if (!rescheduledNotificationIds.add(notif.idNotif)) {
        continue;
      }
      if (notif.remindAt.isBefore(DateTime.now())) {
        // Supprimer les notifications passées
        await _notifRepo.deleteNotification(notif.idNotif);
        await cancelNotification(notif.idNotif, logCancellation: false);
        continue;
      }

      if (notif.idHabit != null) {
        final habit = await AppDatabase.isar.habits.get(notif.idHabit!);
        if (habit == null) continue;
        await _scheduleStoredNotification(
          notification: notif,
          title: '🌱 Habitude: ${habit.title}',
          body: 'C\'est l\'heure de votre habitude quotidienne !',
          payload: 'habit|${habit.idHabit}',
        );
        continue;
      }

      if (notif.idTask == null) continue;
      final task = await AppDatabase.isar.tasks.get(notif.idTask!);
      if (task != null) {
        await _scheduleStoredNotification(
          notification: notif,
          title: '🔔 Rappel: ${task.title}',
          body: 'Il est temps de commencer cette tâche !',
          payload: 'task|${task.idTasks}',
        );
      }
    }
  }

  Future<void> _scheduleStoredNotification({
    required notif_model.Notification notification,
    required String title,
    required String body,
    required String payload,
  }) async {
    await _scheduleNotification(
      id: notification.idNotif,
      title: title,
      body: body,
      scheduledTime: notification.remindAt,
      payload: payload,
    );
  }

  Future<void> handleNotificationsEnabledChange(bool enabled) async {
    if (enabled) {
      await rescheduleAllActiveNotifications();
    } else {
      await cancelAllNotifications();
      await _notifRepo.disableAllNotifications();
    }
  }

  Future<void> cleanupOldNotifications() async {
    final now = DateTime.now();
    final notifications = await _notifRepo.getAllNotifications();

    for (final notif in notifications) {
      if (notif.remindAt.isBefore(now) || !notif.enabled) {
        await _notifRepo.deleteNotification(notif.idNotif);
        await cancelNotification(notif.idNotif, logCancellation: false);
      }
    }
    print('🧹 Nettoyage des notifications terminé');
  }

  Future<void> scheduleTaskWithSettings({
    required Task task,
    required int minutesBefore,
  }) async {
    final taskStartTime = task.startTime;
    if (taskStartTime == null) return;
    final remindAt = taskStartTime.subtract(Duration(minutes: minutesBefore));
    await scheduleTaskReminder(
      task.idTasks,
      task.title,
      task.description,
      remindAt,
    );
  }

  Future<void> scheduleHabitWithSettings({
    required Habit habit,
    required List<int> daysOfWeek,
    required TimeOfDay reminderTime,
  }) async {
    final existingNotifications = await _notifRepo.getNotificationsForHabit(
      habit.idHabit,
    );
    for (final notification in existingNotifications) {
      await cancelNotification(notification.idNotif, logCancellation: false);
    }
    await _notifRepo.deleteNotificationsForHabit(habit.idHabit);

    for (final day in daysOfWeek) {
      final now = DateTime.now();
      final nextDate = _getNextDateForDay(day, now);
      final scheduledTime = DateTime(
        nextDate.year,
        nextDate.month,
        nextDate.day,
        reminderTime.hour,
        reminderTime.minute,
      );

          await scheduleHabitReminder(habit.idHabit, habit.title, scheduledTime);
    }
  }

  Future<List<notif_model.Notification>> getNotificationsForHabit(int habitId) {
    return _notifRepo.getNotificationsForHabit(habitId);
  }

  DateTime _getNextDateForDay(int dayOfWeek, DateTime from) {
    var date = DateTime(from.year, from.month, from.day);
    while (date.weekday != dayOfWeek) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}
