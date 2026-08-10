import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitSaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const HabitSaveButton({
    super.key,
    this.onPressed,
    this.label = 'Create Habit',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: HFButton(
        label: label,
        onPressed: onPressed,
      ),
    );
  }
}
