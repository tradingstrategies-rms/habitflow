import 'package:flutter/material.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/challenge_progress.dart';
import '../widgets/challenge_badge.dart';
import '../widgets/challenge_progress_card.dart';

class ChallengeDetailScreen extends StatelessWidget {
  final Challenge challenge;
  final ChallengeProgress progress;

  const ChallengeDetailScreen({
    super.key,
    required this.challenge,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = progress.isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                ChallengeBadge(type: challenge.type),
                const SizedBox(width: 8),
                ChallengeBadge(difficulty: challenge.difficulty),
                const Spacer(),
                if (isCompleted)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              challenge.title,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              challenge.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Your Progress',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ChallengeProgressCard(
              currentValue: progress.currentValue,
              targetValue: challenge.targetValue,
              unit: challenge.unit,
              progressColor: isCompleted ? Colors.green : null,
            ),
            const SizedBox(height: 40),
            Text(
              'Rewards',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRewardRow(
              theme,
              icon: Icons.stars_rounded,
              iconColor: Colors.amber,
              label: '${challenge.pointReward} Points',
              subLabel: 'Redeemable for family rewards',
            ),
            const SizedBox(height: 12),
            _buildRewardRow(
              theme,
              icon: Icons.bolt_rounded,
              iconColor: Colors.blue,
              label: '${challenge.xpReward} XP',
              subLabel: 'Level up faster',
            ),
            const SizedBox(height: 48),
            if (!isCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _getInstructionText(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardRow(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(subLabel, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInstructionText() {
    // This could be more dynamic based on challenge type
    return 'Complete habits related to this challenge to earn progress and claim your rewards!';
  }
}
