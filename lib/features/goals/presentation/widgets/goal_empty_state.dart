import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/foundation/hf_empty_state.dart';

class GoalEmptyState extends StatelessWidget {
  const GoalEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: HFEmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'No Goals Yet',
        message: 'Create your first milestone and stay consistent.',
      ),
    );
  }
}
