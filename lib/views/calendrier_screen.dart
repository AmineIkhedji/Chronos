// lib/views/calendrier_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calendar/day_view.dart';
import '../widgets/calendar/three_days_view.dart';
import '../widgets/calendar/week_view.dart';
import '../widgets/calendar/month_view.dart';
import '../widgets/calendar/kanban_view.dart';
import '../widgets/theme/theme_provider.dart';
import '../widgets/common/custom_app_bar.dart';
import 'task_form.dart';

enum CalendarViewType {
  day('Jour'),
  threeDays('3 jours'),
  week('Semaine'),
  month('Mois'),
  kanban('Kanban');

  final String label;
  const CalendarViewType(this.label);
}

class CalendrierScreen extends ConsumerStatefulWidget {
  const CalendrierScreen({super.key});

  @override
  ConsumerState<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends ConsumerState<CalendrierScreen> {
  CalendarViewType _currentView = CalendarViewType.day;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header personnalisé
            CustomAppBar(
              title: 'Calendrier',
              showBackButton: false,
              backgroundColor: theme.scaffoldBackgroundColor,
              foregroundColor: theme.colorScheme.onBackground,
              elevation: 0,
            ),
            
            // Sélecteur de vue
            _buildViewSelector(),
            
            // Contenu de la vue sélectionnée
            Expanded(
              child: _buildSelectedView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskForm()),
          );
          if (mounted) setState(() {});
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildViewSelector() {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);
    final borderColor = isDark 
        ? const Color(0xFF334155) 
        : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: CalendarViewType.values.map((type) {
            final isSelected = _currentView == type;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentView = type;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSelectedView() {
    switch (_currentView) {
      case CalendarViewType.day:
        return DayView(
          date: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        );
      case CalendarViewType.threeDays:
        return ThreeDaysView(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        );
      case CalendarViewType.week:
        return WeekView(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        );
      case CalendarViewType.month:
        return MonthView(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        );
      case CalendarViewType.kanban:
        return const KanbanView();
    }
  }
}