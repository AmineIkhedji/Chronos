// lib/utils/date_formatters.dart
import 'package:intl/intl.dart';

class DateFormatters {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatTime(DateTime? time) {
    if (time == null) return 'Pas d\'heure';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatTimeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null && endTime == null) return 'Toute la journée';
    if (startTime != null && endTime == null) return 'À partir de ${formatTime(startTime)}';
    if (startTime == null && endTime != null) return 'Jusqu\'à ${formatTime(endTime)}';
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  static String formatFullDate(DateTime date) {
    try {
      return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
    } catch (_) {
      return DateFormat('EEEE d MMMM yyyy', 'en_US').format(date);
    }
  }

  static String formatShortDate(DateTime date) {
    try {
      return DateFormat('EEEE d MMMM', 'fr_FR').format(date);
    } catch (_) {
      return DateFormat('EEEE d MMMM', 'en_US').format(date);
    }
  }
}