import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFTopAppBar(title: 'Habits'),
      body: Center(
        child: HFEmptyState(
          title: 'No Habits',
          message: 'Start tracking your daily progress by adding your first habit.',
          icon: Icons.check_circle_outline,
          actionLabel: 'Add Habit',
          onActionPressed: () {
            // TODO: Navigate to Add Habit screen in Sprint 2
          },
        ),
      ),
    );
  }
}
