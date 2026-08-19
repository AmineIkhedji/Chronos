import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:chronos/models/task.dart';
import 'package:chronos/models/event.dart';
import 'package:chronos/models/habit.dart';
import 'package:chronos/models/days.dart';
import 'package:chronos/models/notification.dart';
import 'package:chronos/models/category.dart';
import 'package:chronos/models/priority.dart';
import 'package:chronos/models/status.dart';
import 'package:chronos/models/settings.dart';
class AppDatabase {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [
        TaskSchema,
        EventSchema,
        HabitSchema,
        DaysSchema,
        NotificationSchema,
        CategorySchema,
        PrioritySchema,
        StatusSchema,
        SettingsSchema,
      ],
      directory: dir.path,
    );
  }
}