// lib/views/habit_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../providers/repository_providers.dart';

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
  final _habitController = HabitController();
  
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
    final days = await _habitController.getDaysForHabit(habit.idHabit);
    _titleController.text = habit.title;
    _descriptionController.text = habit.description;
    _color = habit.color;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Nouvelle habitude' : 'Modifier l\'habitude'),
        actions: [
          if (widget.habit != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Supprimer',
              onPressed: _confirmDelete,
            ),
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
                  labelText: 'Titre *',
                  hintText: 'Entrez le titre de l\'habitude (3-100 caractères)',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 100,
                validator: _habitController.validateTitle,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez l\'habitude (optionnel, max 500 caractères)',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLines: 3,
                maxLength: 500,
                validator: _habitController.validateDescription,
              ),
              const SizedBox(height: 16),

              // Jours de la semaine
              const Text(
                'Jours de la semaine *',
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
              // Message d'erreur pour les jours
              if (_selectedDays.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Veuillez sélectionner au moins un jour',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
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

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'habitude'),
        content: Text('Voulez-vous supprimer « ${widget.habit?.title} » ?'),
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
        await _habitController.deleteHabit(widget.habit!.idHabit);
        
        ref.invalidate(allHabitsProvider);
        ref.invalidate(todayHabitsProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Habitude supprimée'),
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

  Future<void> _saveHabit() async {
    // Validation du formulaire
    if (!_formKey.currentState!.validate()) return;

    // Validation des jours
    final dayError = _habitController.validateDays(_selectedDays);
    if (dayError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ $dayError'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final habit = widget.habit ?? Habit();
      habit
        ..title = _titleController.text.trim()
        ..description = _descriptionController.text.trim()
        ..color = _color;

      await _habitController.saveHabitWithDays(habit, _selectedDays.toList());

      if (_enableReminder) {
        await _habitController.scheduleHabitReminders(
          habit: habit,
          daysOfWeek: _selectedDays.toList(),
          reminderTime: _reminderTime,
        );
      }

      ref.invalidate(allHabitsProvider);
      ref.invalidate(todayHabitsProvider);
      ref.invalidate(habitDaysProvider(habit.idHabit));

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