import 'package:flutter/material.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_category.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitCategorySelector extends StatelessWidget {
  final HabitCategory selectedCategory;
  final ValueChanged<HabitCategory> onSelected;

  const HabitCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Life Area'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HabitCategory.values.map((cat) => HFChip(
            label: cat.name,
            isSelected: selectedCategory == cat,
            onTap: () => onSelected(cat),
          )).toList(),
        ),
      ],
    );
  }
}
