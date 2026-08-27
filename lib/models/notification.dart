import 'package:isar_community/isar.dart';

part 'notification.g.dart';

@collection
class Notification {
  Id idNotif = Isar.autoIncrement;

  late DateTime remindAt;
  late bool enabled;
  int? idTask;
  int? idHabit;
}
