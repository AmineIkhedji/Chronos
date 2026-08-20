// lib/views/task_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../models/status.dart';
import '../repositories/category_repository.dart';
import '../repositories/priority_repository.dart';
import '../repositories/status_repository.dart';
import '../services/notification_service.dart';
import '../providers/repository_providers.dart';
import '../providers/task_providers.dart';

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
  
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  int _color = 0xFF4F7CFF;
  int? _selectedCategoryId;
  int? _selectedPriorityId;
  int? _selectedStatusId;
  
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
    final categoryRepo = CategoryRepository();
    final priorityRepo = PriorityRepository();
    final statusRepo = StatusRepository();

    setState(() => _isLoading = true);

    try {
      _categories = await categoryRepo.getAllCategories();
      _priorities = await priorityRepo.getAllPriorities();
      _statuses = await statusRepo.getAllStatus();

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
      print('Erreur lors du chargement des données: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initFromTask(Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _date = task.date;
    _startTime = TimeOfDay.fromDateTime(task.startTime);
    _endTime = TimeOfDay.fromDateTime(task.endTime);
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
        title: Text(widget.task == null ? 'Nouvelle tâche' : 'Modifier la tâche'),
        actions: [
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
                        labelText: 'Titre',
                        hintText: 'Entrez le titre de la tâche',
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

                    // ============ DESCRIPTION ============
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Décrivez la tâche',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // ============ DATE ============
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded),
                            const SizedBox(width: 8),
                            Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(_date)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ============ HEURE DE DÉBUT ============
                    InkWell(
                      onTap: () => _selectTime(context, _startTime, (time) {
                        setState(() => _startTime = time);
                      }),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Heure de début',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded),
                            const SizedBox(width: 8),
                            Text('${_startTime.format(context)}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ============ HEURE DE FIN ============
                    InkWell(
                      onTap: () => _selectTime(context, _endTime, (time) {
                        setState(() => _endTime = time);
                      }),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Heure de fin',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded),
                            const SizedBox(width: 8),
                            Text('${_endTime.format(context)}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ============ CATÉGORIE ============
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
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
                      onChanged: (value) => setState(() => _selectedCategoryId = value),
                    ),
                    const SizedBox(height: 16),

                    // ============ PRIORITÉ ============
                    DropdownButtonFormField<int>(
                      value: _selectedPriorityId,
                      decoration: const InputDecoration(
                        labelText: 'Priorité',
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
                      onChanged: (value) => setState(() => _selectedPriorityId = value),
                    ),
                    const SizedBox(height: 16),

                    // ============ STATUT ============
                    DropdownButtonFormField<int>(
                      value: _selectedStatusId,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
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
                      onChanged: (value) => setState(() => _selectedStatusId = value),
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
                      subtitle: const Text('Recevez une notification avant la tâche'),
                      value: _enableReminder,
                      onChanged: (value) => setState(() => _enableReminder = value),
                    ),

                    if (_enableReminder) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _reminderMinutesBefore,
                              decoration: const InputDecoration(
                                labelText: 'Rappel',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 5, child: Text('5 minutes avant')),
                                DropdownMenuItem(value: 10, child: Text('10 minutes avant')),
                                DropdownMenuItem(value: 15, child: Text('15 minutes avant')),
                                DropdownMenuItem(value: 30, child: Text('30 minutes avant')),
                                DropdownMenuItem(value: 60, child: Text('1 heure avant')),
                                DropdownMenuItem(value: 120, child: Text('2 heures avant')),
                                DropdownMenuItem(value: 1440, child: Text('1 jour avant')),
                              ],
                              onChanged: (value) => setState(() => _reminderMinutesBefore = value!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.access_time_rounded),
                            onPressed: () => _selectTime(context, _reminderTime, (time) {
                              setState(() => _reminderTime = time);
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Le rappel sera envoyé ${_reminderMinutesBefore} minutes avant le début de la tâche',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
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

  // ============ MÉTHODES DE SÉLECTION ============

  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _date = date);
    }
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initial, Function(TimeOfDay) onSelect) async {
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (time != null) {
      onSelect(time);
    }
  }

  // ============ SAUVEGARDE ET PLANIFICATION ============

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    // Créer la tâche
    final task = widget.task ?? Task();
    task.title = _titleController.text.trim();
    task.description = _descriptionController.text.trim();
    task.date = _date;
    
    task.startTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _startTime.hour,
      _startTime.minute,
    );
    
    task.endTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _endTime.hour,
      _endTime.minute,
    );
    
    task.color = _color;
    task.idCategory = _selectedCategoryId ?? 0;
    task.idPriority = _selectedPriorityId ?? 0;
    task.idStatus = _selectedStatusId ?? 0;

    // Vérifier que l'heure de fin est après l'heure de début
    if (task.endTime.isBefore(task.startTime)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ L\'heure de fin doit être après l\'heure de début'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Vérifier que la tâche est dans le futur (uniquement à la création)
    if (widget.task == null && task.startTime.isBefore(DateTime.now())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ La tâche doit être planifiée dans le futur'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.saveTask(task);

      invalidateTaskProviders(ref);

      // Planifier le rappel si activé
      if (_enableReminder) {
        // Calculer l'heure du rappel
        final remindAt = task.startTime.subtract(Duration(minutes: _reminderMinutesBefore));
        
        // Vérifier que le rappel est dans le futur
        if (remindAt.isBefore(DateTime.now())) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ Le rappel serait à ${remindAt.toLocal()}, qui est déjà passé. Vérifiez la date/heure.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        final notificationService = NotificationService();
        await notificationService.scheduleTaskReminder(
          task.idTasks,
          task.title,
          task.description,
          remindAt,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.task == null
                ? '✅ Tâche créée avec succès'
                : '✅ Tâche modifiée avec succès'),
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