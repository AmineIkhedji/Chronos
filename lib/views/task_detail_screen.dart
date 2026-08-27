// lib/views/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../models/status.dart';
import '../providers/task_providers.dart';
import '../providers/repository_providers.dart';
import '../utils/date_formatters.dart';
import '../widgets/task/priority_badge.dart';
import '../widgets/task/status_badge.dart';
import '../widgets/task/task_info_row.dart';
import '../widgets/common/confirmation_dialog.dart';
import '../widgets/common/custom_snackbar.dart';
import 'task_form.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskByIdProvider(task.idTasks));

    return taskAsync.when(
      data: (currentTask) {
        if (currentTask == null) {
          return const Scaffold(body: Center(child: Text('Tâche introuvable')));
        }
        return _buildDetails(context, ref, currentTask);
      },
      loading: () => _buildSkeleton(context),
      error: (_, _) => const Scaffold(
        body: Center(child: Text('Erreur de chargement de la tâche')),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, WidgetRef ref, Task task) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final toggleCompletion = ref.read(toggleTaskCompletionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la tâche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Modifier',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskForm(task: task)),
              );
              invalidateTaskProviders(ref);
              ref.invalidate(taskByIdProvider(task.idTasks));
              await ref.read(taskByIdProvider(task.idTasks).future);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Supprimer',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============ STATUT / PRIORITÉ ============
            Wrap(
              spacing: 8,
              children: [
                StatusBadge(statusId: task.idStatus),
                PriorityBadge(priorityId: task.idPriority),
              ],
            ),
            const SizedBox(height: 20),

            // ============ TITRE ============
            Text(
              task.title,
              style: TextStyle(
                color: textColor.withValues(
                  alpha: task.isCompleted ? 0.5 : 1.0,
                ),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // ============ DESCRIPTION ============
            if (task.description.isNotEmpty) ...[
              Text(
                'Description',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  task.description,
                  style: TextStyle(
                    color: textColor.withValues(
                      alpha: task.isCompleted ? 0.5 : 1.0,
                    ),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ============ INFORMATIONS ============
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  TaskInfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: DateFormatters.formatFullDate(task.date),
                  ),

                  if (task.startTime != null)
                    TaskInfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Heure de début',
                      value: DateFormatters.formatTime(task.startTime),
                    ),

                  if (task.endTime != null)
                    TaskInfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Heure de fin',
                      value: DateFormatters.formatTime(task.endTime),
                    ),

                  if (task.startTime == null && task.endTime == null)
                    const TaskInfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Heures',
                      value: 'Toute la journée',
                    ),

                  _buildCategoryInfoRow(context, ref, task.idCategory),
                  _buildPriorityInfoRow(context, ref, task.idPriority),
                  _buildStatusInfoRow(context, ref, task.idStatus),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ============ RAPPELS ============
            if (!task.isCompleted) ...[
              Text(
                'Rappels',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildRemindersSection(context, ref, task),
            ],

            const SizedBox(height: 24),

            // ============ BOUTON COCHER TERMINER (EN BAS) ============
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? Colors.green.withValues(alpha: 0.15)
                    : cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: task.isCompleted
                      ? Colors.green.withValues(alpha: 0.5)
                      : borderColor.withValues(alpha: 0.5),
                ),
              ),
              child: InkWell(
                onTap: () => toggleCompletion(task),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: task.isCompleted
                                ? Colors.green
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                            width: 2,
                          ),
                          color: task.isCompleted
                              ? Colors.green
                              : Colors.transparent,
                        ),
                        child: task.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.isCompleted
                                  ? 'Tâche terminée'
                                  : 'Marquer comme terminée',
                              style: TextStyle(
                                color: task.isCompleted
                                    ? Colors.green
                                    : textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task.isCompleted
                                  ? 'Vous avez accompli cette tâche !'
                                  : 'Cochez pour indiquer que la tâche est accomplie',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final color = Theme.of(context).dividerColor.withValues(alpha: 0.2);

    Widget block(double height, {double? width}) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la tâche')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            block(24, width: 150),
            const SizedBox(height: 24),
            block(30, width: 260),
            const SizedBox(height: 16),
            block(100),
            const SizedBox(height: 20),
            block(180),
          ],
        ),
      ),
    );
  }

  // ============ MÉTHODES D'AFFICHAGE DES RELATIONS ============

  Widget _buildCategoryInfoRow(
    BuildContext context,
    WidgetRef ref,
    int categoryId,
  ) {
    final categoryRepo = ref.read(categoryRepositoryProvider);

    return FutureBuilder<Category?>(
      future: categoryRepo.getCategoryById(categoryId),
      builder: (context, snapshot) {
        final categoryName = snapshot.data?.name ?? 'Catégorie inconnue';
        return TaskInfoRow(
          icon: Icons.category_rounded,
          label: 'Catégorie',
          value: categoryName,
        );
      },
    );
  }

  Widget _buildPriorityInfoRow(
    BuildContext context,
    WidgetRef ref,
    int priorityId,
  ) {
    final priorityRepo = ref.read(priorityRepositoryProvider);

    return FutureBuilder<Priority?>(
      future: priorityRepo.getPriorityById(priorityId),
      builder: (context, snapshot) {
        final priorityName = snapshot.data?.name ?? 'Priorité inconnue';
        return TaskInfoRow(
          icon: Icons.flag_rounded,
          label: 'Priorité',
          value: priorityName,
        );
      },
    );
  }

  Widget _buildStatusInfoRow(
    BuildContext context,
    WidgetRef ref,
    int statusId,
  ) {
    final statusRepo = ref.read(statusRepositoryProvider);

    return FutureBuilder<Status?>(
      future: statusRepo.getStatusById(statusId),
      builder: (context, snapshot) {
        final statusName = snapshot.data?.name ?? 'Statut inconnu';
        return TaskInfoRow(
          icon: Icons.check_circle_rounded,
          label: 'Statut',
          value: statusName,
        );
      },
    );
  }

  // ============ RAPPELS ============

  Widget _buildRemindersSection(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) {
    final notificationsProvider = ref.watch(
      notificationsForTaskProvider(task.idTasks),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: notificationsProvider.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Row(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Text(
                  'Aucun rappel actif',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: notifications.map((notif) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Rappel le ${DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(notif.remindAt)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      onPressed: () async {
                        final controller = ref.read(taskControllerProvider);
                        await controller.cancelAllReminders(task.idTasks);
                        ref.invalidate(
                          notificationsForTaskProvider(task.idTasks),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Text(
          'Erreur de chargement',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  // ============ SUPPRESSION ============

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Supprimer la tâche',
      message: 'Voulez-vous supprimer « ${task.title} » ?',
      confirmText: 'Supprimer',
      isDestructive: true,
    );

    if (confirmed) {
      try {
        final controller = ref.read(taskControllerProvider);
        await controller.deleteTask(task.idTasks);

        invalidateTaskProviders(ref);

        if (context.mounted) {
          Navigator.pop(context);
          CustomSnackbar.success(context, 'Tâche supprimée');
        }
      } catch (e) {
        if (context.mounted) {
          CustomSnackbar.error(context, 'Erreur : ${e.toString()}');
        }
      }
    }
  }
}
