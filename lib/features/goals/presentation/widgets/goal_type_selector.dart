import 'package:flutter/material.dart';
import '../../domain/enums/goal_type.dart';
import '../../../../core/theme/hf_spacing.dart';

class GoalTypeSelector extends StatelessWidget {
  final GoalType selectedType;
  final ValueChanged<GoalType> onTypeSelected;

  const GoalTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GOAL TYPE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: HFSpacing.s),
        Wrap(
          spacing: HFSpacing.s,
          runSpacing: HFSpacing.s,
          children: GoalType.values.map((type) {
            final isSelected = type == selectedType;
            return ChoiceChip(
              label: Text(_getTypeLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onTypeSelected(type);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getTypeLabel(GoalType type) {
    switch (type) {
      case GoalType.completionCount:
        return 'Completions';
      case GoalType.streak:
        return 'Streak';
      case GoalType.percentage:
        return 'Percentage';
      case GoalType.binary:
        return 'Yes/No';
      case GoalType.numeric:
        return 'Numeric';
    }
  }
}
