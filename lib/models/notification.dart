import 'package:isar/isar.dart';

part 'notification.g.dart';

@collection
class Notification {
  Id idNotif = Isar.autoIncrement;

  late DateTime remindAt;

  late bool enabled;

  late int idTasks;
}