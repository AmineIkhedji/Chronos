// lib/widgets/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/settings_repository.dart';
import 'theme_colors.dart';

// ============ STATE PROVIDER (pour le thème) ============

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system; // Par défaut : suit le système
});

final primaryColorProvider = StateProvider<Color>((ref) {
  return const Color(ThemeColors.defaultPrimary);
});

final secondaryColorProvider = StateProvider<Color>((ref) {
  return const Color(ThemeColors.defaultSecondary);
});

final accentColorProvider = StateProvider<Color>((ref) {
  return const Color(ThemeColors.defaultAccent);
});

final backgroundColorProvider = StateProvider<Color>((ref) {
  return const Color(ThemeColors.defaultBackground);
});

final surfaceColorProvider = StateProvider<Color>((ref) {
  return const Color(ThemeColors.defaultSurface);
});

// ============ SERVICE POUR CHARGER LES PARAMÈTRES ============

final loadThemeProvider = FutureProvider<void>((ref) async {
  final repo = SettingsRepository();
  final settings = await repo.getSettings();
  
  if (settings != null) {
    ref.read(primaryColorProvider.notifier).state = Color(settings.primaryColor);
    ref.read(secondaryColorProvider.notifier).state = Color(settings.secondaryColor);
    ref.read(accentColorProvider.notifier).state = Color(settings.accentColor);
    ref.read(backgroundColorProvider.notifier).state = Color(settings.backgroundColor);
    ref.read(surfaceColorProvider.notifier).state = Color(settings.surfaceColor);
    ref.read(themeModeProvider.notifier).state = 
        settings.darkMode ? ThemeMode.dark : ThemeMode.light;
  }
});

// ============ FONCTION POUR CRÉER LE THÈME ============

ThemeData buildTheme(WidgetRef ref, {bool isDark = false}) {
  final primary = ref.watch(primaryColorProvider);
  final secondary = ref.watch(secondaryColorProvider);
  final accent = ref.watch(accentColorProvider);
  final background = ref.watch(backgroundColorProvider);
  final surface = ref.watch(surfaceColorProvider);
  
  final brightness = isDark ? Brightness.dark : Brightness.light;
  final textColor = isDark ? Colors.white : Colors.black;
  final textColorSecondary = isDark ? Colors.grey[400] : Colors.grey[600];
  
  return ThemeData(
    brightness: brightness,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    cardColor: surface,
    dividerColor: isDark ? Colors.grey[800] : Colors.grey[300],
    
    // ============ COLOR SCHEME ============
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: primary,
      secondary: secondary,
      surface: surface,
      background: background,
      error: Colors.red,
      onPrimary: textColor,
      onSecondary: textColor,
      onSurface: textColor,
      onBackground: textColor,
      onError: Colors.white,
    ),
    
    // ============ APP BAR ============
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    
    // ============ BOUTONS ============
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    
    // ============ INPUT ============
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      labelStyle: TextStyle(color: textColorSecondary),
      floatingLabelStyle: TextStyle(color: primary),
    ),
    
    // ============ CARD ============
    cardTheme: CardThemeData(
      color: surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // ============ TEXTES ============
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textColorSecondary,
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // ============ CHIP ============
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      labelStyle: TextStyle(color: textColor),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    
    // ============ SWITCH ============
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary.withOpacity(0.5);
        }
        return null;
      }),
    ),
    
    // ============ DIVIDER ============
    dividerTheme: DividerThemeData(
      color: isDark ? Colors.grey[800] : Colors.grey[300],
      thickness: 1,
      space: 0,
    ),
  );
}