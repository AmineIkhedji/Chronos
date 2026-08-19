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
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final bool showBottomNav;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: child,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNav 
          ? const ChronosBottomNavigationBar() 
          : null,
    );
  }
}