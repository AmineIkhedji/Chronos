// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- AJOUTER CET IMPORT
import 'database/app_database.dart';
import 'widgets/theme/theme_provider.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'widgets/common/custom_app_bar.dart';
import 'widgets/common/loading_indicator.dart';
import 'views/home_screen.dart'; // Si vous avez créé la vue

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser la base de données
  if (!kIsWeb) {
    await AppDatabase.init();
  }
  
  // Initialiser les locales pour le formatage des dates (FR)
  await initializeDateFormatting('fr_FR', null); // <--- AJOUTER CETTE LIGNE
  
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
    // Charger les paramètres au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loadThemeProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isLoading = ref.watch(loadThemeProvider).isLoading;

    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: LoadingIndicator(message: 'Chargement...'),
        ),
      );
    }

    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && 
         MediaQuery.of(context).platformBrightness == Brightness.dark);

    final themeData = buildTheme(ref, isDark: isDark);

    return MaterialApp(
      title: 'Chronos',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}

// ============ PAGE D'ACCUEIL (temporaire) ============

// lib/main.dart - Mise à jour de la HomePage
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    // On affiche HomeScreen par défaut quand on est sur l'onglet Home
    if (selectedTab == AppTab.home) {
      return const HomeScreen();
    }

    // Contenu différent selon l'onglet sélectionné
    Widget content;
    switch (selectedTab) {
      case AppTab.home:
        content = const Center(child: Text('Accueil'));
        break;
      case AppTab.calendar:
        content = const Center(child: Text('Calendrier'));
        break;
      case AppTab.stats:
        content = const Center(child: Text('Statistiques'));
        break;
      case AppTab.settings:
        content = const Center(child: Text('Paramètres'));
        break;
    }

    return AppScaffold(
      appBar: CustomAppBar(
        title: 'Chronos',
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // TODO: Recherche
            },
          ),
        ],
      ),
      child: content,
    );
  }
}