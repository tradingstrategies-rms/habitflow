import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class ChallengeEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const ChallengeEmptyState({
    super.key,
    this.title = 'No Challenges Yet',
    this.message = 'New challenges will appear here soon. Keep up your habits!',
    this.icon = Icons.emoji_events_outlined,
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
