import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';
import '../models/habit.dart';
import '../models/notification.dart' as notif_model;
import '../models/task.dart';
import '../repositories/notification_repository.dart';
import '../repositories/settings_repository.dart';
import 'notification_message_catalog.dart';
import 'notification_message_selector.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final SettingsRepository _settingsRepo = SettingsRepository();
  final NotificationRepository _notifRepo = NotificationRepository();
  final NotificationMessageSelector _messageSelector =
      NotificationMessageSelector();

  static const _channelId = 'chronos_notifications';
  static const _channelName = 'Rappels Chronos';
  static const _channelDescription =
      'Notifications pour vos tâches et habitudes';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    tz.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    if (!kIsWeb) await _createNotificationChannel();
    _isInitialized = true;
  }

  Future<void> _createNotificationChannel() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
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

  void _onNotificationTap(NotificationResponse response) {}

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final plugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (plugin == null) return false;
      final notificationsGranted =
          await plugin.requestNotificationsPermission() ?? false;
      final exactAlarmsGranted =
          await plugin.requestExactAlarmsPermission() ?? false;
      return notificationsGranted && exactAlarmsGranted;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  Future<bool> areNotificationsEnabled() async {
    final settings = await _settingsRepo.getSettings();
    return settings?.notificationsEnabled ?? true;
  }

  Future<void> scheduleTaskReminder(
    int taskId,
    String title,
    String description,
    DateTime remindAt,
  ) async {
    if (!await areNotificationsEnabled() || remindAt.isBefore(DateTime.now())) {
      return;
    }
    final existing = await _notifRepo.getNotificationsForTask(taskId);
    for (final notification in existing) {
      await cancelNotification(notification.idNotif, logCancellation: false);
    }
    await _notifRepo.deleteNotificationsForTask(taskId);
    final id = await _getNextAvailableId();
    await _notifRepo.saveNotification(
      notif_model.Notification()
        ..idNotif = id
        ..idTask = taskId
        ..remindAt = remindAt
        ..enabled = true,
    );
    await _scheduleNotification(
      id: id,
      title: _messageSelector.title(
        NotificationMessageCatalog.taskTitles,
        title,
      ),
      body: _messageSelector.message(
        NotificationMessageCatalog.taskReminderMessages,
      ),
      scheduledTime: remindAt,
      payload: 'task|$taskId',
    );
  }

  Future<void> scheduleHabitReminder(
    int habitId,
    String title,
    DateTime scheduledTime,
  ) async {
    if (!await areNotificationsEnabled() ||
      scheduledTime.isBefore(DateTime.now())) {
      return;
    }
    final id = await _getNextAvailableId();
    await _notifRepo.saveNotification(
      notif_model.Notification()
        ..idNotif = id
        ..idHabit = habitId
        ..remindAt = scheduledTime
        ..enabled = true,
    );
    await _scheduleNotification(
      id: id,
      title: _messageSelector.title(
        NotificationMessageCatalog.habitTitles,
        title,
      ),
      body: _messageSelector.message(
        NotificationMessageCatalog.habitReminderMessages,
      ),
      scheduledTime: scheduledTime,
      payload: 'habit|$habitId',
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime.toLocal(), tz.local);
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
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

  Future<void> showTaskCompletedNotification(String taskTitle) async {
    if (kIsWeb || !await areNotificationsEnabled()) return;
    await initialize();
    final id = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _notifications.show(
      id,
      _messageSelector.title(
        NotificationMessageCatalog.completionTitles,
        taskTitle,
      ),
      '$taskTitle : ${_messageSelector.message(NotificationMessageCatalog.completionMessages)}',
      details,
      payload: 'task-completed',
    );
  }

  Future<void> showMotivationalNotification() async {
    if (kIsWeb || !await areNotificationsEnabled()) return;
    await initialize();
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      'Motivation',
      _messageSelector.message(NotificationMessageCatalog.motivationalMessages),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      payload: 'motivational',
    );
  }

  Future<void> cancelNotification(int id, {bool logCancellation = true}) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() => _notifications.cancelAll();

  Future<void> rescheduleAllActiveNotifications() async {
    if (!await areNotificationsEnabled()) {
      await cancelAllNotifications();
      return;
    }
    final notifications = await _notifRepo.getEnabledNotifications();
    await _notifications.cancelAll();
    for (final notification in notifications) {
      if (notification.remindAt.isBefore(DateTime.now())) {
        await _notifRepo.deleteNotification(notification.idNotif);
        continue;
      }
      if (notification.idHabit != null) {
        final habit = await AppDatabase.isar.habits.get(notification.idHabit!);
        if (habit == null) continue;
        await _scheduleStoredNotification(
          notification,
          _messageSelector.title(
            NotificationMessageCatalog.habitTitles,
            habit.title,
          ),
          _messageSelector.message(
            NotificationMessageCatalog.habitReminderMessages,
          ),
          'habit|${habit.idHabit}',
        );
      } else if (notification.idTask != null) {
        final task = await AppDatabase.isar.tasks.get(notification.idTask!);
        if (task == null) continue;
        await _scheduleStoredNotification(
          notification,
          _messageSelector.title(
            NotificationMessageCatalog.taskTitles,
            task.title,
          ),
          _messageSelector.message(
            NotificationMessageCatalog.taskReminderMessages,
          ),
          'task|${task.idTasks}',
        );
      }
    }
  }

  Future<void> _scheduleStoredNotification(
    notif_model.Notification notification,
    String title,
    String body,
    String payload,
  ) => _scheduleNotification(
    id: notification.idNotif,
    title: title,
    body: body,
    scheduledTime: notification.remindAt,
    payload: payload,
  );

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
    for (final notification in await _notifRepo.getAllNotifications()) {
      if (notification.remindAt.isBefore(now) || !notification.enabled) {
        await _notifRepo.deleteNotification(notification.idNotif);
        await cancelNotification(notification.idNotif, logCancellation: false);
      }
    }
  }

  Future<void> scheduleTaskWithSettings({
    required Task task,
    required int minutesBefore,
  }) async {
    if (task.startTime == null) return;
    await scheduleTaskReminder(
      task.idTasks,
      task.title,
      task.description,
      task.startTime!.subtract(Duration(minutes: minutesBefore)),
    );
  }

  Future<void> scheduleHabitWithSettings({
    required Habit habit,
    required List<int> daysOfWeek,
    required TimeOfDay reminderTime,
  }) async {
    for (final notification in await _notifRepo.getNotificationsForHabit(
      habit.idHabit,
    )) {
      await cancelNotification(notification.idNotif, logCancellation: false);
    }
    await _notifRepo.deleteNotificationsForHabit(habit.idHabit);
    for (final day in daysOfWeek) {
      final nextDate = _getNextDateForDay(day, DateTime.now());
      await scheduleHabitReminder(
        habit.idHabit,
        habit.title,
        DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
          reminderTime.hour,
          reminderTime.minute,
        ),
      );
    }
  }

  Future<List<notif_model.Notification>> getNotificationsForHabit(
    int habitId,
  ) => _notifRepo.getNotificationsForHabit(habitId);

  Future<int> _getNextAvailableId() async {
    final notifications = await _notifRepo.getAllNotifications();
    if (notifications.isEmpty) return 1;
    final maxId = notifications.fold<int>(
      0,
      (max, item) => item.idNotif > max ? item.idNotif : max,
    );
    return maxId < 2147483647 ? maxId + 1 : 1;
  }

  DateTime _getNextDateForDay(int dayOfWeek, DateTime from) {
    var date = DateTime(from.year, from.month, from.day);
    while (date.weekday != dayOfWeek) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}
