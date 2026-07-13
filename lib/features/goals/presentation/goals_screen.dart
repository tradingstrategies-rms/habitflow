import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFTopAppBar(title: 'Goals'),
      body: Center(
        child: HFEmptyState(
          title: 'No Goals',
          message: 'Define what you want to achieve with your family.',
          icon: Icons.flag_outlined,
          actionLabel: 'Create Goal',
          onActionPressed: () {
            // TODO: Navigate to Create Goal screen in Sprint 2
          },
        ),
      ),
    );
  }
}
