import 'package:isar_community/isar.dart';

part 'event.g.dart';

@collection
class Event {
  Id idEvent = Isar.autoIncrement;
  
  late int idTasks;
}