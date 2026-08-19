// lib/repositories/status_repository.dart
import 'package:isar/isar.dart';
import '../database/app_database.dart';
import '../models/status.dart';
import '../models/task.dart';

class StatusRepository {
  Future<List<Status>> getAllStatus() async {
    return await AppDatabase.isar.status.where().findAll();
  }

  Future<Status?> getStatusById(int id) async {
    return await AppDatabase.isar.status.get(id);
  }

  Future<void> saveStatus(Status status) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.status.put(status);
    });
  }

  Future<void> updateStatus(Status status) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.status.put(status);
    });
  }

  Future<void> deleteStatus(int id) async {
    await AppDatabase.isar.writeTxn(() async {
      final tasksCount = await AppDatabase.isar.tasks
          .filter()
          .idStatusEqualTo(id)
          .count();
      
      if (tasksCount > 0) {
        throw Exception('Ce statut est utilisé par $tasksCount tâche(s)');
      }
      
      await AppDatabase.isar.status.delete(id);
    });
  }

  Future<Status?> getStatusByName(String name) async {
    return await AppDatabase.isar.status
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();
  }

  Future<void> createDefaultStatus() async {
    final count = await AppDatabase.isar.status.count();
    if (count > 0) return;
    
    final defaultStatus = [
      {'name': 'À faire', 'color': 0xFF2196F3},
      {'name': 'En cours', 'color': 0xFFFF9800},
      {'name': 'Terminé', 'color': 0xFF4CAF50},
    ];
    
    await AppDatabase.isar.writeTxn(() async {
      for (var data in defaultStatus) {
        final status = Status()
          ..name = data['name'] as String
          ..color = data['color'] as int;
        await AppDatabase.isar.status.put(status);
      }
    });
  }
}