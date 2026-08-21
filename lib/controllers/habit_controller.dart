// lib/controllers/habit_controller.dart
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';
import '../repositories/category_repository.dart';
import '../models/category.dart';
import '../services/notification_service.dart';
import '../utils/validators.dart';

class HabitController {
  final HabitRepository _habitRepo = HabitRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final NotificationService _notificationService = NotificationService();

  // ============ VALIDATIONS ============

  String? validateTitle(String? value) => Validators.validateTitle(value);

  String? validateDescription(String? value) => Validators.validateDescription(value);

  String? validateCategory(int? categoryId) => Validators.validateCategory(categoryId);

  String? validateDays(Set<int> days) => Validators.validateDays(days);

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

  // ============ CATÉGORIES ============

  Future<List<Category>> getCategories() async {
    return await _categoryRepo.getAllCategories();
  }

  // ============ RAPPELS ============

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

  Future<void> cancelAllReminders(int habitId) async {
    final notifications = await _notificationService.getNotificationsForHabit(habitId);
    for (final notif in notifications) {
      await _notificationService.cancelNotification(notif.idNotif);
    }
  }
}