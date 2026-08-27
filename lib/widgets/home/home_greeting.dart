import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/theme_provider.dart';
import '../../providers/settings_providers.dart';

class HomeGreeting extends ConsumerStatefulWidget {
  const HomeGreeting({super.key});

  @override
  ConsumerState<HomeGreeting> createState() => _HomeGreetingState();
}

class _HomeGreetingState extends ConsumerState<HomeGreeting> {
  late final int _greetingIndex;
  late final String _emoji;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _greetingIndex = random.nextInt(3);
    final emojis = switch (DateTime.now().hour) {
      < 7 => ['😴', '💤', '🛏️'],
      < 12 => ['☀️', '🌞', '🌅'],
      < 16 => ['🥐', '📖', '🤓'],
      _ => ['🌉', '🌚', '✨'],
    };
    _emoji = emojis[random.nextInt(emojis.length)];
  }

  String _getGreeting(String? userName) {
    final hour = DateTime.now().hour;
    final phrases = switch (hour) {
      < 7 => <String>[
        'Zzz',
        userName == null ? 'Chut dors' : 'Chut $userName dors',
        userName == null
            ? 'Fais de beaux rêves'
            : 'Fais de beaux rêves $userName',
      ],
      < 12 => <String>[
        'Bonjour',
        userName == null ? 'Au travail' : 'Au travail $userName',
        userName == null
            ? 'On finit une tâche ?'
            : 'On finit une tâche $userName ?',
      ],
      < 16 => <String>[
        userName == null ? 'Bon après-midi' : 'Bon après-midi $userName',
        'Miam',
        userName == null ? 'Petite sieste ?' : 'Petite sieste $userName ?',
      ],
      _ => <String>[
        userName == null ? 'Bonsoir' : 'Bonsoir $userName',
        userName == null
            ? 'Une dernière tâche ?'
            : 'Une dernière tâche $userName ?',
        userName == null
            ? 'On se prépare pour demain ?'
            : 'On se prépare pour demain $userName ?',
      ],
    };

    return phrases[_greetingIndex];
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    try {
      return DateFormat('EEEE d MMMM', 'fr_FR').format(now);
    } catch (_) {
      return DateFormat('EEEE d MMMM', 'en_US').format(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final userName = ref.watch(userNameProvider);
    final textColor = theme.colorScheme.onSurface;
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting(userName)} $_emoji',
          style: TextStyle(
            color: textColorSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Aujourd'hui",
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _getFormattedDate(),
          style: TextStyle(color: textColorSecondary, fontSize: 14),
        ),
      ],
    );
  }
}
