// lib/widgets/forms/date_picker_field.dart
import 'package:flutter/material.dart';
import '../../utils/date_formatters.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? value;
  final String label;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.value,
    required this.label,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = value ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (date != null) {
      onDateSelected(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded),
            const SizedBox(width: 8),
            Text(
              value != null
                  ? DateFormatters.formatFullDate(value!)
                  : 'Sélectionner',
            ),
          ],
        ),
      ),
    );
  }
}
