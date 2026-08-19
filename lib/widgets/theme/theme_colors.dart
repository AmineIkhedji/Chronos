// lib/widgets/theme/theme_colors.dart
import 'package:flutter/material.dart';

class ThemeColors {
  // ============ COULEURS PAR DÉFAUT (si pas de paramètres) ============
  
  static const int defaultPrimary = 0xFF6200EE;
  static const int defaultSecondary = 0xFF03DAC6;
  static const int defaultAccent = 0xFFFF6D00;
  static const int defaultBackground = 0xFFFFFFFF;
  static const int defaultSurface = 0xFFF5F5F5;
  
  static const int darkPrimary = 0xFFBB86FC;
  static const int darkSecondary = 0xFF03DAC6;
  static const int darkAccent = 0xFFFF6D00;
  static const int darkBackground = 0xFF121212;
  static const int darkSurface = 0xFF1E1E1E;

  // ============ COULEURS SPÉCIFIQUES ============
  
  // Statuts
  static const Color statusTodo = Color(0xFF2196F3);
  static const Color statusInProgress = Color(0xFFFF9800);
  static const Color statusDone = Color(0xFF4CAF50);
  
  // Priorités
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityHigh = Color(0xFFF44336);
  
  // Catégories par défaut (si pas de couleur définie)
  static const List<Color> defaultCategoryColors = [
    Color(0xFF4CAF50), // Travail
    Color(0xFF2196F3), // Personnel
    Color(0xFFFF9800), // Maison
    Color(0xFFF44336), // Sport
    Color(0xFF9C27B0), // Études
  ];
}