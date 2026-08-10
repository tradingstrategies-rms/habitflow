import 'package:flutter/material.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_transaction.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_type.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_source.dart';
import 'package:intl/intl.dart';

class RewardTransactionTile extends StatelessWidget {
  final RewardTransaction transaction;
  final VoidCallback? onTap;

  const RewardTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = transaction.amount >= 0;
    final amountText = '${isPositive ? '+' : ''}${transaction.amount} ${transaction.type == RewardType.xp ? 'XP' : 'Pts'}';
    final amountColor = isPositive ? Colors.green : theme.colorScheme.error;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _getIconColor(transaction.source, theme).withAlpha(40),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIconData(transaction.source),
          color: _getIconColor(transaction.source, theme),
          size: 20,
        ),
      ),
      title: Text(
        transaction.description,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${transaction.source.name.toUpperCase()} • ${DateFormat('h:mm a').format(transaction.createdAt)}',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Text(
        amountText,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: amountColor,
        ),
      ),
    );
  }

  IconData _getIconData(RewardSource source) {
    switch (source) {
      case RewardSource.habitCompletion:
        return Icons.check_circle_outline_rounded;
      case RewardSource.goalReached:
        return Icons.emoji_events_outlined;
      case RewardSource.streakMilestone:
        return Icons.local_fire_department_outlined;
      case RewardSource.familyChallenge:
        return Icons.groups_outlined;
      case RewardSource.achievementUnlocked:
        return Icons.stars_rounded;
      case RewardSource.manualAdjustment:
        return Icons.edit_note_rounded;
      case RewardSource.challengeCompletion:
        return Icons.military_tech_rounded;
      case RewardSource.rewardRedemption:
        return Icons.shopping_bag_outlined;
    }
  }

  Color _getIconColor(RewardSource source, ThemeData theme) {
    switch (source) {
      case RewardSource.habitCompletion:
        return theme.colorScheme.primary;
      case RewardSource.goalReached:
        return Colors.amber;
      case RewardSource.streakMilestone:
        return Colors.orange;
      case RewardSource.familyChallenge:
        return theme.colorScheme.secondary;
      case RewardSource.achievementUnlocked:
        return Colors.amber;
      case RewardSource.manualAdjustment:
        return theme.colorScheme.outline;
      case RewardSource.challengeCompletion:
        return theme.colorScheme.tertiary;
      case RewardSource.rewardRedemption:
        return theme.colorScheme.error; // Deductions are usually red
    }
  }
}
