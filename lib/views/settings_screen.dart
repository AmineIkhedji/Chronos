// lib/views/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/settings_card.dart';
import '../widgets/common/settings_list_tile.dart';
import '../widgets/dialogs/color_picker_dialog.dart';
import '../widgets/theme/theme_provider.dart';
import '../widgets/theme/theme_colors.dart';
import '../repositories/settings_repository.dart';
import '../services/notification_service.dart';
import 'customization_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _firstDayOfWeek = DateTime.monday;
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await SettingsRepository().getSettings();
      if (!mounted) return;
      
      setState(() {
        _firstDayOfWeek = settings?.firstDayWeek ?? DateTime.monday;
        _notificationsEnabled = settings?.notificationsEnabled ?? true;
      });
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNotificationsEnabled(bool value) async {
    try {
      await SettingsRepository().setNotificationsEnabled(value);
      await NotificationService().handleNotificationsEnabledChange(value);
      
      if (mounted) {
        setState(() => _notificationsEnabled = value);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value 
              ? '✅ Notifications activées' 
              : '🔕 Notifications désactivées'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectPrimaryColor(BuildContext context, Color currentColor) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => ColorPickerDialog(currentColor: currentColor),
    );

    if (result != null) {
      try {
        final repo = SettingsRepository();
        await repo.setPrimaryColor(result);
        
        // Trouver la clé correspondante
        String? colorKey;
        for (final entry in ThemeColors.userColors.entries) {
          if (entry.value == result) {
            colorKey = entry.key;
            break;
          }
        }
        if (colorKey != null) {
          ref.read(userColorProvider.notifier).state = colorKey;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Erreur lors du changement de couleur'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final userColorKey = ref.watch(userColorProvider);
    final primaryColor = Color(ThemeColors.userColors[userColorKey] ?? ThemeColors.defaultPrimary);

    final textColor = theme.colorScheme.onBackground;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Paramètres',
        showBackButton: false,
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        titleFontSize: 30,
        toolbarHeight: 84,
        titleSpacing: 20,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION APPARENCE ---
            _buildSectionTitle('Apparence', textColor),
            const SizedBox(height: 12),
            SettingsCard(
              children: [
                SettingsListTile(
                  leadingIcon: Icons.dark_mode_rounded,
                  title: 'Mode sombre',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) async {
                      try {
                        final repo = SettingsRepository();
                        await repo.setDarkMode(value);
                        ref.read(darkModeProvider.notifier).state = value;
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Erreur lors du changement de mode'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    activeThumbColor: primaryColor,
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                SettingsListTile(
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
                          border: Border.all(color: theme.dividerColor, width: 2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                  onTap: () => _selectPrimaryColor(context, primaryColor),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- SECTION CALENDRIER ---
            _buildSectionTitle('Calendrier', textColor),
            const SizedBox(height: 12),
            SettingsCard(
              children: [
                SettingsListTile(
                  leadingIcon: Icons.calendar_today_rounded,
                  title: 'Premier jour de la semaine',
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildWeekdayToggle(
                    primaryColor: primaryColor,
                    borderColor: theme.dividerColor,
                    inactiveTextColor: textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- SECTION NOTIFICATIONS ---
            _buildSectionTitle('Notifications', textColor),
            const SizedBox(height: 12),
            SettingsCard(
              children: [
                SettingsListTile(
                  leadingIcon: Icons.notifications_rounded,
                  title: 'Rappels activés',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: _updateNotificationsEnabled,
                    activeThumbColor: primaryColor,
                  ),
                ),
                if (!_notificationsEnabled) ...[
                  Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Les rappels sont désactivés. Vous ne recevrez plus de notifications.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // --- SECTION PERSONNALISATION ---
            _buildSectionTitle('Personnalisation', textColor),
            const SizedBox(height: 12),
            SettingsCard(
              children: [
                SettingsListTile(
                  leadingIcon: Icons.sell_rounded,
                  title: 'Catégories',
                  leadingIconColor: const Color(0xFF6366F1),
                  iconBgColor: const Color(0xFF6366F1).withOpacity(0.15),
                  onTap: () => _openCustomization(CustomizationKind.categories),
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                SettingsListTile(
                  leadingIcon: Icons.flag_rounded,
                  title: 'Priorités',
                  leadingIconColor: const Color(0xFFEF4444),
                  onTap: () => _openCustomization(CustomizationKind.priorities),
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                SettingsListTile(
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

  // ============ NAVIGATION ============

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
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============ TOGGLE PREMIER JOUR DE LA SEMAINE ============

  Widget _buildWeekdayToggle({
    required Color primaryColor,
    required Color borderColor,
    required Color inactiveTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDayToggleOption(
              label: 'Lundi',
              day: DateTime.monday,
              primaryColor: primaryColor,
              inactiveTextColor: inactiveTextColor,
            ),
          ),
          Expanded(
            child: _buildDayToggleOption(
              label: 'Dimanche',
              day: DateTime.sunday,
              primaryColor: primaryColor,
              inactiveTextColor: inactiveTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayToggleOption({
    required String label,
    required int day,
    required Color primaryColor,
    required Color inactiveTextColor,
  }) {
    final isSelected = _firstDayOfWeek == day;
    return GestureDetector(
      onTap: () async {
        if (_firstDayOfWeek == day) return;
        try {
          await SettingsRepository().setFirstDayOfWeek(day);
          if (mounted) setState(() => _firstDayOfWeek = day);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Erreur lors du changement de jour'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : inactiveTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}