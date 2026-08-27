// lib/widgets/dialogs/create_options_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../views/task_form.dart';
import '../../views/habit_form.dart';
import '../../providers/task_providers.dart';
import '../../providers/habit_providers.dart';

class CreateOptionsDialog extends ConsumerWidget {
  const CreateOptionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Créer un élément',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Nouvelle tâche
            _buildCreateOption(
              context: context,
              ref: ref,
              icon: LucideIcons.plus,
              iconColor: theme.primaryColor,
              iconBgColor: theme.primaryColor.withOpacity(0.1),
              title: 'Nouvelle tâche',
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TaskForm()),
                );
                invalidateTaskProviders(ref);
              },
            ),
            const SizedBox(height: 12),

            // Nouvelle habitude
            _buildCreateOption(
              context: context,
              ref: ref,
              icon: LucideIcons.bolt,
              iconColor: Colors.orange,
              iconBgColor: Colors.orange.withOpacity(0.1),
              title: 'Nouvelle habitude',
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HabitForm()),
                );
                ref.invalidate(todayHabitsProvider);
                ref.invalidate(allHabitsManagementProvider);
                invalidateTaskProviders(ref);
              },
            ),

            const SizedBox(height: 20),

            // Bouton Annuler
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: theme.dividerColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
