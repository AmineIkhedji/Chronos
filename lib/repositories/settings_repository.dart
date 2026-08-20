// lib/repositories/settings_repository.dart
import 'package:isar_community/isar.dart';
import '../database/app_database.dart';
import '../models/settings.dart';

class SettingsRepository {
  // ============ CRUD ============
  
  Future<Settings?> getSettings() async {
    return await AppDatabase.isar.settings.where().findFirst();
  }

  Future<void> saveSettings(Settings settings) async {
    await AppDatabase.isar.writeTxn(() async {
      final existing = await getSettings();
      if (existing == null) {
        await AppDatabase.isar.settings.put(settings);
      } else {
        settings.idSettings = existing.idSettings;
        await AppDatabase.isar.settings.put(settings);
      }
    });
  }

  // ============ MODE SOMBRE/CLAIR ============
  
  Future<void> toggleDarkMode() async {
    final settings = await getSettings();
    if (settings != null) {
      settings.darkMode = !settings.darkMode;
      await saveSettings(settings);
    }
  }

  Future<void> setDarkMode(bool value) async {
    final settings = await getSettings() ?? Settings();
    settings.darkMode = value;
    await saveSettings(settings);
  }

  // ============ PREMIER JOUR DE LA SEMAINE ============
  
  Future<void> setFirstDayOfWeek(int day) async {
    final settings = await getSettings() ?? Settings();
    settings.firstDayWeek = day;
    await saveSettings(settings);
  }

  // ============ NOTIFICATIONS ============
  
  Future<void> toggleNotifications() async {
    final settings = await getSettings();
    if (settings != null) {
      settings.notificationsEnabled = !settings.notificationsEnabled;
      await saveSettings(settings);
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final settings = await getSettings() ?? Settings();
    settings.notificationsEnabled = value;
    await saveSettings(settings);
  }

  // ============ GESTION DES COULEURS ============
  
  Future<void> setPrimaryColor(int color) async {
    final settings = await getSettings() ?? Settings();
    settings.primaryColor = color;
    await saveSettings(settings);
  }

  Future<void> setSecondaryColor(int color) async {
    final settings = await getSettings() ?? Settings();
    settings.secondaryColor = color;
    await saveSettings(settings);
  }

  Future<void> setAccentColor(int color) async {
    final settings = await getSettings() ?? Settings();
    settings.accentColor = color;
    await saveSettings(settings);
  }

  Future<void> setBackgroundColor(int color) async {
    final settings = await getSettings() ?? Settings();
    settings.backgroundColor = color;
    await saveSettings(settings);
  }

  Future<void> setSurfaceColor(int color) async {
    final settings = await getSettings() ?? Settings();
    settings.surfaceColor = color;
    await saveSettings(settings);
  }

  // ============ RÉINITIALISATION DES COULEURS ============
  
  Future<void> resetColors() async {
    final settings = await getSettings();
    if (settings != null) {
      settings.primaryColor = 0xFF4F7CFF;      // Blue
      settings.secondaryColor = 0xFF03DAC6;    // Teal
      settings.accentColor = 0xFFFF6D00;       // Orange
      settings.backgroundColor = 0xFFFFFFFF;   // White
      settings.surfaceColor = 0xFFF5F5F5;      // Light Gray
      await saveSettings(settings);
    }
  }

  // ============ DONNÉES PAR DÉFAUT ============
  
  Future<void> createDefaultSettings() async {
    final exists = await getSettings() != null;
    if (exists) return;
    
    final settings = Settings()
      ..darkMode = false
      ..firstDayWeek = 1  // Lundi
      ..notificationsEnabled = true
      ..primaryColor = 0xFF4F7CFF      // Blue
      ..secondaryColor = 0xFF03DAC6    // Teal
      ..accentColor = 0xFFFF6D00       // Orange
      ..backgroundColor = 0xFFFFFFFF   // White
      ..surfaceColor = 0xFFF5F5F5;     // Light Gray
    
    await saveSettings(settings);
  }
}