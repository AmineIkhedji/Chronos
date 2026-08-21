// lib/controllers/habit_controller.dart
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';
import '../services/notification_service.dart';

class HabitController {
  final HabitRepository _habitRepo = HabitRepository();
  final NotificationService _notificationService = NotificationService();

  // ============ VALIDATIONS ============

  /// Valide le titre (obligatoire, 3-100 caractères)
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le titre est obligatoire';
    }
    if (value.trim().length < 3) {
      return 'Le titre doit contenir au moins 3 caractères';
    }
    if (value.trim().length > 100) {
      return 'Le titre ne doit pas dépasser 100 caractères';
    }
    return null;
  }

  /// Valide la description (optionnelle, max 500 caractères)
  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > 500) {
      return 'La description ne doit pas dépasser 500 caractères';
    }
    return null;
  }

  /// Valide les jours sélectionnés (au moins un jour obligatoire)
  String? validateDays(Set<int> days) {
    if (days.isEmpty) {
      return 'Veuillez sélectionner au moins un jour';
    }
    return null;
  }

  // ============ CRUD ============

  Future<void> saveHabit(Habit habit) async {
    await _habitRepo.saveHabit(habit);
  }

  Future<void> saveHabitWithDays(Habit habit, List<int> daysOfWeek) async {
    await _habitRepo.saveHabitWithDays(habit, daysOfWeek);
  }

  Future<void> deleteHabit(int id) async {
    await _habitRepo.deleteHabit(id);
  }

  // ============ RECHERCHES ============

  Future<List<Habit>> getAllHabits() async {
    return await _habitRepo.getAllHabits();
  }

  Future<List<Habit>> getHabitsForToday() async {
    return await _habitRepo.getHabitsForToday();
  }

  Future<List<int>> getDaysForHabit(int habitId) async {
    return await _habitRepo.getDaysForHabit(habitId);
  }

  // ============ RAPPELS ============

  /// Planifie les rappels pour une habitude
  Future<void> scheduleHabitReminders({
    required Habit habit,
    required List<int> daysOfWeek,
    required TimeOfDay reminderTime,
  }) async {
    await _notificationService.scheduleHabitWithSettings(
      habit: habit,
      daysOfWeek: daysOfWeek,
      reminderTime: reminderTime,
    );
  }

  /// Supprime tous les rappels d'une habitude
  Future<void> cancelAllReminders(int habitId) async {
    final notifications = await _notificationService.getNotificationsForHabit(habitId);
    for (final notif in notifications) {
      await _notificationService.cancelNotification(notif.idNotif);
    }
  }
}