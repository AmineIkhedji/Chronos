import 'package:isar_community/isar.dart';

part 'habit.g.dart';

@collection
class Habit {
  Id idHabit = Isar.autoIncrement;

  String title = '';
  String description = '';
  int color = 0xFF4F7CFF;
}