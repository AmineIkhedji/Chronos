// lib/providers/repository_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/task_controller.dart';
import '../controllers/habit_controller.dart';
import '../repositories/task_repository.dart';
import '../repositories/habit_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/priority_repository.dart';
import '../repositories/status_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/settings_repository.dart';

// Providers des repositories
final taskRepositoryProvider = Provider((ref) => TaskRepository());
final habitRepositoryProvider = Provider((ref) => HabitRepository());
final categoryRepositoryProvider = Provider((ref) => CategoryRepository());
final priorityRepositoryProvider = Provider((ref) => PriorityRepository());
final statusRepositoryProvider = Provider((ref) => StatusRepository());
final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepository(),
);
final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

// Providers des contrôleurs
final taskControllerProvider = Provider((ref) => TaskController());
final habitControllerProvider = Provider((ref) => HabitController());
