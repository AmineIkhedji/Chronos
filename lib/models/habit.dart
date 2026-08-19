import 'package:isar/isar.dart';

part 'habit.g.dart';

@collection
class Habit {
  Id idHabit = Isar.autoIncrement;
  
  late int idTasks;
}