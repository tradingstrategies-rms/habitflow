import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: HFGoalCard(
          title: 'Reading',
          currentValue: 10,
          targetValue: 20,
          unit: 'Books',
        ),
      ),
    );
  }
}
