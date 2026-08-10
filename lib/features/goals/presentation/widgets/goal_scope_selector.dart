import 'package:flutter/material.dart';
import '../../domain/enums/goal_scope.dart';
import '../../../../core/theme/hf_spacing.dart';

class GoalScopeSelector extends StatelessWidget {
  final GoalScope selectedScope;
  final ValueChanged<GoalScope> onScopeSelected;

  const GoalScopeSelector({
    super.key,
    required this.selectedScope,
    required this.onScopeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIMEFRAME',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: HFSpacing.s),
        Wrap(
          spacing: HFSpacing.s,
          runSpacing: HFSpacing.s,
          children: GoalScope.values.map((scope) {
            final isSelected = scope == selectedScope;
            return ChoiceChip(
              label: Text(scope.name.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onScopeSelected(scope);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
