// lib/views/settings_screen.dart (VERSION CORRIGÉE ET FONCTIONNELLE)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/theme/theme_provider.dart';
import '../widgets/theme/theme_colors.dart';
import '../repositories/settings_repository.dart';
import 'customization_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _firstDayOfWeek = DateTime.monday;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsRepository().getSettings();
    if (!mounted || settings == null) return;
    setState(() {
      _firstDayOfWeek = settings.firstDayWeek;
      _notificationsEnabled = settings.notificationsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final userColorKey = ref.watch(userColorProvider);
    final primaryColor = Color(ThemeColors.userColors[userColorKey] ?? ThemeColors.defaultPrimary);

    final cardColor = theme.cardColor;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = theme.colorScheme.onSurface;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Paramètres',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION APPARENCE ---
            _buildSectionTitle('Apparence', textColor),
            const SizedBox(height: 12),
            _buildCard(
              color: cardColor,
              borderColor: borderColor,
              children: [
                // ✅ Switch Mode sombre CORRIGÉ
                _buildListTile(
                  leadingIcon: Icons.dark_mode_rounded,
                  title: 'Mode sombre',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) async {
                      final repo = SettingsRepository();
                      await repo.setDarkMode(value);
                      ref.read(darkModeProvider.notifier).state = value;
                    },
                    activeThumbColor: primaryColor,
                  ),
                ),
                const Divider(height: 1, color: Colors.transparent),
                // ✅ Couleur principale CORRIGÉE
                _buildListTile(
                  leadingIcon: Icons.color_lens_rounded,
                  title: 'Couleur principale',
                  subtitle: 'Personnalisez l\'accent de l\'app',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                  onTap: () => _showColorPickerDialog(context, primaryColor),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- SECTION CALENDRIER ---
            _buildSectionTitle('Calendrier', textColor),
            const SizedBox(height: 12),
            _buildCard(
              color: cardColor,
              borderColor: borderColor,
              children: [
                _buildListTile(
                  leadingIcon: Icons.calendar_today_rounded,
                  title: 'Premier jour de la semaine',
                  subtitle: 'Choisissez le jour de début du calendrier',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _dayName(_firstDayOfWeek),
                        style: TextStyle(color: textSecondary, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                  onTap: _showFirstDayPicker,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- SECTION NOTIFICATIONS ---
            _buildSectionTitle('Notifications', textColor),
            const SizedBox(height: 12),
            _buildCard(
              color: cardColor,
              borderColor: borderColor,
              children: [
                _buildListTile(
                  leadingIcon: Icons.notifications_rounded,
                  title: 'Rappels activés',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) async {
                      await SettingsRepository().setNotificationsEnabled(value);
                      if (mounted) setState(() => _notificationsEnabled = value);
                    },
                    activeThumbColor: primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- SECTION PERSONNALISATION ---
            _buildSectionTitle('Personnalisation', textColor),
            const SizedBox(height: 12),
            _buildCard(
              color: cardColor,
              borderColor: borderColor,
              children: [
                // Catégories
                _buildListTile(
                  leadingIcon: Icons.category_rounded,
                  title: 'Catégories',
                  leadingIconColor: const Color(0xFF4F7CFF),
                  onTap: () => _openCustomization(CustomizationKind.categories),
                ),
                const Divider(height: 1, color: Colors.transparent),
                // Priorités
                _buildListTile(
                  leadingIcon: Icons.flag_rounded,
                  title: 'Priorités',
                  leadingIconColor: const Color(0xFFEF4444),
                  onTap: () => _openCustomization(CustomizationKind.priorities),
                ),
                const Divider(height: 1, color: Colors.transparent),
                // Statuts
                _buildListTile(
                  leadingIcon: Icons.check_circle_rounded,
                  title: 'Statuts',
                  leadingIconColor: const Color(0xFF22C55E),
                  onTap: () => _openCustomization(CustomizationKind.statuses),
                ),
              ],
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _dayName(int day) {
    const names = {
      DateTime.monday: 'Lundi',
      DateTime.tuesday: 'Mardi',
      DateTime.wednesday: 'Mercredi',
      DateTime.thursday: 'Jeudi',
      DateTime.friday: 'Vendredi',
      DateTime.saturday: 'Samedi',
      DateTime.sunday: 'Dimanche',
    };
    return names[day] ?? 'Lundi';
  }

  Future<void> _showFirstDayPicker() async {
    final selectedDay = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Premier jour de la semaine'),
        children: List.generate(7, (index) {
          final day = index + 1;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, day),
            child: Row(
              children: [
                Expanded(child: Text(_dayName(day))),
                if (day == _firstDayOfWeek)
                  Icon(Icons.check, color: Theme.of(context).primaryColor),
              ],
            ),
          );
        }),
      ),
    );
    if (selectedDay == null) return;
    await SettingsRepository().setFirstDayOfWeek(selectedDay);
    if (mounted) setState(() => _firstDayOfWeek = selectedDay);
  }

  void _openCustomization(CustomizationKind kind) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomizationScreen(kind: kind)),
    );
  }

  // ============ WIDGETS UTILITAIRES ============

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color color,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData leadingIcon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? leadingIconColor,
  }) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (leadingIconColor ?? theme.primaryColor).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                leadingIcon,
                color: leadingIconColor ?? theme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // ============ DIALOGUE DE SÉLECTION DE COULEUR CORRIGÉ ============

  void _showColorPickerDialog(BuildContext context, Color currentColor) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisir une couleur',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sélectionnez la couleur principale de l\'application',
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ThemeColors.userColors.entries.map((entry) {
                  final color = Color(entry.value);
                  final isSelected = color == currentColor;
                  
                  return InkWell(
                    onTap: () async {
                      final repo = SettingsRepository();
                      await repo.setPrimaryColor(entry.value);
                      
                      ref.read(userColorProvider.notifier).state = entry.key;
                      
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected 
                            ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)]
                            : null,
                      ),
                      child: isSelected 
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 32)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Annuler',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}