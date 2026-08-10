import 'package:flutter/material.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_color.dart';

class HabitColorSelector extends StatelessWidget {
  final HabitColor selectedColor;
  final ValueChanged<HabitColor> onSelected;

  const HabitColorSelector({
    super.key,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: HabitColor.values.map((color) {
            final isSelected = selectedColor == color;
            return InkWell(
              onTap: () => onSelected(color),
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mapColorToColor(color),
                  border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2) : null,
                ),
                child: isSelected ? const Icon(Icons.check, size: 20) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _mapColorToColor(HabitColor color) {
    switch (color) {
      case HabitColor.emerald: return Colors.green;
      case HabitColor.blue: return Colors.blue;
      case HabitColor.orange: return Colors.orange;
      case HabitColor.purple: return Colors.purple;
      case HabitColor.red: return Colors.red;
      case HabitColor.teal: return Colors.teal;
    }
  }
}
