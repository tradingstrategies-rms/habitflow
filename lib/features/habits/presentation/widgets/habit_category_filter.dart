import 'package:flutter/material.dart';

class HabitCategoryFilter extends StatelessWidget {
  const HabitCategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: ['All Habits', 'Mind', 'Body', 'Heart', 'Soul'].map((c) => FilterChip(
        label: Text(c),
        onSelected: (bool selected) {},
      )).toList(),
    );
  }
}
