// lib/models/settings.dart
import 'package:isar/isar.dart';

part 'settings.g.dart';

@collection
class Settings {
  Id idSettings = Isar.autoIncrement;

  late bool darkMode;
  late int firstDayWeek;
  late bool notificationsEnabled;
  
  // 🆕 Couleurs personnalisables
  late int primaryColor;      // Couleur principale (boutons, en-têtes)
  late int secondaryColor;    // Couleur secondaire (éléments secondaires)
  late int accentColor;       // Couleur d'accentuation (surlignages)
  late int backgroundColor;   // Couleur de fond
  late int surfaceColor;      // Couleur des cartes/surfaces
}