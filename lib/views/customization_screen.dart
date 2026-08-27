// lib/views/customization_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../models/status.dart';
import '../repositories/category_repository.dart';
import '../repositories/priority_repository.dart';
import '../repositories/status_repository.dart';
import '../utils/validators.dart';
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

  static const icons = <String, IconData>{
    'layers': LucideIcons.layers,
    'briefcase': LucideIcons.briefcase,
    'user': LucideIcons.user,
    'house': LucideIcons.house,
    'flag': LucideIcons.flag,
    'circle_check': LucideIcons.circle_check,
    'star': LucideIcons.star,
    'bookmark': LucideIcons.bookmark,
    'heart': LucideIcons.heart,
    'target': LucideIcons.target,
    'zap': LucideIcons.zap,
    'bell': LucideIcons.bell,
    'calendar': LucideIcons.calendar,
    'clock': LucideIcons.clock,
    'coffee': LucideIcons.coffee,
    'book_open': LucideIcons.book_open,
    'graduation_cap': LucideIcons.graduation_cap,
    'shopping_cart': LucideIcons.shopping_cart,
    'dumbbell': LucideIcons.dumbbell,
    'music': LucideIcons.music,
    'message_circle': LucideIcons.message_circle,
    'info': LucideIcons.info,
    'settings': LucideIcons.settings,
    'archive': LucideIcons.archive,
    'award': LucideIcons.award,
    'bike': LucideIcons.bike,
    'cake': LucideIcons.cake,
    'camera': LucideIcons.camera,
    'car': LucideIcons.car,
    'circle': LucideIcons.circle,
    'code': LucideIcons.code,
    'compass': LucideIcons.compass,
    'crown': LucideIcons.crown,
    'file_text': LucideIcons.file_text,
    'gift': LucideIcons.gift,
    'globe': LucideIcons.globe,
    'hammer': LucideIcons.hammer,
    'key': LucideIcons.key,
    'mail': LucideIcons.mail,
    'map_pin': LucideIcons.map_pin,
    'monitor': LucideIcons.monitor,
    'package': LucideIcons.package,
    'phone': LucideIcons.phone,
    'play': LucideIcons.play,
    'rocket': LucideIcons.rocket,
    'search': LucideIcons.search,
    'shield': LucideIcons.shield,
    'sun': LucideIcons.sun,
    'trophy': LucideIcons.trophy,
    'wallet': LucideIcons.wallet,
    'wifi': LucideIcons.wifi,
  };

  late Future<List<dynamic>> _itemsFuture;
  bool _isReloading = false;

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

  String get _itemType {
    switch (widget.kind) {
      case CustomizationKind.categories:
        return 'catégorie';
      case CustomizationKind.priorities:
        return 'priorité';
      case CustomizationKind.statuses:
        return 'statut';
    }
  }

  String get _itemArticle {
    return widget.kind == CustomizationKind.statuses ? 'le' : 'la';
  }

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _isReloading = true;
      _itemsFuture = _loadItems().whenComplete(() {
        if (mounted) setState(() => _isReloading = false);
      });
    });
  }

  Future<List<dynamic>> _loadItems() {
    return switch (widget.kind) {
      CustomizationKind.categories => CategoryRepository().getAllCategories(),
      CustomizationKind.priorities => PriorityRepository().getAllPriorities(),
      CustomizationKind.statuses => StatusRepository().getAllStatus(),
    };
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
          if (_isReloading) return const _CustomizationSkeletonLoader();
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          }
          if (!snapshot.hasData) {
            return const _CustomizationSkeletonLoader();
          }
          if (snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun élément dans $_title'));
          }
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

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger les éléments',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage(error, 'charger'), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
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
          child: Icon(icons[iconName] ?? LucideIcons.tag, color: Colors.white),
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
    final existingNames = (await _itemsFuture)
        .map((existingItem) => existingItem.name as String)
        .toList();
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _CustomizationEditDialog(
        title: item == null ? 'Ajouter' : 'Modifier',
        itemType: _itemType,
        item: item,
        colors: colors,
        icons: icons,
        existingNames: existingNames,
        currentName: item?.name as String?,
        onSave: (name, color, icon) => _saveItem(item, name, color, icon),
      ),
    );

    if (result == true && mounted) _reload();
  }

  Future<void> _saveItem(
    dynamic item,
    String name,
    int color,
    String icon,
  ) async {
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
          await CategoryRepository().deleteCategory(
            (item as Category).idCategory,
          );
        case CustomizationKind.priorities:
          await PriorityRepository().deletePriority(
            (item as Priority).idPriorities,
          );
        case CustomizationKind.statuses:
          await StatusRepository().deleteStatus((item as Status).idStatus);
      }
      if (mounted) _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage(error, 'supprimer')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _errorMessage(Object error, String action) {
    final details = error.toString().replaceFirst('Exception: ', '').trim();
    if (details.isNotEmpty && !details.startsWith('Bad state')) {
      return 'Impossible de $action $_itemArticle $_itemType : $details';
    }
    return 'Impossible de $action $_itemArticle $_itemType. Vérifiez les données et réessayez.';
  }
}

class _CustomizationEditDialog extends StatefulWidget {
  const _CustomizationEditDialog({
    required this.title,
    required this.itemType,
    required this.item,
    required this.colors,
    required this.icons,
    required this.existingNames,
    required this.currentName,
    required this.onSave,
  });

  final String title;
  final String itemType;
  final dynamic item;
  final List<int> colors;
  final Map<String, IconData> icons;
  final List<String> existingNames;
  final String? currentName;
  final Future<void> Function(String name, int color, String icon) onSave;

  @override
  State<_CustomizationEditDialog> createState() =>
      _CustomizationEditDialogState();
}

class _CustomizationEditDialogState extends State<_CustomizationEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late int _selectedColor;
  late String _selectedIcon;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.item?.name as String? ?? '',
    );
    _selectedColor = widget.item?.color as int? ?? widget.colors.first;
    _selectedIcon = widget.item?.icon as String? ?? widget.icons.keys.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    try {
      await widget.onSave(
        _nameController.text.trim(),
        _selectedColor,
        _selectedIcon,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        final details = error.toString().replaceFirst('Exception: ', '').trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impossible d\'enregistrer le ${widget.itemType} : '
              '${details.isEmpty ? 'vérifiez les données et réessayez.' : details}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _validateName(String? value) {
    final validationError = Validators.validateCustomizationName(
      value,
      widget.itemType,
    );
    if (validationError != null) return validationError;

    final normalizedName = value!.trim().toLowerCase();
    final normalizedCurrentName = widget.currentName?.trim().toLowerCase();
    final isDuplicate = widget.existingNames.any(
      (existingName) =>
          existingName.trim().toLowerCase() == normalizedName &&
          normalizedName != normalizedCurrentName,
    );
    if (isDuplicate) return 'Ce nom de ${widget.itemType} existe déjà';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.sizeOf(context).height * 0.55,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  maxLength: 50,
                  decoration: InputDecoration(
                    labelText: 'Nom de ${widget.itemType}',
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children: widget.colors.map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: Color(color),
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Icône',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.icons.entries.map((entry) {
                    final isSelected = _selectedIcon == entry.key;
                    return SizedBox(
                      width: 44,
                      height: 44,
                      child: Tooltip(
                        message: entry.key,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _isSaving
                              ? null
                              : () => setState(() => _selectedIcon = entry.key),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.transparent
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  entry.value,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                if (isSelected)
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Icon(
                                      LucideIcons.check,
                                      size: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _CustomizationSkeletonLoader extends StatelessWidget {
  const _CustomizationSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final highlightColor = theme.brightness == Brightness.dark
        ? const Color(0xFF475569)
        : const Color(0xFFF8FAFC);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _SkeletonBox(
                  width: 40,
                  height: 40,
                  color: baseColor,
                  highlightColor: highlightColor,
                  shape: BoxShape.circle,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SkeletonBox(
                    width: double.infinity,
                    height: 18,
                    color: baseColor,
                    highlightColor: highlightColor,
                  ),
                ),
                const SizedBox(width: 24),
                _SkeletonBox(
                  width: 24,
                  height: 24,
                  color: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
    required this.highlightColor,
    this.shape = BoxShape.rectangle,
  });

  final double width;
  final double height;
  final Color color;
  final Color highlightColor;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(6)
            : null,
      ),
      foregroundDecoration: BoxDecoration(
        color: highlightColor.withValues(alpha: 0.25),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(6)
            : null,
      ),
    );
  }
}
