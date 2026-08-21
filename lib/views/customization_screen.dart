// lib/views/customization_screen.dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../models/status.dart';
import '../repositories/category_repository.dart';
import '../repositories/priority_repository.dart';
import '../repositories/status_repository.dart';
import '../widgets/common/confirmation_dialog.dart';

enum CustomizationKind { categories, priorities, statuses }

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key, required this.kind});

  final CustomizationKind kind;

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  static const colors = [
    0xFF4F7CFF,
    0xFF22C55E,
    0xFFF59E0B,
    0xFFEF4444,
    0xFFA855F7,
    0xFF06B6D4,
  ];
  
  static const icons = {
    'category': Icons.category_rounded,
    'work': Icons.work_rounded,
    'person': Icons.person_rounded,
    'home': Icons.home_rounded,
    'flag': Icons.flag_rounded,
    'check_circle': Icons.check_circle_rounded,
    'star': Icons.star_rounded,
    'bookmark': Icons.bookmark_rounded,
  };

  late Future<List<dynamic>> _itemsFuture;

  String get _title {
    switch (widget.kind) {
      case CustomizationKind.categories:
        return 'Catégories';
      case CustomizationKind.priorities:
        return 'Priorités';
      case CustomizationKind.statuses:
        return 'Statuts';
    }
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _itemsFuture = switch (widget.kind) {
        CustomizationKind.categories => CategoryRepository().getAllCategories(),
        CustomizationKind.priorities => PriorityRepository().getAllPriorities(),
        CustomizationKind.statuses => StatusRepository().getAllStatus(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editItem(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return Center(child: Text('Aucun élément dans $_title'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (_, index) => _itemTile(snapshot.data![index]),
          );
        },
      ),
    );
  }

  Widget _itemTile(dynamic item) {
    final name = item.name as String;
    final color = Color(item.color as int);
    final iconName = item.icon as String;
    
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icons[iconName] ?? Icons.label, color: Colors.white),
        ),
        title: Text(name),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'edit') _editItem(item);
            if (action == 'delete') _deleteItem(item);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Modifier')),
            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ),
    );
  }

  Future<void> _editItem([dynamic item]) async {
    final nameController = TextEditingController(text: item?.name as String? ?? '');
    var selectedColor = item?.color as int? ?? colors.first;
    var selectedIcon = item?.icon as String? ?? icons.keys.first;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Ajouter' : 'Modifier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: colors.map((color) => GestureDetector(
                  onTap: () => setDialogState(() => selectedColor = color),
                  child: CircleAvatar(
                    backgroundColor: Color(color),
                    child: selectedColor == color 
                      ? const Icon(Icons.check, color: Colors.white) 
                      : null,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedIcon,
                decoration: const InputDecoration(labelText: 'Icône'),
                items: icons.entries.map((entry) => 
                  DropdownMenuItem(value: entry.key, child: Icon(entry.value))
                ).toList(),
                onChanged: (value) => setDialogState(() => selectedIcon = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await _saveItem(item, nameController.text.trim(), selectedColor, selectedIcon);
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    
    nameController.dispose();
    if (result == true && mounted) _reload();
  }

  Future<void> _saveItem(dynamic item, String name, int color, String icon) async {
    switch (widget.kind) {
      case CustomizationKind.categories:
        final value = item as Category? ?? Category();
        value
          ..name = name
          ..color = color
          ..icon = icon;
        await CategoryRepository().saveCategory(value);
      case CustomizationKind.priorities:
        final value = item as Priority? ?? Priority();
        value
          ..name = name
          ..color = color
          ..icon = icon;
        await PriorityRepository().savePriority(value);
      case CustomizationKind.statuses:
        final value = item as Status? ?? Status();
        value
          ..name = name
          ..color = color
          ..icon = icon;
        await StatusRepository().saveStatus(value);
    }
  }

  Future<void> _deleteItem(dynamic item) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Supprimer',
      message: 'Voulez-vous supprimer cet élément ?',
      confirmText: 'Supprimer',
      isDestructive: true,
    );

    if (!confirmed) return;

    try {
      switch (widget.kind) {
        case CustomizationKind.categories:
          await CategoryRepository().deleteCategory((item as Category).idCategory);
        case CustomizationKind.priorities:
          await PriorityRepository().deletePriority((item as Priority).idPriorities);
        case CustomizationKind.statuses:
          await StatusRepository().deleteStatus((item as Status).idStatus);
      }
      if (mounted) _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}