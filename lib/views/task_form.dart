// lib/views/task_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../models/status.dart';
import '../providers/task_providers.dart';
import '../utils/validators.dart';
import '../widgets/form/color_selector.dart';
import '../widgets/form/time_picker_field.dart';
import '../widgets/form/date_picker_field.dart';
import '../widgets/common/confirmation_dialog.dart';
import '../widgets/common/custom_snackbar.dart';

class TaskForm extends ConsumerStatefulWidget {
  final Task? task;

  const TaskForm({super.key, this.task});

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taskController = TaskController();

  DateTime _date = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _color = 0xFF4F7CFF;
  int? _selectedCategoryId;
  int? _selectedPriorityId;
  int? _selectedStatusId;

  bool _hasStartTime = false;
  bool _hasEndTime = false;

  bool _enableReminder = false;
  int _reminderMinutesBefore = 15;

  List<Category> _categories = [];
  List<Priority> _priorities = [];
  List<Status> _statuses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.task != null) {
      _initFromTask(widget.task!);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _categories = await _taskController.getCategories();
      _priorities = await _taskController.getPriorities();
      _statuses = await _taskController.getStatuses();

      if (_categories.isNotEmpty && _selectedCategoryId == null) {
        _selectedCategoryId = _categories[0].idCategory;
      }
      if (_priorities.isNotEmpty && _selectedPriorityId == null) {
        _selectedPriorityId = _priorities[0].idPriorities;
      }
      if (_statuses.isNotEmpty && _selectedStatusId == null) {
        _selectedStatusId = _statuses[0].idStatus;
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des données: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initFromTask(Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _date = task.date;

    if (task.startTime != null) {
      _startTime = TimeOfDay.fromDateTime(task.startTime!);
      _hasStartTime = true;
    }

    if (task.endTime != null) {
      _endTime = TimeOfDay.fromDateTime(task.endTime!);
      _hasEndTime = true;
    }

    _color = task.color;
    _selectedCategoryId = task.idCategory;
    _selectedPriorityId = task.idPriority;
    _selectedStatusId = task.idStatus;
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
          widget.task == null ? 'Nouvelle tâche' : 'Modifier la tâche',
        ),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Supprimer',
              onPressed: _confirmDelete,
            ),
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
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
                            'Entrez le titre de la tâche (3-100 caractères)',
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
                            'Décrivez la tâche (optionnel, max 500 caractères)',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      maxLines: 3,
                      maxLength: 500,
                      validator: Validators.validateDescription,
                    ),
                    const SizedBox(height: 16),

                    // ============ DATE ============
                    DatePickerField(
                      value: _date,
                      label: 'Date *',
                      onDateSelected: (date) => setState(() => _date = date),
                    ),
                    const SizedBox(height: 16),

                    // ============ HEURE DE DÉBUT (OPTIONNELLE) ============
                    SwitchListTile(
                      title: const Text('Définir une heure de début'),
                      subtitle: const Text('Optionnel'),
                      value: _hasStartTime,
                      onChanged: (value) {
                        setState(() {
                          _hasStartTime = value;
                          if (!value) _startTime = null;
                        });
                      },
                    ),
                    if (_hasStartTime) ...[
                      TimePickerField(
                        value: _startTime,
                        label: 'Heure de début',
                        onTimeSelected: (time) =>
                            setState(() => _startTime = time),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // ============ HEURE DE FIN (OPTIONNELLE) ============
                    SwitchListTile(
                      title: const Text('Définir une heure de fin'),
                      subtitle: const Text('Optionnel'),
                      value: _hasEndTime,
                      onChanged: (value) {
                        setState(() {
                          _hasEndTime = value;
                          if (!value) _endTime = null;
                        });
                      },
                    ),
                    if (_hasEndTime) ...[
                      TimePickerField(
                        value: _endTime,
                        label: 'Heure de fin',
                        onTimeSelected: (time) =>
                            setState(() => _endTime = time),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // ============ CATÉGORIE ============
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
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

                    // ============ PRIORITÉ ============
                    DropdownButtonFormField<int>(
                      initialValue: _selectedPriorityId,
                      decoration: const InputDecoration(
                        labelText: 'Priorité *',
                        border: OutlineInputBorder(),
                      ),
                      items: _priorities.map((priority) {
                        return DropdownMenuItem(
                          value: priority.idPriorities,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(priority.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(priority.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedPriorityId = value),
                      validator: Validators.validatePriority,
                    ),
                    const SizedBox(height: 16),

                    // ============ STATUT ============
                    DropdownButtonFormField<int>(
                      initialValue: _selectedStatusId,
                      decoration: const InputDecoration(
                        labelText: 'Statut *',
                        border: OutlineInputBorder(),
                      ),
                      items: _statuses.map((status) {
                        return DropdownMenuItem(
                          value: status.idStatus,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(status.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(status.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedStatusId = value),
                      validator: Validators.validateStatus,
                    ),
                    const SizedBox(height: 24),

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
                        'Recevez une notification avant la tâche',
                      ),
                      value: _enableReminder,
                      onChanged: (value) {
                        setState(() {
                          _enableReminder = value;
                          if (value && !_hasStartTime) {
                            _hasStartTime = true;
                            _startTime =
                                _startTime ??
                                const TimeOfDay(hour: 9, minute: 0);
                          }
                        });
                      },
                    ),

                    if (_enableReminder) ...[
                      const SizedBox(height: 8),
                      if (!_hasStartTime)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Un rappel nécessite une heure de début',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        initialValue: _reminderMinutesBefore,
                        decoration: const InputDecoration(
                          labelText: 'Délai du rappel',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notifications_active_rounded),
                        ),
                        items: _taskController.getReminderOptions(),
                        onChanged: (value) =>
                            setState(() => _reminderMinutesBefore = value!),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous serez notifié ${_taskController.formatReminderTime(_reminderMinutesBefore)} avant la tâche',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
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

  // ============ SUPPRESSION ============

  Future<void> _confirmDelete() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Supprimer la tâche',
      message: 'Voulez-vous supprimer « ${widget.task?.title} » ?',
      confirmText: 'Supprimer',
      isDestructive: true,
    );

    if (confirmed) {
      try {
        await _taskController.deleteTask(widget.task!.idTasks);

        invalidateTaskProviders(ref);

        if (mounted) {
          CustomSnackbar.success(context, 'Tâche supprimée');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.error(context, 'Erreur : ${e.toString()}');
        }
      }
    }
  }

  // ============ SAUVEGARDE ============

  Future<void> _saveTask() async {
    // Validation du formulaire
    if (!_formKey.currentState!.validate()) return;

    // Validation supplémentaire des heures
    final startDateTime = _hasStartTime && _startTime != null
        ? DateTime(
            _date.year,
            _date.month,
            _date.day,
            _startTime!.hour,
            _startTime!.minute,
          )
        : null;
    final endDateTime = _hasEndTime && _endTime != null
        ? DateTime(
            _date.year,
            _date.month,
            _date.day,
            _endTime!.hour,
            _endTime!.minute,
          )
        : null;

    // Vérifier que la tâche n'est pas dans le passé
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(_date.year, _date.month, _date.day);

    if (taskDate.isBefore(today)) {
      if (mounted) {
        CustomSnackbar.warning(
          context,
          'Impossible de créer une tâche dans le passé',
        );
      }
      return;
    }

    // Si la tâche est aujourd'hui, vérifier que l'heure n'est pas passée
    if (taskDate == today) {
      if (startDateTime != null && startDateTime.isBefore(DateTime.now())) {
        if (mounted) {
          CustomSnackbar.warning(
            context,
            'Impossible de créer une tâche avec une heure passée',
          );
        }
        return;
      }
    }

    // Vérifier la cohérence des heures
    final timeError = _taskController.validateTimes(startDateTime, endDateTime);
    if (timeError != null) {
      if (mounted) {
        CustomSnackbar.warning(context, timeError);
      }
      return;
    }

    // Créer ou mettre à jour la tâche
    final task = widget.task ?? Task();
    task.title = _titleController.text.trim();
    task.description = _descriptionController.text.trim();
    task.date = _date;
    task.startTime = startDateTime;
    task.endTime = endDateTime;
    task.color = _color;
    task.idCategory = _selectedCategoryId ?? 0;
    task.idPriority = _selectedPriorityId ?? 0;
    task.idStatus = _selectedStatusId ?? 0;

    try {
      // Sauvegarder la tâche
      if (widget.task == null) {
        await _taskController.saveTask(task);
      } else {
        await _taskController.updateTask(task);
      }

      if (widget.task != null) {
        await _taskController.cancelAllReminders(task.idTasks);
      }

      invalidateTaskProviders(ref);

      // Planifier le rappel si activé
      if (_enableReminder) {
        await _taskController.scheduleReminder(
          task: task,
          minutesBefore: _reminderMinutesBefore,
        );
      }

      if (mounted) {
        CustomSnackbar.success(
          context,
          widget.task == null
              ? 'Tâche créée avec succès'
              : 'Tâche modifiée avec succès',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.error(context, 'Erreur : ${e.toString()}');
      }
    }
  }
}
