// lib/views/settings_screen.dart (VERSION FIDÈLE À LA MAQUETTE)
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
      // Header "plain" fidèle à la maquette : pas de bandeau coloré,
      // texte gras aligné à gauche sur le fond de la page.
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
            _buildCard(
              color: cardColor,
              borderColor: borderColor,
              children: [
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
                Divider(height: 1, color: borderColor.withOpacity(0.5)),
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
                ),
                Divider(height: 1, color: borderColor.withOpacity(0.5)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildWeekdayToggle(
                    primaryColor: primaryColor,
                    borderColor: borderColor,
                    inactiveTextColor: textSecondary,
                  ),
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
                // Catégories : icône "tag", fond bleu, icône verte (fidèle à la maquette)
                _buildListTile(
                  leadingIcon: Icons.sell_rounded,
                  title: 'Catégories',
                  leadingIconColor: const Color(0xFF22C55E),
                  iconBgColor: const Color(0xFF6366F1).withOpacity(0.15),
                  onTap: () => _openCustomization(CustomizationKind.categories),
                ),
                Divider(height: 1, color: borderColor.withOpacity(0.5)),
                // Priorités
                _buildListTile(
                  leadingIcon: Icons.flag_rounded,
                  title: 'Priorités',
                  leadingIconColor: const Color(0xFFEF4444),
                  onTap: () => _openCustomization(CustomizationKind.priorities),
                ),
                Divider(height: 1, color: borderColor.withOpacity(0.5)),
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
    Color? iconBgColor,
  }) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    // Icône "neutre" par défaut (gris) pour les réglages génériques.
    // Seuls les items de Personnalisation passent une couleur explicite.
    final neutralIconBg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final neutralIconColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

    final effectiveIconColor = leadingIconColor ?? neutralIconColor;
    final effectiveBgColor = iconBgColor ??
        (leadingIconColor != null ? leadingIconColor.withOpacity(0.15) : neutralIconBg);

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
                color: effectiveBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                leadingIcon,
                color: effectiveIconColor,
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

  // ============ TOGGLE PREMIER JOUR DE LA SEMAINE ============
  // NB : la maquette ne propose que 2 options (Lundi / Dimanche), alors que
  // le modèle Settings.firstDayWeek accepte les 7 jours. Si la valeur en
  // base n'est ni lundi ni dimanche, aucun bouton n'apparaît sélectionné.

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
        await SettingsRepository().setFirstDayOfWeek(day);
        if (mounted) setState(() => _firstDayOfWeek = day);
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

  // ============ DIALOGUE DE SÉLECTION DE COULEUR ============

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