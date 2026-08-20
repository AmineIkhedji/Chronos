import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/theme_provider.dart';

class HomeGreeting extends ConsumerWidget {
  const HomeGreeting({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    return 'Bonsoir';
  }

  String _getEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    return '🌙';
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final textColor = theme.colorScheme.onBackground;
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting()}, Amine ${_getEmoji()}',
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
          style: TextStyle(
            color: textColorSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
