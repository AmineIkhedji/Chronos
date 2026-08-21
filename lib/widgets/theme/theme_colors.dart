// lib/widgets/theme/theme_colors.dart
class ThemeColors {
  // ============ COULEURS DU THÈME ============
  
  // Mode clair
  static const int lightBackground = 0xFFF8FAFC;
  static const int lightText = 0xFF1E293B;
  
  // Mode sombre
  static const int darkBackground = 0xFF0F172A;
  static const int darkText = 0xFFF8FAFC;
  
  // Couleurs au choix de l'utilisateur
  static const Map<String, int> userColors = {
    'blue': 0xFF4F7CFF,
    'purple': 0xFF8B5CF6,
    'green': 0xFF22C55E,
    'orange': 0xFFF59E0B,
    'red': 0xFFEF4444,
  };
  
  // Valeurs par défaut
  static const int defaultPrimary = 0xFF4F7CFF; // Bleu par défaut
}