import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFTopAppBar(title: 'Rewards'),
      body: Center(
        child: HFEmptyState(
          title: 'No Rewards',
          message: 'Set up rewards to motivate your family members.',
          icon: Icons.card_giftcard_outlined,
          actionLabel: 'Add Reward',
          onActionPressed: () {
            // TODO: Navigate to Add Reward screen in Sprint 2
          },
        ),
      ),
    );
  }
}
