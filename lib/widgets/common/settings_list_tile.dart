// lib/widgets/common/settings_list_tile.dart
import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? leadingIconColor;
  final Color? iconBgColor;

  const SettingsListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.leadingIconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final neutralIconBg = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);
    final neutralIconColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF475569);
    final effectiveIconColor = leadingIconColor ?? neutralIconColor;
    final effectiveBgColor =
        iconBgColor ?? leadingIconColor?.withOpacity(0.15) ?? neutralIconBg;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: effectiveBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(leadingIcon, color: effectiveIconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
