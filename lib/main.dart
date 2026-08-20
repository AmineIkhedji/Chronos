// lib/main.dart (CORRIGÉ AVEC L'IMPORT MANQUANT)
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'database/app_database.dart';
import 'widgets/theme/theme_provider.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'widgets/common/custom_app_bar.dart'; // <--- AJOUT IMPORTANT ICI
import 'widgets/common/loading_indicator.dart';
import 'views/home_screen.dart';
import 'views/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    await AppDatabase.init();
  }
  
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loadThemeProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadThemeProvider).isLoading;

    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: LoadingIndicator(message: 'Chargement...'),
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
        content = Center(
          child: Text(
            'Calendrier',
            style: TextStyle(color: theme.colorScheme.onBackground),
          ),
        );
        title = 'Calendrier';
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

    // ✅ UN SEUL AppScaffold, avec AppBar SEULEMENT si nécessaire
    // HomeScreen et SettingsScreen gèrent eux-mêmes leur header
    final showAppBar = selectedTab != AppTab.home && selectedTab != AppTab.settings;

    return AppScaffold(
      // ✅ Pas de AppBar pour Home et Settings (ils ont leur propre header)
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