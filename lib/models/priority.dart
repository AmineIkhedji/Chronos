import 'package:isar/isar.dart';

part 'priority.g.dart';

@collection
class Priority {
  Id idPriorities = Isar.autoIncrement;

  late String name;

  late int color;
}