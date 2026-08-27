// lib/services/initialization_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../database/app_database.dart';
import '../repositories/category_repository.dart';
import '../repositories/priority_repository.dart';
import '../repositories/status_repository.dart';
import '../repositories/settings_repository.dart';
import 'user_profile_service.dart';

final appInitializationProvider = FutureProvider<void>((ref) async {
  await InitializationService.initializeApp();
});

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

    final settings = await settingsRepo.getSettings();
    if (settings != null && settings.userName.trim().isEmpty) {
      final legacyUserName = await UserProfileService.getUserName();
      if (legacyUserName != null) {
        await settingsRepo.setUserName(legacyUserName);
      }
    }
  }

  static Future<void> initializeApp() async {
    if (!kIsWeb) {
      await AppDatabase.init();
      await initializeDefaultData();
    }

    await initializeDateFormatting('fr_FR', null);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
