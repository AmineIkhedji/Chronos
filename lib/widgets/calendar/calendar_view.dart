// lib/widgets/calendar/calendar_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'day_view.dart';
import 'three_days_view.dart';
import 'week_view.dart';
import 'month_view.dart';
import 'kanban_view.dart';

enum CalendarViewType {
  day('Jour'),
  threeDays('3 jours'),
  week('Semaine'),
  month('Mois'),
  kanban('Kanban');

  final String label;
  const CalendarViewType(this.label);
}

class CalendarView extends ConsumerWidget {
  final CalendarViewType viewType;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarView({
    super.key,
    required this.viewType,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (viewType) {
      case CalendarViewType.day:
        return DayView(
          date: selectedDate,
          onDateSelected: onDateSelected,
        );
      case CalendarViewType.threeDays:
        return ThreeDaysView(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
        );
      case CalendarViewType.week:
        return WeekView(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
        );
      case CalendarViewType.month:
        return MonthView(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
        );
      case CalendarViewType.kanban:
        return const KanbanView();
    }
  }
}