import 'package:isar_community/isar.dart';

part 'settings.g.dart';

@collection
class Settings {
  Id idSettings = Isar.autoIncrement;
  
  bool darkMode = false;
  int firstDayWeek = 1;
  bool notificationsEnabled = true;
  int primaryColor = 0xFF4F7CFF;
  int secondaryColor = 0xFF03DAC6;
  int accentColor = 0xFFFF6D00;
  int backgroundColor = 0xFFFFFFFF;
  int surfaceColor = 0xFFF5F5F5;
}