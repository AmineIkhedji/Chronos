// lib/services/initialization_service.dart
import '../repositories/category_repository.dart';
import '../repositories/priority_repository.dart';
import '../repositories/status_repository.dart';
import '../repositories/settings_repository.dart';

class InitializationService {
  static Future<void> initializeDefaultData() async {
    final categoryRepo = CategoryRepository();
    final priorityRepo = PriorityRepository();
    final statusRepo = StatusRepository();
    final settingsRepo = SettingsRepository();
    
    await categoryRepo.createDefaultCategories();
    await priorityRepo.createDefaultPriorities();
    await statusRepo.createDefaultStatus();
    await settingsRepo.createDefaultSettings();
  }
}