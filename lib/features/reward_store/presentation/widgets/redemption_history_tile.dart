import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reward_redemption.dart';
import '../../domain/entities/reward_item.dart';
import 'redemption_status_badge.dart';

class RedemptionHistoryTile extends StatelessWidget {
  final RewardRedemption redemption;
  final RewardItem? item;

  const RedemptionHistoryTile({
    super.key,
    required this.redemption,
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d, h:mm a').format(redemption.createdAt);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        item?.title ?? 'Unknown Reward',
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateStr, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          RedemptionStatusBadge(status: redemption.status),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '-${redemption.pointsSpent}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('Stars', style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
