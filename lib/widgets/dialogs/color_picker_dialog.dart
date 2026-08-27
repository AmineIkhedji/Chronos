// lib/widgets/dialogs/color_picker_dialog.dart
import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color currentColor;

  const ColorPickerDialog({super.key, required this.currentColor});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisir une couleur',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sélectionnez la couleur principale de l\'application',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ThemeColors.userColors.entries.map((entry) {
                final color = Color(entry.value);
                final isSelected = color == _selectedColor;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedColor = color);
                    Navigator.pop(context, entry.value);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 32,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
