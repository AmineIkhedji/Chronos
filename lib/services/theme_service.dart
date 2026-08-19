// lib/services/theme_service.dart
import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

class ThemeService {
  final SettingsRepository _settingsRepo = SettingsRepository();

  /// Récupère le thème actuel
  Future<ThemeData> getTheme() async {
    final settings = await _settingsRepo.getSettings();
    
    if (settings == null) {
      return ThemeData.light();
    }

    final isDark = settings.darkMode;
    
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: Color(settings.primaryColor),
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: Color(settings.primaryColor),
        secondary: Color(settings.secondaryColor),
        surface: Color(settings.surfaceColor),
        background: Color(settings.backgroundColor),
        error: Colors.red,
        onPrimary: isDark ? Colors.white : Colors.white,
        onSecondary: isDark ? Colors.white : Colors.black,
        onSurface: isDark ? Colors.white : Colors.black,
        onBackground: isDark ? Colors.white : Colors.black,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: Color(settings.backgroundColor),
      cardColor: Color(settings.surfaceColor),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(settings.primaryColor),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(settings.primaryColor),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(settings.primaryColor),
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(settings.primaryColor)),
        ),
      ),
    );
  }

  /// Change le thème et retourne le nouveau ThemeData
  Future<ThemeData> toggleTheme() async {
    await _settingsRepo.toggleDarkMode();
    return await getTheme();
  }

  /// Change une couleur et retourne le nouveau ThemeData
  Future<ThemeData> updateColor(String colorType, int color) async {
    switch (colorType) {
      case 'primary':
        await _settingsRepo.setPrimaryColor(color);
        break;
      case 'secondary':
        await _settingsRepo.setSecondaryColor(color);
        break;
      case 'accent':
        await _settingsRepo.setAccentColor(color);
        break;
      case 'background':
        await _settingsRepo.setBackgroundColor(color);
        break;
      case 'surface':
        await _settingsRepo.setSurfaceColor(color);
        break;
    }
    return await getTheme();
  }
}