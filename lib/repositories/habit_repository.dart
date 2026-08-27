// lib/repositories/habit_repository.dart
import 'package:isar_community/isar.dart';
import '../database/app_database.dart';
import '../models/habit.dart';
import '../models/days.dart';

class HabitRepository {
  // ============ CRUD DE BASE ============

  Future<List<Habit>> getAllHabits() async {
    return await AppDatabase.isar.habits.where().findAll();
  }

  Future<Habit?> getHabitById(int id) async {
    return await AppDatabase.isar.habits.get(id);
  }

  Future<void> saveHabit(Habit habit) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.habits.put(habit);
    });
  }

  Future<void> saveHabitWithDays(Habit habit, List<int> daysOfWeek) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.habits.put(habit);
      await AppDatabase.isar.days
          .filter()
          .idHabitEqualTo(habit.idHabit)
          .deleteAll();
      await _saveDays(habit.idHabit, daysOfWeek);
    });
  }

  Future<void> _saveDays(int habitId, List<int> daysOfWeek) async {
    for (final day in daysOfWeek) {
      final habitDay = Days()
        ..idHabit = habitId
        ..dayOfWeek = day;
      await AppDatabase.isar.days.put(habitDay);
    }
  }

  Future<void> deleteHabit(int id) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.days.filter().idHabitEqualTo(id).deleteAll();
      await AppDatabase.isar.habits.delete(id);
    });
  }

  // ============ GESTION DES JOURS ============

  Future<void> addDaysToHabit(int habitId, List<int> daysOfWeek) async {
    await AppDatabase.isar.writeTxn(() async {
      final habit = await getHabitById(habitId);
      if (habit == null) throw Exception('Habitude non trouvée');

      await AppDatabase.isar.days.filter().idHabitEqualTo(habitId).deleteAll();
      await _saveDays(habitId, daysOfWeek);
    });
  }

  Future<List<int>> getDaysForHabit(int habitId) async {
    final habit = await getHabitById(habitId);
    if (habit == null) return [];

    final days = await AppDatabase.isar.days
        .filter()
        .idHabitEqualTo(habitId)
        .findAll();
    return days.map((d) => d.dayOfWeek).toList();
  }

  Future<bool> isHabitForDay(int habitId, int dayOfWeek) async {
    final habit = await getHabitById(habitId);
    if (habit == null) return false;

    final days = await AppDatabase.isar.days
        .filter()
        .idHabitEqualTo(habitId)
        .dayOfWeekEqualTo(dayOfWeek)
        .findAll();

    return days.isNotEmpty;
  }

  // ============ RECHERCHES SPÉCIFIQUES ============

  Future<List<Habit>> getHabitsForToday() async {
    final now = DateTime.now();
    final today = now.weekday;

    final days = await AppDatabase.isar.days
        .filter()
        .dayOfWeekEqualTo(today)
        .findAll();

    if (days.isEmpty) return [];

    final List<Habit> result = [];
    for (var day in days) {
      final habit = await getHabitById(day.idHabit);
      if (habit != null) {
        result.add(habit);
      }
    }

    return result;
  }

  Future<List<Habit>> getHabitsForDay(int dayOfWeek) async {
    final days = await AppDatabase.isar.days
        .filter()
        .dayOfWeekEqualTo(dayOfWeek)
        .findAll();

    if (days.isEmpty) return [];

    final List<Habit> habits = [];
    for (var day in days) {
      final habit = await getHabitById(day.idHabit);
      if (habit != null) {
        habits.add(habit);
      }
    }

    return habits;
  }

  Future<List<Habit>> getDailyHabits() async {
    final allHabits = await getAllHabits();
    final dailyHabits = <Habit>[];

    for (var habit in allHabits) {
      final days = await getDaysForHabit(habit.idHabit);
      if (days.length == 7) {
        dailyHabits.add(habit);
      }
    }

    return dailyHabits;
  }
}
