// lib/widgets/common/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.titleFontSize = 20,
    this.toolbarHeight = kToolbarHeight,
    this.titleSpacing,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool centerTitle;

  /// Si non fourni, retombe sur le fond du thème (scaffoldBackgroundColor) —
  /// c'est ce qui rend le header "minimaliste" et transparent visuellement,
  /// tout en respectant automatiquement le dark/light mode.
  final Color? backgroundColor;

  /// Si non fourni, retombe sur la couleur de texte du thème (onBackground),
  /// qui change automatiquement selon dark/light mode.
  final Color? foregroundColor;

  final double elevation;
  final double titleFontSize;
  final double toolbarHeight;
  final double? titleSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // ============ MINIMALISTE ============
    // Avant : fond plein primaryColor + texte blanc (look "bandeau coloré").
    // Maintenant : fond = fond du thème, texte/icônes = couleur de texte
    // du thème → épuré, et 100% synchro avec dark/light mode.
    final bgColor = backgroundColor ?? theme.scaffoldBackgroundColor;
    final fgColor = foregroundColor ?? theme.colorScheme.onSurface;

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      title: Text(
        title,
        style: TextStyle(
          color: fgColor,
          fontSize: titleFontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      leading:
          leading ??
          (showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: fgColor,
                    size: 22,
                  ),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null),
      iconTheme: IconThemeData(color: fgColor, size: 22),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
