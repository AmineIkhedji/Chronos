import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id idTasks = Isar.autoIncrement;

  late String title;
  late String description;

  late DateTime date;
  late DateTime startTime;
  late DateTime endTime;

  late int color;

  late int idCategory;
  late int idPriority;
  late int idStatus;
}