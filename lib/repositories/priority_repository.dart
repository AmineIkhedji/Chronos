// lib/repositories/priority_repository.dart
import 'package:isar_community/isar.dart';
import '../database/app_database.dart';
import '../models/priority.dart';
import '../models/task.dart';

class PriorityRepository {
  Future<List<Priority>> getAllPriorities() async {
    return await AppDatabase.isar.prioritys.where().findAll();
  }

  Future<Priority?> getPriorityById(int id) async {
    return await AppDatabase.isar.prioritys.get(id);
  }

  Future<void> savePriority(Priority priority) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.prioritys.put(priority);
    });
  }

  Future<void> updatePriority(Priority priority) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.prioritys.put(priority);
    });
  }

  Future<void> deletePriority(int id) async {
    await AppDatabase.isar.writeTxn(() async {
      final tasksCount = await AppDatabase.isar.tasks
          .filter()
          .idPriorityEqualTo(id)
          .count();
      
      if (tasksCount > 0) {
        throw Exception('Cette priorité est utilisée par $tasksCount tâche(s)');
      }
      
      await AppDatabase.isar.prioritys.delete(id);
    });
  }

  Future<void> createDefaultPriorities() async {
    final count = await AppDatabase.isar.prioritys.count();
    if (count > 0) return;
    
    final defaultPriorities = [
      {'name': 'Basse', 'color': 0xFF4CAF50},
      {'name': 'Moyenne', 'color': 0xFFFF9800},
      {'name': 'Haute', 'color': 0xFFF44336},
    ];
    
    await AppDatabase.isar.writeTxn(() async {
      for (var data in defaultPriorities) {
        final priority = Priority()
          ..name = data['name'] as String
          ..color = data['color'] as int;
        await AppDatabase.isar.prioritys.put(priority);
      }
    });
  }
}