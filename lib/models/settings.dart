import 'package:isar/isar.dart';

part 'settings.g.dart';

@collection
class Settings {
  Id idSettings = Isar.autoIncrement;

  late bool darkMode;

  late int firstDayWeek;

  late bool notificationsEnabled;
}