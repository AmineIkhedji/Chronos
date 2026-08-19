// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/app_database.dart';
import 'widgets/theme/theme_provider.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'widgets/common/custom_app_bar.dart';
import 'widgets/common/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await AppDatabase.init();
  }
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

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

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
      child: Center(
        child: Text(
          '${selectedTab.label} - À venir',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}