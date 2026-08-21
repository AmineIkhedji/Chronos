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
import '../repositories/category_repository.dart';
import '../repositories/priority_repository.dart';
import '../repositories/status_repository.dart';
import 'task_form.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final textSecondary = theme.colorScheme.onBackground.withOpacity(0.6);
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final primaryColor = theme.primaryColor;

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
                _buildBadge(
                  context,
                  task.isCompleted ? 'Terminé' : 'En cours',
                  task.isCompleted ? Colors.green : Colors.orange,
                ),
                _buildBadge(
                  context,
                  _getPriorityLabel(task.idPriority),
                  _getPriorityColor(task.idPriority),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ============ TITRE ============
            Text(
              task.title,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
                  border: Border.all(color: borderColor.withOpacity(0.5)),
                ),
                child: Text(
                  task.description,
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.5),
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
                border: Border.all(color: borderColor.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    Icons.calendar_today_rounded,
                    'Date',
                    DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(task.date),
                  ),
                  
                  if (task.startTime != null)
                    _buildInfoRow(
                      context,
                      Icons.access_time_rounded,
                      'Heure de début',
                      task.formatStartTime(),
                    ),
                  
                  if (task.endTime != null)
                    _buildInfoRow(
                      context,
                      Icons.access_time_rounded,
                      'Heure de fin',
                      task.formatEndTime(),
                    ),
                  
                  if (task.startTime == null && task.endTime == null)
                    _buildInfoRow(
                      context,
                      Icons.access_time_rounded,
                      'Heures',
                      'Toute la journée',
                    ),
                  
                  // Charger le nom de la catégorie
                  _buildCategoryInfoRow(context, ref, task.idCategory),
                  
                  // Charger le nom de la priorité
                  _buildPriorityInfoRow(context, ref, task.idPriority),
                  
                  // Charger le nom du statut
                  _buildStatusInfoRow(context, ref, task.idStatus),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ============ RAPPELS ============
            if (task.idStatus != 3) ...[
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
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour charger et afficher le nom de la catégorie
  Widget _buildCategoryInfoRow(BuildContext context, WidgetRef ref, int categoryId) {
    final categoryRepo = ref.read(categoryRepositoryProvider);
    
    return FutureBuilder<Category?>(
      future: categoryRepo.getCategoryById(categoryId),
      builder: (context, snapshot) {
        final categoryName = snapshot.data?.name ?? 'Catégorie inconnue';
        return _buildInfoRow(
          context,
          Icons.category_rounded,
          'Catégorie',
          categoryName,
        );
      },
    );
  }

  // Nouvelle méthode pour charger et afficher le nom de la priorité
  Widget _buildPriorityInfoRow(BuildContext context, WidgetRef ref, int priorityId) {
    final priorityRepo = ref.read(priorityRepositoryProvider);
    
    return FutureBuilder<Priority?>(
      future: priorityRepo.getPriorityById(priorityId),
      builder: (context, snapshot) {
        final priorityName = snapshot.data?.name ?? 'Priorité inconnue';
        return _buildInfoRow(
          context,
          Icons.flag_rounded,
          'Priorité',
          priorityName,
        );
      },
    );
  }

  // Nouvelle méthode pour charger et afficher le nom du statut
  Widget _buildStatusInfoRow(BuildContext context, WidgetRef ref, int statusId) {
    final statusRepo = ref.read(statusRepositoryProvider);
    
    return FutureBuilder<Status?>(
      future: statusRepo.getStatusById(statusId),
      builder: (context, snapshot) {
        final statusName = snapshot.data?.name ?? 'Statut inconnu';
        return _buildInfoRow(
          context,
          Icons.check_circle_rounded,
          'Statut',
          statusName,
        );
      },
    );
  }

  // Nouvelle méthode pour afficher les rappels
  Widget _buildRemindersSection(BuildContext context, WidgetRef ref, Task task) {
    final notificationsProvider = ref.watch(notificationsForTaskProvider(task.idTasks));
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: notificationsProvider.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Row(
              children: [
                Icon(Icons.notifications_none_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 12),
                Text(
                  'Aucun rappel actif',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
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
                    Icon(Icons.notifications_active_rounded, color: Theme.of(context).primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Rappel le ${DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(notif.remindAt)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      onPressed: () async {
                        final controller = ref.read(taskControllerProvider);
                        await controller.cancelAllReminders(task.idTasks);
                        ref.invalidate(notificationsForTaskProvider(task.idTasks));
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Text(
          'Erreur de chargement',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final textSecondary = theme.colorScheme.onBackground.withOpacity(0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primaryColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getPriorityLabel(int priorityId) {
    switch (priorityId) {
      case 1: return 'Basse';
      case 2: return 'Moyenne';
      case 3: return 'Haute';
      default: return 'Moyenne';
    }
  }

  Color _getPriorityColor(int priorityId) {
    switch (priorityId) {
      case 1: return const Color(0xFF4F7CFF);
      case 2: return const Color(0xFFF59E0B);
      case 3: return const Color(0xFFEF4444);
      default: return const Color(0xFFF59E0B);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: Text('Voulez-vous supprimer « ${task.title} » ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final controller = ref.read(taskControllerProvider);
        await controller.deleteTask(task.idTasks);
        
        invalidateTaskProviders(ref);
        
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Tâche supprimée'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}