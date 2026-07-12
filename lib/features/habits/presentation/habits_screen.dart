import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: HFEmptyState(
          title: 'No Habits',
          message: 'Start tracking your daily progress.',
          icon: Icons.check_circle_outline,
          actionLabel: 'Add Habit',
        ),
      ),
    );
  }
}
