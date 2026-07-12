import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: HFRewardCard(
          title: 'Movie Ticket',
          cost: 100,
          isLocked: false,
        ),
      ),
    );
  }
}
