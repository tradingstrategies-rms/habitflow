import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class RewardEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const RewardEmptyState({
    super.key,
    this.title = 'No Rewards Yet',
    this.message = 'Complete habits and goals to earn points and XP!',
    this.icon = Icons.stars_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return HFEmptyState(
      title: title,
      message: message,
      icon: icon,
    );
  }
}
