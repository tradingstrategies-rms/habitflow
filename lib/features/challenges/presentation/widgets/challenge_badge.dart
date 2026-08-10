import 'package:flutter/material.dart';
import '../../domain/enums/challenge_difficulty.dart';
import '../../domain/enums/challenge_type.dart';

class ChallengeBadge extends StatelessWidget {
  final ChallengeDifficulty? difficulty;
  final ChallengeType? type;

  const ChallengeBadge({
    super.key,
    this.difficulty,
    this.type,
  }) : assert(difficulty != null || type != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String label;
    final Color color;

    if (difficulty != null) {
      label = difficulty!.displayName.toUpperCase();
      switch (difficulty!) {
        case ChallengeDifficulty.easy:
          color = Colors.green;
        case ChallengeDifficulty.medium:
          color = Colors.blue;
        case ChallengeDifficulty.hard:
          color = Colors.orange;
        case ChallengeDifficulty.epic:
          color = Colors.purple;
      }
    } else {
      label = type!.displayName.toUpperCase();
      color = theme.colorScheme.secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
