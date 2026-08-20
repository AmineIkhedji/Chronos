// lib/providers/settings_providers.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import 'repository_providers.dart';
import '../widgets/theme/theme_provider.dart';

// ============ LECTURE (GET) ============

// Paramètres actuels depuis la base de données
final settingsProvider = FutureProvider<Settings?>((ref) async {
  if (kIsWeb) return null;

  final repo = ref.read(settingsRepositoryProvider);
  return await repo.getSettings();
});

// ============ ÉCRITURE (POST/PUT) ============

// Basculer le mode sombre (écriture en base + rafraîchissement UI)
final toggleDarkModeProvider = FutureProvider<void>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  await repo.toggleDarkMode();
  
  // Rafraîchir les données brutes
  ref.invalidate(settingsProvider);
  // Rafraîchir l'UI du thème (provoque un rebuild de toute l'app)
  ref.invalidate(loadThemeProvider);
});

// Changer la couleur principale
final setPrimaryColorProvider = FutureProvider.family<void, int>((ref, color) async {
  final repo = ref.read(settingsRepositoryProvider);
  await repo.setPrimaryColor(color);
  
  ref.invalidate(settingsProvider);
  ref.invalidate(loadThemeProvider);
});

// Changer le premier jour de la semaine
final setFirstDayWeekProvider = FutureProvider.family<void, int>((ref, day) async {
  final repo = ref.read(settingsRepositoryProvider);
  await repo.setFirstDayOfWeek(day);
  ref.invalidate(settingsProvider);
});

// Basculer les notifications
final toggleNotificationsProvider = FutureProvider<void>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  await repo.toggleNotifications();
  ref.invalidate(settingsProvider);
});