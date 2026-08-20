// lib/views/habit_form.dart (à créer)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../models/task.dart';
import '../providers/repository_providers.dart';
import '../providers/habit_providers.dart';
import '../providers/task_providers.dart';
import '../services/notification_service.dart';

class HabitForm extends ConsumerStatefulWidget {
  final Habit? habit;

  const HabitForm({super.key, this.habit});

  @override
  ConsumerState<HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends ConsumerState<HabitForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int _color = 0xFF4F7CFF;
  bool _enableReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  
  Set<int> _selectedDays = {};

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _loadHabitData(widget.habit!);
    }
  }

  Future<void> _loadHabitData(Habit habit) async {
    final habitRepo = ref.read(habitRepositoryProvider);
    final taskRepo = ref.read(taskRepositoryProvider);
    final days = await habitRepo.getDaysForHabit(habit.idHabit);

    final task = await taskRepo.getTaskById(habit.idTasks);
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _color = task.color;
    }

    if (mounted) {
      setState(() {
        _selectedDays = Set.from(days);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Nouvelle habitude' : 'Modifier l\'habitude'),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  hintText: 'Entrez le titre de l\'habitude',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le titre est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez l\'habitude',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Jours de la semaine
              const Text(
                'Jours de la semaine',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDayChip(1, 'Lundi'),
                  _buildDayChip(2, 'Mardi'),
                  _buildDayChip(3, 'Mercredi'),
                  _buildDayChip(4, 'Jeudi'),
                  _buildDayChip(5, 'Vendredi'),
                  _buildDayChip(6, 'Samedi'),
                  _buildDayChip(7, 'Dimanche'),
                ],
              ),
              const SizedBox(height: 24),

              // SECTION RAPPEL
              const Text(
                'Rappel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Activer le rappel'),
                subtitle: const Text('Recevez une notification à l\'heure de l\'habitude'),
                value: _enableReminder,
                onChanged: (value) => setState(() => _enableReminder = value),
              ),

              if (_enableReminder) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectTime(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Heure du rappel',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded),
                        const SizedBox(width: 8),
                        Text('${_reminderTime.format(context)}'),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(int day, String label) {
    final isSelected = _selectedDays.contains(day);
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(day);
          } else {
            _selectedDays.remove(day);
          }
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.primaryColor.withOpacity(0.3),
      checkmarkColor: theme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un jour')),
      );
      return;
    }

    final taskRepo = ref.read(taskRepositoryProvider);
    final habitRepo = ref.read(habitRepositoryProvider);

    try {
      late Task task;
      late Habit habit;

      if (widget.habit != null) {
        habit = widget.habit!;
        final existingTask = await taskRepo.getTaskById(habit.idTasks);
        if (existingTask == null) {
          throw Exception('Tâche associée introuvable');
        }
        task = existingTask
          ..title = _titleController.text.trim()
          ..description = _descriptionController.text.trim()
          ..color = _color;
        await taskRepo.updateTask(task);
      } else {
        task = Task()
          ..title = _titleController.text.trim()
          ..description = _descriptionController.text.trim()
          ..date = DateTime.now()
          ..startTime = DateTime.now()
          ..endTime = DateTime.now().add(const Duration(hours: 1))
          ..color = _color
          ..idCategory = 1
          ..idPriority = 2
          ..idStatus = 2;
        await taskRepo.saveTask(task);

        habit = Habit()..idTasks = task.idTasks;
        await habitRepo.saveHabit(habit);
      }

      await habitRepo.addDaysToHabit(habit.idHabit, _selectedDays.toList());

      if (_enableReminder) {
        final notificationService = NotificationService();
        await notificationService.scheduleHabitWithSettings(
          habit: habit,
          task: task,
          daysOfWeek: _selectedDays.toList(),
          reminderTime: _reminderTime,
        );
      }

      ref.invalidate(allHabitsProvider);
      ref.invalidate(todayHabitsProvider);
      ref.invalidate(allHabitsWithTasksProvider);
      ref.invalidate(habitDaysProvider(habit.idHabit));
      invalidateTaskProviders(ref);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.habit == null
                ? '✅ Habitude créée avec succès'
                : '✅ Habitude modifiée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
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