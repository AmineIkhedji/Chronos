// lib/views/habit_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../models/category.dart';
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
  int? _selectedCategoryId;
  bool _enableReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  // Mode de répétition : 'daily' = tous les jours, 'specific' = jours spécifiques
  String _repeatMode = 'daily';
  Set<int> _selectedDays = {};

  static const _availableColors = [
    0xFF4F7CFF, // Bleu
    0xFF22C55E, // Vert
    0xFFF59E0B, // Orange
    0xFFEF4444, // Rouge
    0xFFA855F7, // Violet
    0xFF06B6D4, // Cyan
    0xFFEC4899, // Rose
    0xFF84CC16, // Lime
  ];

  // Jours de la semaine avec leur lettre
  static const _daysOfWeek = [
    (1, 'L'),
    (2, 'M'),
    (3, 'M'),
    (4, 'J'),
    (5, 'V'),
    (6, 'S'),
    (7, 'D'),
  ];

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
    final theme = Theme.of(context);

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
                      validator: _habitController.validateTitle,
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
                      validator: _habitController.validateDescription,
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
                      validator: (value) =>
                          _habitController.validateCategory(value),
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableColors.map((color) {
                        final isSelected = _color == color;
                        return InkWell(
                          onTap: () => setState(() => _color = color),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(color),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: theme.colorScheme.onSurface,
                                      width: 3,
                                    )
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(color).withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
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

                    // Deux boutons : Tous les jours / Jours spécifiques
                    Row(
                      children: [
                        Expanded(
                          child: _buildRepeatModeButton(
                            label: 'Tous les jours',
                            icon: LucideIcons.calendar_days,
                            isSelected: _repeatMode == 'daily',
                            onTap: () {
                              setState(() {
                                _repeatMode = 'daily';
                                _selectedDays = {1, 2, 3, 4, 5, 6, 7};
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRepeatModeButton(
                            label: 'Jours spécifiques',
                            icon: LucideIcons.calendar_clock,
                            isSelected: _repeatMode == 'specific',
                            onTap: () {
                              setState(() {
                                _repeatMode = 'specific';
                                if (_selectedDays.length == 7) {
                                  _selectedDays = {};
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    // Boules des jours (visible uniquement en mode spécifique)
                    if (_repeatMode == 'specific') ...[
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: _daysOfWeek.map((dayData) {
                          final day = dayData.$1;
                          final letter = dayData.$2;
                          final isSelected = _selectedDays.contains(day);

                          return _buildDayBubble(
                            day: day,
                            letter: letter,
                            isSelected: isSelected,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      // Message si aucun jour sélectionné
                      if (_selectedDays.isEmpty)
                        Center(
                          child: Text(
                            'Sélectionnez au moins un jour',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],

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

  Widget _buildRepeatModeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.5)
                : theme.dividerColor.withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.primaryColor
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center, // ✅ Correct ici
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBubble({
    required int day,
    required String letter,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final primaryColor = Color(_color);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDays.remove(day);
          } else {
            _selectedDays.add(day);
          }
        });
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? primaryColor.withOpacity(0.2) : theme.cardColor,
          border: Border.all(
            color: isSelected
                ? primaryColor
                : theme.dividerColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: isSelected ? primaryColor : theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
