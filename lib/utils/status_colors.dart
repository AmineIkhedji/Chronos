// lib/utils/status_colors.dart
import 'package:flutter/material.dart';

class StatusColors {
  static const Color todo = Color(0xFF2196F3);
  static const Color inProgress = Color(0xFFFF9800);
  static const Color completed = Color(0xFF4CAF50);

  static Color getColor(int statusId) {
    switch (statusId) {
      case 3:
        return completed;
      case 2:
        return inProgress;
      default:
        return todo;
    }
  }

  static String getLabel(int statusId) {
    switch (statusId) {
      case 3:
        return 'Terminé';
      case 2:
        return 'En cours';
      default:
        return 'À faire';
    }
  }
}
