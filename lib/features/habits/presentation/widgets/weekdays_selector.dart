import 'package:flutter/material.dart';

/// [WeekdaysSelector] allows multi-selecting days of the week.
class WeekdaysSelector extends StatelessWidget {
  /// The currently selected weekdays (1 = Monday, 7 = Sunday).
  final List<int> selectedDays;

  /// Callback when the selection changes.
  final ValueChanged<List<int>> onDaysChanged;

  /// Creates a [WeekdaysSelector].
  const WeekdaysSelector({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  static const _days = [
    (1, 'Mon'),
    (2, 'Tue'),
    (3, 'Wed'),
    (4, 'Thu'),
    (5, 'Fri'),
    (6, 'Sat'),
    (7, 'Sun'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT DAYS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _days.map((day) {
            final isSelected = selectedDays.contains(day.$1);
            return FilterChip(
              label: Text(day.$2),
              selected: isSelected,
              onSelected: (bool selected) {
                final newList = List<int>.from(selectedDays);
                if (selected) {
                  newList.add(day.$1);
                } else {
                  newList.remove(day.$1);
                }
                newList.sort();
                onDaysChanged(newList);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
