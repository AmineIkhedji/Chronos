// lib/widgets/forms/color_selector.dart
import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final int selectedColor;
  final ValueChanged<int> onColorSelected;
  final List<int> colors;

  const ColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.colors = const [
      0xFF4F7CFF, // Bleu
      0xFF22C55E, // Vert
      0xFFF59E0B, // Orange
      0xFFEF4444, // Rouge
      0xFFA855F7, // Violet
      0xFF06B6D4, // Cyan
      0xFFEC4899, // Rose
      0xFF84CC16, // Lime
    ],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = selectedColor == color;
        return InkWell(
          onTap: () => onColorSelected(color),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(color),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(color).withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
