// lib/views/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import '../providers/calendar_providers.dart';
import '../widgets/theme/theme_provider.dart';
import '../widgets/theme/theme_colors.dart';
import '../widgets/stats/progress_circle.dart';
import '../widgets/stats/weekly_chart.dart';
import '../widgets/stats/daily_progress_bar.dart';
import '../widgets/common/error_state.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final userColor = ref.watch(userColorProvider);
    final primaryColor = Color(
      ThemeColors.userColors[userColor] ?? ThemeColors.defaultPrimary,
    );

    final textColor = theme.colorScheme.onBackground;
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final cardColor = theme.cardColor;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    // Providers pour les statistiques
    final globalStatsAsync = ref.watch(globalStatisticsProvider);
    final weeklyStatsAsync = ref.watch(weeklyStatisticsProvider);
    final todayStatsAsync = ref.watch(todayDetailedStatsProvider);
    final firstDayOfWeekAsync = ref.watch(firstDayOfWeekProvider);

    final isLoading =
        globalStatsAsync.isLoading ||
        weeklyStatsAsync.isLoading ||
        todayStatsAsync.isLoading ||
        firstDayOfWeekAsync.isLoading;

    if (isLoading) {
      return _buildLoadingScreen(
        context: context,
        cardColor: cardColor,
        borderColor: borderColor,
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(globalStatisticsProvider);
          ref.invalidate(weeklyStatisticsProvider);
          ref.invalidate(todayDetailedStatsProvider);
          await Future.wait([
            ref.read(globalStatisticsProvider.future),
            ref.read(weeklyStatisticsProvider.future),
            ref.read(todayDetailedStatsProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ SECTION GLOBALE ============
              globalStatsAsync.when(
                data: (stats) {
                  return _buildGlobalStatsCard(
                    context: context,
                    stats: stats,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    textColorSecondary: textColorSecondary,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  );
                },
                loading: () => _buildSkeletonCard(
                  height: 250,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                error: (_, __) => ErrorState(
                  message: 'Impossible de charger les statistiques globales',
                  onRetry: () => ref.invalidate(globalStatisticsProvider),
                ),
              ),

              const SizedBox(height: 24),

              // ============ SECTION PROGRESSION HEBDOMADAIRE ============
              Text(
                'Progression hebdomadaire',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              firstDayOfWeekAsync.when(
                data: (firstDay) {
                  return weeklyStatsAsync.when(
                    data: (weeklyStats) {
                      return _buildWeeklyChartCard(
                        context: context,
                        data: weeklyStats,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        textColorSecondary: textColorSecondary,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        firstDayOfWeek: firstDay,
                      );
                    },
                    loading: () => _buildSkeletonCard(
                      height: 200,
                      cardColor: cardColor,
                      borderColor: borderColor,
                    ),
                    error: (_, __) => ErrorState(
                      message:
                          'Impossible de charger la progression hebdomadaire',
                      onRetry: () => ref.invalidate(weeklyStatisticsProvider),
                    ),
                  );
                },
                loading: () => _buildSkeletonCard(
                  height: 200,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                error: (_, __) => _buildSkeletonCard(
                  height: 200,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ),

              const SizedBox(height: 24),

              // ============ SECTION PROGRESSION QUOTIDIENNE ============
              Text(
                'Progression quotidienne',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              todayStatsAsync.when(
                data: (todayStats) {
                  return _buildDailyProgressCard(
                    context: context,
                    stats: todayStats,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    textColorSecondary: textColorSecondary,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  );
                },
                loading: () => _buildSkeletonCard(
                  height: 100,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                error: (_, __) => ErrorState(
                  message: 'Impossible de charger les statistiques du jour',
                  onRetry: () => ref.invalidate(todayDetailedStatsProvider),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ============ CARTE STATS GLOBALES ============

  Widget _buildGlobalStatsCard({
    required BuildContext context,
    required GlobalStatistics stats,
    required Color primaryColor,
    required Color textColor,
    required Color textColorSecondary,
    required Color cardColor,
    required Color borderColor,
  }) {
    final successRate = stats.successRate;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          // Cercle de progression
          Row(
            children: [
              ProgressCircle(
                progress: successRate / 100,
                size: 90,
                color: primaryColor,
                centerChild: Text(
                  '${successRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${successRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Taux de réussite',
                      style: TextStyle(color: textColorSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Séparateur
          Divider(color: borderColor.withOpacity(0.5), height: 1),

          const SizedBox(height: 20),

          // Trois colonnes de statistiques
          Row(
            children: [
              _buildStatItem(
                value: stats.completed,
                label: 'Terminées',
                color: Colors.green,
                textColor: textColor,
                textColorSecondary: textColorSecondary,
              ),
              _buildVerticalDivider(borderColor),
              _buildStatItem(
                value: stats.remaining,
                label: 'Restantes',
                color: primaryColor,
                textColor: textColor,
                textColorSecondary: textColorSecondary,
              ),
              _buildVerticalDivider(borderColor),
              _buildStatItem(
                value: stats.late,
                label: 'En retard',
                color: Colors.red,
                textColor: textColor,
                textColorSecondary: textColorSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required int value,
    required String label,
    required Color color,
    required Color textColor,
    required Color textColorSecondary,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: textColorSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(Color borderColor) {
    return Container(width: 1, height: 40, color: borderColor.withOpacity(0.5));
  }

  // ============ CARTE GRAPHE HEBDOMADAIRE ============

  Widget _buildWeeklyChartCard({
    required BuildContext context,
    required Map<DateTime, int> data,
    required Color primaryColor,
    required Color textColor,
    required Color textColorSecondary,
    required Color cardColor,
    required Color borderColor,
    required int firstDayOfWeek,
  }) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: WeeklyChart(
        data: data,
        barColor: primaryColor,
        textColor: textColor,
        textColorSecondary: textColorSecondary,
        firstDayOfWeek: firstDayOfWeek,
      ),
    );
  }

  // ============ CARTE PROGRESSION QUOTIDIENNE ============

  Widget _buildDailyProgressCard({
    required BuildContext context,
    required TodayStats stats,
    required Color primaryColor,
    required Color textColor,
    required Color textColorSecondary,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: DailyProgressBar(
        progress: stats.total > 0 ? stats.completed / stats.total : 0.0,
        color: primaryColor,
        trackColor: primaryColor.withOpacity(0.15),
        label: '${stats.completed} sur ${stats.total} tâches',
        percentageLabel: '${stats.successRate.toStringAsFixed(0)}%',
      ),
    );
  }

  // ============ SKELETON LOADER ============

  Widget _buildSkeletonCard({
    required double height,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBlock(width: double.infinity, height: 16),
          const SizedBox(height: 12),
          const _SkeletonBlock(width: double.infinity, height: 12),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen({
    required BuildContext context,
    required Color cardColor,
    required Color borderColor,
  }) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkeletonCard(
              height: 250,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 24),
            const _SkeletonBlock(width: 220, height: 18),
            const SizedBox(height: 12),
            _buildSkeletonCard(
              height: 220,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 24),
            const _SkeletonBlock(width: 190, height: 18),
            const SizedBox(height: 12),
            _buildSkeletonCard(
              height: 100,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.22),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
