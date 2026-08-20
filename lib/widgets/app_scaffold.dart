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
  });

  final Widget child;
  final bool showBottomNav;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      // ✅ LA CORRECTION ICI : On utilise la couleur du thème actuel
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      
      // ✅ SafeArea toujours actif (gère la barre de statut proprement)
      body: SafeArea(
        child: child,
      ),
      floatingActionButton: null, // FAB géré dans la bottom nav
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: showBottomNav 
          ? const ChronosBottomNavigationBar() 
          : null,
    );
  }
}