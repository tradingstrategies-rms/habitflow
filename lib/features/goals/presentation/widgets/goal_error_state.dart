import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/foundation/hf_empty_state.dart';

class GoalErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const GoalErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HFEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Oops!',
        message: message,
      ),
    );
  }
}
