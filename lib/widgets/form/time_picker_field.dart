// lib/widgets/forms/time_picker_field.dart
import 'package:flutter/material.dart';

class TimePickerField extends StatelessWidget {
  final TimeOfDay? value;
  final String label;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool readOnly;

  const TimePickerField({
    super.key,
    required this.value,
    required this.label,
    required this.onTimeSelected,
    this.readOnly = false,
  });

  Future<void> _selectTime(BuildContext context) async {
    if (readOnly) return;
    final initialTime = value ?? const TimeOfDay(hour: 9, minute: 0);
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time != null) {
      onTimeSelected(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded),
            const SizedBox(width: 8),
            Text(value?.format(context) ?? 'Sélectionner'),
          ],
        ),
      ),
    );
  }
}