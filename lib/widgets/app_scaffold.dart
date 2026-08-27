// lib/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bottom_navigation_bar.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.showBottomNav = true,
    this.appBar,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.padding,
  });

  final Widget child;
  final bool showBottomNav;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      // ============ IMPORTANT POUR LE GLASSMORPHISM ============
      // extendBody: true fait passer le contenu SOUS la bottom nav bar.
      // C'est indispensable pour que le BackdropFilter (flou) de la navbar
      // ait réellement quelque chose à flouter en transparence, sinon
      // l'effet "verre" ne fait que montrer une couleur semi-transparente
      // sur un fond uni, sans profondeur.
      extendBody: showBottomNav,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      body: SafeArea(
        // bottom: false pour laisser le contenu défiler derrière la navbar
        // translucide (sinon SafeArea ajoute un padding qui annule l'effet).
        bottom: !showBottomNav,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(0),
          child: child,
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? const ChronosBottomNavigationBar()
          : null,
    );
  }
}
