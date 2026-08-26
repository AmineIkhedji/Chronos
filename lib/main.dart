// lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'views/splash_screen.dart';
import 'services/notification_service.dart';
import 'widgets/theme/theme_provider.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'widgets/common/custom_app_bar.dart';
import 'views/home_screen.dart';
import 'views/settings_screen.dart';
import 'views/calendrier_screen.dart';
import 'views/stats_screen.dart';
import 'providers/settings_providers.dart';
import 'repositories/settings_repository.dart';
import 'services/user_profile_service.dart';
import 'widgets/dialogs/user_name_dialog.dart';

Future<void> _initializeBackgroundServices() async {
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermissions();
    await notificationService.cleanupOldNotifications();
    await notificationService.rescheduleAllActiveNotifications();
  } catch (error, stackTrace) {
    debugPrint('Initialisation des notifications échouée: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const ProviderScope(child: ChronosApp()));
}

class ChronosApp extends ConsumerStatefulWidget {
  const ChronosApp({super.key});

  @override
  ConsumerState<ChronosApp> createState() => _ChronosAppState();
}

class _ChronosAppState extends ConsumerState<ChronosApp> {
  @override
  void initState() {
    super.initState();
    // Les services non bloquants peuvent démarrer pendant le splash.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) {
        unawaited(_initializeBackgroundServices());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadThemeProvider);

    final themeData = buildTheme(ref);

    return MaterialApp(
      title: 'Chronos',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: SplashScreen(nextPageBuilder: (_) => const HomePage()),
    );
  }
}

// ============ PAGE D'ACCUEIL (CONTENEUR UNIQUE) ============

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _tabs = AppTab.values;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (mounted) await _requestUserName();
    });
  }

  Future<void> _requestUserName() async {
    final settingsRepository = SettingsRepository();
    final userName = kIsWeb
        ? await UserProfileService.getUserName()
        : await settingsRepository.getUserName();
    if (!mounted) return;
    ref.read(userNameProvider.notifier).state = userName;
    if (userName != null) return;

    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UserNameDialog(),
    );

    if (name == null || name.trim().isEmpty) return;
    if (kIsWeb) {
      await UserProfileService.saveUserName(name);
    } else {
      await settingsRepository.setUserName(name);
    }
    if (mounted) ref.read(userNameProvider.notifier).state = name.trim();
  }

  Future<void> _moveToTab(AppTab tab) async {
    if (ref.read(navigationLoadingProvider)) return;
    await navigateToTab(ref, tab);
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isLoading = ref.watch(navigationLoadingProvider);

    // Contenu différent selon l'onglet sélectionné
    Widget content;
    String title;

    switch (selectedTab) {
      case AppTab.home:
        content = const HomeScreen();
        title = ''; // Pas de titre, HomeScreen gère son propre header
        break;
      case AppTab.calendar:
        content = const CalendrierScreen();
        title = ''; // CalendrierScreen gère son propre header
        break;
      case AppTab.stats:
        content = const StatsScreen();
        title = 'Statistiques';
        break;
      case AppTab.settings:
        content = const SettingsScreen();
        title = ''; // SettingsScreen gère son propre header
        break;
    }

    // AppBar seulement pour les pages qui n'ont pas leur propre header
    final showAppBar = selectedTab == AppTab.stats;

    return AppScaffold(
      appBar: showAppBar ? CustomAppBar(title: title) : null,
      child: GestureDetector(
        onHorizontalDragEnd: isLoading
            ? null
            : (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity.abs() < 250) return;

                final currentIndex = _tabs.indexOf(selectedTab);
                final nextIndex = velocity < 0
                    ? currentIndex + 1
                    : currentIndex - 1;
                if (nextIndex >= 0 && nextIndex < _tabs.length) {
                  _moveToTab(_tabs[nextIndex]);
                }
              },
        child: IgnorePointer(
          // Pendant le remplacement du contenu par le squelette de
          // chargement, on ignore les pointeurs le temps d'une frame pour
          // éviter qu'un doigt encore posé sur l'écran ne hit-teste un
          // RenderBox en cours de destruction/layout ("Cannot hit test a
          // render box with no size").
          ignoring: isLoading,
          child: isLoading
              ? const _NavigationSkeleton()
              : KeyedSubtree(key: ValueKey(selectedTab), child: content),
        ),
      ),
    );
  }
}

class _NavigationSkeleton extends StatelessWidget {
  const _NavigationSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).dividerColor.withOpacity(0.2);

    Widget block(double height, {double? width}) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          block(22, width: 180),
          const SizedBox(height: 20),
          block(110),
          const SizedBox(height: 20),
          block(180),
          const SizedBox(height: 20),
          block(120),
        ],
      ),
    );
  }
}
