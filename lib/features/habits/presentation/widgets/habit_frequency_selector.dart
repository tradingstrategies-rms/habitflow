import 'package:flutter/material.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_frequency.dart';

class HabitFrequencySelector extends StatelessWidget {
  final HabitFrequency selectedFrequency;
  final ValueChanged<HabitFrequency> onSelected;

  const HabitFrequencySelector({
    super.key,
    required this.selectedFrequency,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequency'),
        const SizedBox(height: 8),
        ...HabitFrequency.values.map((f) => RadioMenuButton<HabitFrequency>(
          value: f,
          groupValue: selectedFrequency,
          onChanged: (val) => onSelected(val!),
          child: Text(f.name),
        )),
      ],
    );
  }
}
