// lib/widgets/home/home_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/task_providers.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

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
      // Essayer avec le français
      final formatter = DateFormat('EEEE d MMMM', 'fr_FR');
      return formatter.format(now);
    } catch (e) {
      // Fallback en anglais si la locale échoue
      final formatter = DateFormat('EEEE d MMMM', 'en_US');
      return formatter.format(now);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Salutation
        Text(
          '${_getGreeting()}, Alex ${_getEmoji()}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Aujourd'hui",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _getFormattedDate(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),

        // Cartes Stats
        statsAsync.when(
          data: (stats) {
            final total = stats['total'] as int? ?? 0;
            final completed = stats['completed'] as int? ?? 0;
            final remaining = total - completed;
            final successRate = (stats['successRate'] as num?)?.toDouble() ?? 0.0;

            return Row(
              children: [
                // Carte Gauche (Tâches)
                Expanded(
                  child: _buildStatCard(
                    title: '$remaining',
                    subtitle: 'Tâches aujourd\'hui',
                    color: const Color(0xFF5B8DEF), // Bleu
                  ),
                ),
                const SizedBox(width: 12),
                // Carte Droite (Pourcentage)
                Expanded(
                  child: _buildStatCard(
                    title: '${successRate.toStringAsFixed(0)}%',
                    subtitle: 'Réussite semaine',
                    color: const Color(0xFF9B59B6), // Violet
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Erreur stats')),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}