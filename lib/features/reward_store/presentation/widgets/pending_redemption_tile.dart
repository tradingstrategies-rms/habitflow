import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reward_redemption.dart';
import '../providers/reward_store_providers.dart';
import '../../../family/presentation/providers/family_provider.dart';

class PendingRedemptionTile extends ConsumerWidget {
  final RewardRedemption redemption;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const PendingRedemptionTile({
    super.key,
    required this.redemption,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final itemAsync = ref.watch(rewardItemByIdProvider(redemption.rewardItemId));
    final familyState = ref.watch(familyProvider);
    final childProfile = familyState.profiles.cast<dynamic>().firstWhere(
      (p) => p.id == redemption.profileId,
      orElse: () => null,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(childProfile?.displayName[0] ?? '?'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${childProfile?.displayName ?? 'Unknown'} wants to redeem:',
                        style: theme.textTheme.labelSmall,
                      ),
                      itemAsync.when(
                        data: (item) => Text(
                          item?.title ?? 'Unknown Reward',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        loading: () => const Text('Loading...'),
                        error: (_, __) => const Text('Error loading item'),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${redemption.pointsSpent} Stars',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onReject,
                  style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
