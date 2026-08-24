// lib/widgets/stats/weekly_chart.dart
import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  final Map<DateTime, int> data;
  final Color barColor;
  final Color textColor;
  final Color textColorSecondary;
  final int firstDayOfWeek;

  const WeeklyChart({
    super.key,
    required this.data,
    required this.barColor,
    required this.textColor,
    required this.textColorSecondary,
    required this.firstDayOfWeek,
  });

  @override
  Widget build(BuildContext context) {
    // Trier les jours selon le premier jour de la semaine
    final sortedDays = data.keys.toList()
      ..sort((a, b) {
        final aWeekday = a.weekday;
        final bWeekday = b.weekday;
        final aOffset = (aWeekday - firstDayOfWeek + 7) % 7;
        final bOffset = (bWeekday - firstDayOfWeek + 7) % 7;
        return aOffset.compareTo(bOffset);
      });

    final maxValue = sortedDays.fold<int>(0, (max, day) {
      final value = data[day] ?? 0;
      return value > max ? value : max;
    });

    const dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight;
        const reservedHeight = 46.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: sortedDays.map((day) {
            final value = data[day] ?? 0;
            final barHeight = maxValue == 0
                ? 0.0
                : (value / maxValue) *
                      (chartHeight - reservedHeight).clamp(
                        0.0,
                        double.infinity,
                      );
            final label = dayLabels[day.weekday - 1];

            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Valeur au-dessus de la barre
                  if (value > 0)
                    Text(
                      '$value',
                      style: TextStyle(
                        color: barColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Barre
                  Container(
                    height: barHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Étiquette du jour
                  Text(
                    label,
                    style: TextStyle(
                      color: textColorSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
