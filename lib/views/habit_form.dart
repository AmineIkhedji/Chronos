// lib/views/habit_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../models/category.dart';
import '../providers/habit_providers.dart';
import '../utils/validators.dart';
import '../widgets/form/color_selector.dart';
import '../widgets/form/time_picker_field.dart';
import '../widgets/habits/habit_day_selector.dart';
import '../widgets/common/confirmation_dialog.dart';

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
  int? _selectedCategoryId;
  bool _enableReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  // Mode de répétition : 'daily' = tous les jours, 'specific' = jours spécifiques
  String _repeatMode = 'daily';
  Set<int> _selectedDays = {};
  Set<int> _specificDays = {};

  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.habit != null) {
      _loadHabitData(widget.habit!);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _categories = await _habitController.getCategories();

      if (_categories.isNotEmpty && _selectedCategoryId == null) {
        _selectedCategoryId = _categories[0].idCategory;
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHabitData(Habit habit) async {
    final days = await _habitController.getDaysForHabit(habit.idHabit);
    _titleController.text = habit.title;
    _descriptionController.text = habit.description;
    _color = habit.color;
    _selectedCategoryId = habit.idCategory;

    if (mounted) {
      setState(() {
        _selectedDays = Set.from(days);
        _specificDays = Set.from(days);
        _repeatMode = days.length == 7 ? 'daily' : 'specific';
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
        title: Text(
          widget.habit == null ? 'Nouvelle habitude' : 'Modifier l\'habitude',
        ),
        actions: [
          if (widget.habit != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Supprimer',
              onPressed: _confirmDelete,
            ),
          TextButton(
            onPressed: _isLoading ? null : _saveHabit,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ============ TITRE ============
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre *',
                        hintText:
                            'Entrez le titre de l\'habitude (3-100 caractères)',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: Validators.validateTitle,
                    ),
                    const SizedBox(height: 16),

                    // ============ DESCRIPTION ============
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText:
                            'Décrivez l\'habitude (optionnel, max 500 caractères)',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      maxLines: 3,
                      maxLength: 500,
                      validator: Validators.validateDescription,
                    ),
                    const SizedBox(height: 16),

                    // ============ CATÉGORIE ============
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie *',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category.idCategory,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(category.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategoryId = value),
                      validator: Validators.validateCategory,
                    ),
                    const SizedBox(height: 16),

                    // ============ COULEUR ============
                    const Text(
                      'Couleur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ColorSelector(
                      selectedColor: _color,
                      onColorSelected: (color) =>
                          setState(() => _color = color),
                    ),
                    const SizedBox(height: 24),

                    // ============ RÉPÉTITION ============
                    const Text(
                      'Répétition',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    HabitDaySelector(
                      repeatMode: _repeatMode,
                      selectedDays: _selectedDays,
                      selectedColor: _color,
                      onRepeatModeChanged: (mode) {
                        final previousMode = _repeatMode;
                        setState(() {
                          _repeatMode = mode;
                          if (mode == 'daily') {
                            if (previousMode == 'specific') {
                              _specificDays = Set.from(_selectedDays);
                            }
                            _selectedDays = {1, 2, 3, 4, 5, 6, 7};
                          } else {
                            _selectedDays = _specificDays.isEmpty
                                ? Set.from(_selectedDays)
                                : Set.from(_specificDays);
                          }
                        });
                      },
                      onDayToggle: (day) {
                        setState(() {
                          if (_selectedDays.contains(day)) {
                            _selectedDays.remove(day);
                          } else {
                            _selectedDays.add(day);
                          }
                          if (_repeatMode == 'specific') {
                            _specificDays = Set.from(_selectedDays);
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // ============ SECTION RAPPEL ============
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
                      subtitle: const Text(
                        'Recevez une notification à l\'heure de l\'habitude',
                      ),
                      value: _enableReminder,
                      onChanged: (value) =>
                          setState(() => _enableReminder = value),
                    ),

                    if (_enableReminder) ...[
                      const SizedBox(height: 16),
                      TimePickerField(
                        value: _reminderTime,
                        label: 'Heure du rappel',
                        onTimeSelected: (time) =>
                            setState(() => _reminderTime = time),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Supprimer l\'habitude',
      message: 'Voulez-vous supprimer « ${widget.habit?.title} » ?',
      confirmText: 'Supprimer',
      isDestructive: true,
    );

    if (confirmed) {
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

    // Validation de la catégorie
    if (_selectedCategoryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Veuillez sélectionner une catégorie'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Validation des jours selon le mode
    if (_repeatMode == 'specific' && _selectedDays.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Veuillez sélectionner au moins un jour'),
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
        ..color = _color
        ..idCategory = _selectedCategoryId!;

      // Déterminer les jours à sauvegarder selon le mode
      final daysToSave = _repeatMode == 'daily'
          ? [1, 2, 3, 4, 5, 6, 7]
          : _selectedDays.toList();

      await _habitController.saveHabitWithDays(habit, daysToSave);

      if (widget.habit != null) {
        await _habitController.cancelAllReminders(habit.idHabit);
      }

      if (_enableReminder) {
        await _habitController.scheduleHabitReminders(
          habit: habit,
          daysOfWeek: daysToSave,
          reminderTime: _reminderTime,
        );
      }

      ref.invalidate(allHabitsProvider);
      ref.invalidate(todayHabitsProvider);
      ref.invalidate(habitDaysProvider(habit.idHabit));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.habit == null
                  ? '✅ Habitude créée avec succès'
                  : '✅ Habitude modifiée avec succès',
            ),
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
