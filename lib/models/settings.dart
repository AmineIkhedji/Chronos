import 'package:isar_community/isar.dart';

part 'settings.g.dart';

@collection
class Settings {
  Id idSettings = Isar.autoIncrement;
  
  late bool darkMode;
  late int firstDayWeek;
  late bool notificationsEnabled;
  late int primaryColor;
  late int secondaryColor;
  late int accentColor;
  late int backgroundColor;
  late int surfaceColor;
}