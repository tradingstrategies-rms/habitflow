import 'package:flutter/material.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';

class HabitIconSelector extends StatelessWidget {
  final HabitIcon selectedIcon;
  final ValueChanged<HabitIcon> onSelected;

  const HabitIconSelector({
    super.key,
    required this.selectedIcon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Icon'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: HabitIcon.values.map((icon) {
            final isSelected = selectedIcon == icon;
            return IconButton(
              onPressed: () => onSelected(icon),
              icon: Icon(_mapIconToData(icon)),
              style: IconButton.styleFrom(
                backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _mapIconToData(HabitIcon icon) {
    switch (icon) {
      case HabitIcon.water: return Icons.water_drop;
      case HabitIcon.book: return Icons.menu_book;
      case HabitIcon.running: return Icons.directions_run;
      case HabitIcon.meditation: return Icons.self_improvement;
      case HabitIcon.finance: return Icons.attach_money;
      case HabitIcon.family: return Icons.family_restroom;
      case HabitIcon.sleep: return Icons.bed;
      case HabitIcon.food: return Icons.restaurant;
      case HabitIcon.exercise: return Icons.fitness_center;
      case HabitIcon.custom: return Icons.star;
    }
  }
}
