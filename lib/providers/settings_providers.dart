// lib/providers/settings_providers.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import 'repository_providers.dart';

// Paramètres actuels
final settingsProvider = FutureProvider<Settings?>((ref) async {
  if (kIsWeb) return null;

  final repo = ref.read(settingsRepositoryProvider);
  return await repo.getSettings();
});

// Mode sombre
final darkModeProvider = FutureProvider<bool>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  return settings?.darkMode ?? false;
});

// Couleur principale
final primaryColorProvider = FutureProvider<int>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  return settings?.primaryColor ?? 0xFF6200EE;
});

// ============ ÉCRITURE ============

// Basculer le mode sombre
final toggleDarkModeProvider = FutureProvider<void>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  await repo.toggleDarkMode();
  ref.invalidate(settingsProvider);
  ref.invalidate(darkModeProvider);
});

// Changer la couleur principale
final setPrimaryColorProvider = FutureProvider.family<void, int>((ref, color) async {
  final repo = ref.read(settingsRepositoryProvider);
  await repo.setPrimaryColor(color);
  ref.invalidate(settingsProvider);
  ref.invalidate(primaryColorProvider);
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