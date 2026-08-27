// lib/utils/priority_colors.dart
import 'package:flutter/material.dart';

class PriorityColors {
  static const Color low = Color(0xFF4F7CFF);
  static const Color medium = Color(0xFFF59E0B);
  static const Color high = Color(0xFFEF4444);

  static Color getColor(int priorityId) {
    switch (priorityId) {
      case 1:
        return low;
      case 3:
        return high;
      default:
        return medium;
    }
  }

  static String getLabel(int priorityId) {
    switch (priorityId) {
      case 1:
        return 'Basse';
      case 3:
        return 'Haute';
      default:
        return 'Moyenne';
    }
  }
}
