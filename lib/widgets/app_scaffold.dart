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
    this.showFab = true,
    this.onFabPressed,
  });

  final Widget child;
  final bool showBottomNav;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;
  final bool showFab;
  final VoidCallback? onFabPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Le FAB est maintenant intégré dans la bottom navigation bar
    // On le désactive ici pour éviter le doublon
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: child,
      floatingActionButton: null, // Désactivé car intégré dans la barre
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: showBottomNav 
          ? const ChronosBottomNavigationBar() 
          : null,
    );
  }
}