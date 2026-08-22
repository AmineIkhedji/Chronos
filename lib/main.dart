// lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'database/app_database.dart';
import 'services/initialization_service.dart';
import 'services/notification_service.dart';
import 'widgets/theme/theme_provider.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'widgets/common/custom_app_bar.dart';
import 'widgets/common/loading_indicator.dart';
import 'views/home_screen.dart';
import 'views/settings_screen.dart';
import 'views/calendrier_screen.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    // Initialiser la base de données
    await AppDatabase.init();

    // Initialiser les données par défaut
    await InitializationService.initializeDefaultData();
  }

  // Initialiser le formatage des dates pour le français
  await initializeDateFormatting('fr_FR', null);
  
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
    // Charger le thème après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loadThemeProvider);
      if (!kIsWeb) {
        unawaited(_initializeBackgroundServices());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadThemeProvider).isLoading;

    // Afficher un écran de chargement pendant le chargement du thème
    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: LoadingIndicator(message: 'Chargement des paramètres...'),
        ),
      );
    }

    final themeData = buildTheme(ref);

    return MaterialApp(
      title: 'Chronos',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const HomePage(),
    );
  }
}

// ============ PAGE D'ACCUEIL (CONTENEUR UNIQUE) ============

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final theme = Theme.of(context);

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
        content = Center(
          child: Text(
            'Statistiques',
            style: TextStyle(color: theme.colorScheme.onBackground),
          ),
        );
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
      appBar: showAppBar 
        ? CustomAppBar(
            title: title,
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () {},
              ),
            ],
          )
        : null,
      child: content,
    );
  }
}