// lib/views/habits_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../providers/repository_providers.dart';
import '../views/habit_form.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_state.dart';
import '../widgets/common/confirmation_dialog.dart';

class HabitsManagementScreen extends ConsumerWidget {
  const HabitsManagementScreen({super.key});

  static const _dayLabels = {
    1: 'Lun',
    2: 'Mar',
    3: 'Mer',
    4: 'Jeu',
    5: 'Ven',
    6: 'Sam',
    7: 'Dim',
  };

  Future<void> _openHabitForm(
    BuildContext context,
    WidgetRef ref, {
    Habit? habit,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HabitForm(habit: habit)),
    );
    ref.invalidate(allHabitsManagementProvider);
    ref.invalidate(todayHabitsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(allHabitsManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les habitudes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nouvelle habitude',
            onPressed: () => _openHabitForm(context, ref),
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habitsData) {
          if (habitsData.isEmpty) {
            return EmptyState(
              icon: Icons.bolt_rounded,
              title: 'Aucune habitude',
              message: 'Créez une habitude récurrente pour la retrouver ici.',
              actionText: 'Créer une habitude',
              onActionPressed: () => _openHabitForm(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allHabitsManagementProvider);
              await ref.read(allHabitsManagementProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: habitsData.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final habit = habitsData[index];

                return _HabitManagementTile(
                  habit: habit,
                  dayLabels: _dayLabels,
                  onTap: () => _openHabitForm(context, ref, habit: habit),
                  onDelete: () => _confirmDelete(context, ref, habit),
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (_, __) => ErrorState(
          message: 'Impossible de charger les habitudes',
          onRetry: () => ref.invalidate(allHabitsManagementProvider),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Supprimer l\'habitude',
      message: 'Voulez-vous supprimer « ${habit.title} » ?',
      confirmText: 'Supprimer',
      isDestructive: true,
    );

    if (confirmed) {
      final repo = ref.read(habitRepositoryProvider);
      await repo.deleteHabit(habit.idHabit);
      ref.invalidate(allHabitsManagementProvider);
      ref.invalidate(todayHabitsProvider);
    }
  }
}

class _HabitManagementTile extends ConsumerWidget {
  final Habit habit;
  final Map<int, String> dayLabels;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HabitManagementTile({
    required this.habit,
    required this.dayLabels,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(habitDaysProvider(habit.idHabit));
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withOpacity(0.15),
          child: Icon(Icons.bolt_rounded, color: theme.primaryColor, size: 20),
        ),
        title: Text(
          habit.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: daysAsync.when(
          data: (days) {
            if (days.isEmpty) return const Text('Aucun jour sélectionné');
            final sortedDays = List<int>.from(days)..sort();
            final label = sortedDays.map((d) => dayLabels[d] ?? '').join(' · ');
            return Text(label);
          },
          loading: () => const Text('Chargement...'),
          error: (_, __) => const Text('Erreur jours'),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}