// lib/repositories/habit_repository.dart
import 'package:isar_community/isar.dart';
import '../database/app_database.dart';
import '../models/habit.dart';
import '../models/days.dart';
import '../models/task.dart';

class HabitRepository {
  // ============ CRUD DE BASE ============
  
  Future<List<Habit>> getAllHabits() async {
    return await AppDatabase.isar.habits.where().findAll();
  }

  Future<Habit?> getHabitById(int id) async {
    return await AppDatabase.isar.habits.get(id);
  }

  Future<Map<Habit, Task>?> getHabitWithTask(int habitId) async {
    final habit = await getHabitById(habitId);
    if (habit == null) return null;
    
    final task = await AppDatabase.isar.tasks.get(habit.idTasks);
    if (task == null) return null;
    
    return {habit: task};
  }

  Future<void> saveHabit(Habit habit) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.habits.put(habit);
    });
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
      
      // Supprimer les anciens jours
        await AppDatabase.isar.days
          .filter()
          .idHabitEqualTo(habitId)
          .deleteAll();
      
      // Ajouter les nouveaux jours
      for (var day in daysOfWeek) {
        final days = Days()
          ..idHabit = habitId
          ..dayOfWeek = day;
        await AppDatabase.isar.days.put(days);
      }
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
  
  Future<List<Map<Habit, Task>>> getHabitsForToday() async {
    final now = DateTime.now();
    final today = now.weekday;
    
    final days = await AppDatabase.isar.days
        .filter()
        .dayOfWeekEqualTo(today)
        .findAll();
    
    if (days.isEmpty) return [];
    
    final List<Map<Habit, Task>> result = [];
    for (var day in days) {
      final habit = await getHabitById(day.idHabit);
      if (habit != null) {
        final task = await AppDatabase.isar.tasks.get(habit.idTasks);
        if (task != null) {
          result.add({habit: task});
        }
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

  // ✅ Récupère toutes les habitudes avec leurs tâches
  Future<List<Map<Habit, Task>>> getAllHabitsWithTasks() async {
    final habits = await getAllHabits();
    final List<Map<Habit, Task>> result = [];
    
    for (var habit in habits) {
      final task = await AppDatabase.isar.tasks.get(habit.idTasks);
      if (task != null) {
        result.add({habit: task});
      }
    }
    
    return result;
  }
}