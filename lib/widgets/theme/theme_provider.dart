// lib/widgets/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/initialization_service.dart';
import '../../repositories/settings_repository.dart';
import 'theme_colors.dart';

// ============ STATE PROVIDERS (Source unique pour l'UI) ============

// Mode sombre ou clair (état UI)
final darkModeProvider = StateProvider<bool>((ref) {
  return false; // Par défaut : mode clair
});

// Couleur principale choisie par l'utilisateur (état UI)
final userColorProvider = StateProvider<String>((ref) {
  return 'blue'; // Par défaut : bleu
});

// ============ SERVICE POUR CHARGER LES PARAMÈTRES ============

// Ce provider charge les données depuis la base et met à jour les providers UI
final loadThemeProvider = FutureProvider<void>((ref) async {
  await ref.watch(appInitializationProvider.future);
  final repo = SettingsRepository();
  final settings = await repo.getSettings();

  if (settings != null) {
    // Déterminer quelle couleur est utilisée
    String selectedColor = 'blue';
    for (final entry in ThemeColors.userColors.entries) {
      if (entry.value == settings.primaryColor) {
        selectedColor = entry.key;
        break;
      }
    }

    ref.read(userColorProvider.notifier).state = selectedColor;
    ref.read(darkModeProvider.notifier).state = settings.darkMode;
  }
});

// ============ FONCTION POUR CRÉER LE THÈME ============

ThemeData buildTheme(WidgetRef ref) {
  final isDark = ref.watch(darkModeProvider);
  final colorKey = ref.watch(userColorProvider);
  final primaryColor = Color(
    ThemeColors.userColors[colorKey] ?? ThemeColors.defaultPrimary,
  );

  final backgroundColor = isDark
      ? const Color(ThemeColors.darkBackground)
      : const Color(ThemeColors.lightBackground);

  final textColor = isDark
      ? const Color(ThemeColors.darkText)
      : const Color(ThemeColors.lightText);

  final textColorSecondary = isDark
      ? const Color(0xFF94A3B8)
      : const Color(0xFF64748B);

  final surfaceColor = isDark
      ? const Color(0xFF1E293B)
      : const Color(0xFFFFFFFF);

  final borderColor = isDark
      ? const Color(0xFF334155)
      : const Color(0xFFE2E8F0);

  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: surfaceColor,
    dividerColor: borderColor,

    // ============ COLOR SCHEME ============
    colorScheme: ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      secondary: primaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: const Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textColor,
      onBackground: textColor,
      onError: Colors.white,
      tertiary: primaryColor.withOpacity(0.8),
    ),

    // ============ APP BAR ============
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textColor),
    ),

    // ============ BOUTONS ============
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // ============ INPUT ============
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: textColorSecondary),
      floatingLabelStyle: TextStyle(color: primaryColor),
      hintStyle: TextStyle(color: textColorSecondary),
    ),

    // ============ CARD ============
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor.withOpacity(0.5)),
      ),
    ),

    // ============ TEXTES ============
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
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
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColorSecondary, fontSize: 14),
      labelLarge: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // ============ CHIP ============
    chipTheme: ChipThemeData(
      backgroundColor: isDark
          ? const Color(0xFF1E293B)
          : const Color(0xFFF1F5F9),
      labelStyle: TextStyle(color: textColor),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // ============ SWITCH ============
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      }),
    ),

    // ============ DIVIDER ============
    dividerTheme: DividerThemeData(color: borderColor, thickness: 1, space: 0),

    // ============ ICON ============
    iconTheme: IconThemeData(color: textColor, size: 24),

    // ============ BOTTOM NAVIGATION ============
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textColorSecondary,
      elevation: 8,
    ),
  );
}
