// lib/widgets/home/home_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_providers.dart';
import '../theme/theme_colors.dart';
import '../theme/theme_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);
    final theme = Theme.of(context);
    final userColor = ref.watch(userColorProvider);
    final primaryColor = Color(ThemeColors.userColors[userColor] ?? ThemeColors.defaultPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    color: primaryColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 12),
                // Carte Droite (Pourcentage)
                Expanded(
                  child: _buildStatCard(
                    title: '${successRate.toStringAsFixed(0)}%',
                    subtitle: 'Réussite semaine',
                    color: primaryColor.withOpacity(0.6),
                  ),
                ),
              ],
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: theme.primaryColor),
          ),
          error: (_, __) => Center(
            child: Text('Erreur stats', style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
          ),
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