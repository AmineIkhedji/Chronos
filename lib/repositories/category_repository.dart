// lib/repositories/category_repository.dart
import 'package:isar_community/isar.dart';
import '../database/app_database.dart';
import '../models/category.dart';
import '../models/task.dart';

class CategoryRepository {
  Future<List<Category>> getAllCategories() async {
    return await AppDatabase.isar.categorys.where().findAll();
  }

  Future<Category?> getCategoryById(int id) async {
    return await AppDatabase.isar.categorys.get(id);
  }

  Future<void> saveCategory(Category category) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.categorys.put(category);
    });
  }

  Future<void> updateCategory(Category category) async {
    await AppDatabase.isar.writeTxn(() async {
      await AppDatabase.isar.categorys.put(category);
    });
  }

  Future<void> deleteCategory(int id) async {
    await AppDatabase.isar.writeTxn(() async {
      final tasksCount = await AppDatabase.isar.tasks
          .filter()
          .idCategoryEqualTo(id)
          .count();

      if (tasksCount > 0) {
        throw Exception(
          'Cette catégorie est utilisée par $tasksCount tâche(s)',
        );
      }

      await AppDatabase.isar.categorys.delete(id);
    });
  }

  Future<Category?> getCategoryByName(String name) async {
    return await AppDatabase.isar.categorys
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();
  }

  Future<void> createDefaultCategories() async {
    final count = await AppDatabase.isar.categorys.count();
    if (count > 0) return;

    final defaultCategories = [
      {'name': 'Travail', 'color': 0xFF4CAF50, 'icon': 'work'},
      {'name': 'Personnel', 'color': 0xFF2196F3, 'icon': 'person'},
      {'name': 'Maison', 'color': 0xFFFF9800, 'icon': 'home'},
      {'name': 'Sport', 'color': 0xFFF44336, 'icon': 'fitness_center'},
      {'name': 'Études', 'color': 0xFF9C27B0, 'icon': 'school'},
    ];

    await AppDatabase.isar.writeTxn(() async {
      for (var data in defaultCategories) {
        final category = Category()
          ..name = data['name'] as String
          ..color = data['color'] as int
          ..icon = data['icon'] as String;
        await AppDatabase.isar.categorys.put(category);
      }
    });
  }
}
